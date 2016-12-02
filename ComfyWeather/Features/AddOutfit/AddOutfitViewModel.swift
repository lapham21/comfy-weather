//
//  AddOutfitViewModel.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/12/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

protocol AddOutfitViewModelDelegate: class {

    func viewModelDidLoadCategories(_ viewModel: AddOutfitViewModel)

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didChangeClothingItemSelectionFrom fromIndex: Int?,
                   to toIndex: Int?)

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didChangeCategorySelectionFrom fromIndexPath: IndexPath?,
                   to toIndexPath: IndexPath?)

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didAddNewClothingItemAt index: Int)

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didUpdateClothingItemAt index: Int)

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didCreateOutfit outfit: Outfit)

    func viewModel(_ viewModel: AddOutfitViewModel,
                   failedCreatingOutfit error: AddOutfitViewModelError)

}

enum AddOutfitViewModelError: Swift.Error, CustomStringConvertible {
    case unknownLocation
    case articleOfClothingCreationFailure
    case realmFailure
    case authenticationFailure
    case outfitCreationFailure

    var description: String {
        switch self {
        case .unknownLocation:
            return "We could not get your current location."
        case .articleOfClothingCreationFailure, .outfitCreationFailure:
            return "We were not able to save this outfit. Please try again."
        case .authenticationFailure:
            return "You are not logged in."
        case .realmFailure:
            return "We were not able to access your device's local storage."
        }
    }
}

final class AddOutfitViewModel {

    weak var delegate: AddOutfitViewModelDelegate?

    var comfortability: WeatherRating?
    var notes = Variable("")

    var dateText: String {
        return CommonDateFormatters.previousOutfitDateFormatter.string(from: Date())
    }

    // MARK: Child viewModel
    let addOutfitHeaderViewModel = AddOutfitHeaderViewModel()
    let outfitPhotoViewModel = OutfitPhotoViewModel()

    private let disposeBag = DisposeBag()

    // MARK: - Data for clothing items

    private struct ClothingItem {
        var categoryId: String
        var name: String
    }

    private var clothingItemsVariable = Variable([ClothingItem]())
    private var clothingItems: [ClothingItem] {
        get {
            return clothingItemsVariable.value
        }
        set {
            clothingItemsVariable.value = newValue
        }
    }

    var numberOfClothingItems: Int {
        // We have to make room for "Add Clothing" button at the end.
        return clothingItems.count + 1
    }

    func cellModelForClothingItem(at index: Int) -> ClothingItemCellViewModel {
        if index < clothingItems.count {
            let item = clothingItems[index]
            return ClothingItemCellViewModel(icon: ClothingCategory.with(id: item.categoryId)?.getIcon(),
                                             label: item.name)
        }
        else {
            return isClothingItemSelected ? ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "addClothingExit"), label: "Done")
                                          : ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "addClothing"), label: "Add Clothing")
        }
    }

    func alphaForClothingItems(at index: Int) -> CGFloat {
        if categories?.count == 0 {
            return 0.4
        }

        return !isClothingItemSelected || selectedClothingItemIndex == index ? 1.0 : 0.4
    }

    // MARK: - State changes for clothing items

    private(set) var selectedClothingItemIndex: Int?

    var isClothingItemSelected: Bool {
        return selectedClothingItemIndex != nil
    }

    func canSelectClothingItem(at index: Int) -> Bool {
        guard
            let categories = categories,
            categories.count > 0,
            0 ... clothingItems.count ~= index
            else { return false }

        return !isClothingItemSelected || index == selectedClothingItemIndex
    }

    func selectClothingItem(at index: Int) {
        if canSelectClothingItem(at: index) {
            let previouslySelectedClothingItemIndex = selectedClothingItemIndex
            selectedClothingItemIndex = (selectedClothingItemIndex == index ? nil : index)

            resetCategorySelection()

            delegate?.viewModel(self,
                                didChangeClothingItemSelectionFrom: previouslySelectedClothingItemIndex,
                                to: selectedClothingItemIndex)
        }
    }

    // MARK: - Data for adding new clothing item

    private var categories: Results<ClothingCategory>? {
        return (try? Realm())?.objects(ClothingCategory.self)
    }
    private var categoriesNotificationToken: NotificationToken?
    private var inputViewModels = [AddClothingInputViewModel]()

    private let categoriesPerSection = 4

    var numberOfCategorySections: Int {
        guard let categories = categories else { return 0 }
        return Int(ceil( Double(categories.count) / Double(categoriesPerSection) ))
    }

    func numberOfCategories(in section: Int) -> Int {
        guard
            let categories = categories,
            0 ..< numberOfCategorySections ~= section
            else {
                return 0
            }

        let startIndex = section * categoriesPerSection
        let endIndex = startIndex + categoriesPerSection - 1

        return endIndex < categories.count ? categoriesPerSection : categories.count - startIndex
    }

    func cellModelForCategory(at indexPath: IndexPath) -> ClothingItemCellViewModel? {
        guard let item = category(at: indexPath) else { return nil }
        return ClothingItemCellViewModel(icon: item.getIcon(), label: item.name)
    }

    func alphaForCategory(at indexPath: IndexPath) -> CGFloat {
        if !isCategorySelected || selectedCategoryIndexPath == indexPath {
            return 1.0
        }
        else {
            return 0.4
        }
    }

    func heightOfAddClothingView(cellSize: CGSize) -> CGFloat {
        if !isClothingItemSelected || cellSize == CGSize.zero {
            return 0.0
        }

        let heightOfCells = CGFloat(numberOfCategorySections) * cellSize.height + 16.5

        if isCategorySelected {
            return heightOfCells + heightOfAddClothingInputView
        }
        else {
            return heightOfCells
        }
    }

    let heightOfAddClothingInputView: CGFloat = 60.0

    func inputViewModelForCategory(at indexPath: IndexPath) -> AddClothingInputViewModel {
        return inputViewModels[indexPath.toCategoryIndex(categoriesPerSection: categoriesPerSection)]
    }

    private func category(at indexPath: IndexPath) -> ClothingCategory? {
        return categories?[indexPath.toCategoryIndex(categoriesPerSection: categoriesPerSection)]
    }

    // MARK: - State changes for adding new clothing item

    private(set) var selectedCategoryIndexPath: IndexPath?

    var isCategorySelected: Bool {
        return isClothingItemSelected && selectedCategoryIndexPath != nil
    }

    func canSelectCategory(at indexPath: IndexPath) -> Bool {
        guard
            isClothingItemSelected,
            selectedCategoryIndexPath != indexPath,
            0 ..< numberOfCategorySections ~= indexPath.section,
            0 ..< numberOfCategories(in: indexPath.section) ~= indexPath.row
            else {
                return false
            }

        return true
    }

    func selectCategory(at indexPath: IndexPath) {
        if canSelectCategory(at: indexPath) {
            let previouslySelectedCategoryIndexPath = selectedCategoryIndexPath
            selectedCategoryIndexPath = indexPath

            delegate?.viewModel(self,
                                didChangeCategorySelectionFrom: previouslySelectedCategoryIndexPath,
                                to: selectedCategoryIndexPath)
        }
    }

    private func resetCategorySelection() {
        if selectedClothingItemIndex == clothingItems.count {
            selectedCategoryIndexPath = nil
            inputViewModels = categories?.map { _ in AddClothingInputViewModel() } ?? []

            return
        }

        guard let selectedClothingItemIndex = selectedClothingItemIndex else { return }
        let selectedClothingItem = clothingItems[selectedClothingItemIndex]
        guard let selectedCategory = ClothingCategory.with(id: selectedClothingItem.categoryId) else { return }

        if let selectedCategoryIndex = categories?.index(of: selectedCategory) {
            selectedCategoryIndexPath = selectedCategoryIndex.toCategoryIndexPath(categoriesPerSection: categoriesPerSection)
            inputViewModels = categories?.map { category in
                let viewModel = AddClothingInputViewModel()

                if category == selectedCategory {
                    viewModel.outfitName.value = selectedClothingItem.name
                }

                return viewModel
            } ?? []
        }
        else {
            selectedCategoryIndexPath = nil
            inputViewModels = categories?.map { _ in AddClothingInputViewModel() } ?? []
        }
    }

    // MARK: - Adding a clothing item

    func finalizeClothingItemAddition() {
        guard
            let selectedClothingItemIndex = selectedClothingItemIndex,
            let selectedCategoryIndexPath = selectedCategoryIndexPath,
            let selectedCategory = category(at: selectedCategoryIndexPath)
            else { return }

        let inputViewModel = inputViewModelForCategory(at: selectedCategoryIndexPath)

        if inputViewModel.outfitName.value.isEmpty {
            return
        }

        let newClothingItem = ClothingItem(categoryId: selectedCategory.id, name: inputViewModel.outfitName.value)

        if selectedClothingItemIndex == clothingItems.count {
            clothingItems.append(newClothingItem)

            self.selectedClothingItemIndex = nil
            self.selectedCategoryIndexPath = nil

            delegate?.viewModel(self, didAddNewClothingItemAt: selectedClothingItemIndex)
        }
        else {
            clothingItems[selectedClothingItemIndex] = newClothingItem

            self.selectedClothingItemIndex = nil
            self.selectedCategoryIndexPath = nil

            delegate?.viewModel(self, didUpdateClothingItemAt: selectedClothingItemIndex)
        }
    }

    // MARK: - Outfit creation

    lazy var canCreateOutfit: Observable<Bool> = {
        Observable
            .combineLatest(
                self.creatingOutfit.asObservable(),
                self.clothingItemsVariable.asObservable().map { $0.count > 0 },
                self.outfitPhotoViewModel.outfitImage.asObservable().map { $0 != nil },

                resultSelector: { creatingOutfit, outfitHasClothingItems, outfitHasPhoto in
                    !creatingOutfit && (outfitHasClothingItems || outfitHasPhoto)
                }
            )
            .observeOn(MainScheduler.instance)
    }()

    private var creatingOutfit = Variable(false)

    func createOutfit() {
        guard !creatingOutfit.value else { return }

        creatingOutfit.value = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let welf = self else { return }

            guard let location = LocationService.sharedInstance.lastLocation else {
                welf.creatingOutfit.value = false
                welf.delegate?.viewModel(welf, failedCreatingOutfit: .unknownLocation)
                return
            }

            var articlesOfClothingIds = [String]()
            var articlesOfClothing = [ArticleOfClothing]()

            if welf.clothingItems.count > 0 {
                guard let maybeArticlesOfClothingIds = welf.createArticleOfClothing(index: 0) else {
                    welf.creatingOutfit.value = false
                    welf.delegate?.viewModel(welf, failedCreatingOutfit: .articleOfClothingCreationFailure)
                    return
                }

                articlesOfClothingIds = maybeArticlesOfClothingIds

                guard let realm = try? Realm() else {
                    welf.creatingOutfit.value = false
                    welf.delegate?.viewModel(welf, failedCreatingOutfit: .realmFailure)
                    return
                }
                realm.refresh()

                let articlesOfClothingResults = realm.objects(ArticleOfClothing.self)
                                                     .filter { articlesOfClothingIds.contains($0.id) }
                articlesOfClothing = articlesOfClothingResults.sorted { $0.id > $1.id }
            }

            defer {
                if let realm = try? Realm() {
                    let toBeDeleted = realm.objects(ArticleOfClothing.self)
                                           .filter { articlesOfClothingIds.contains($0.id) }
                    try? realm.write {
                        realm.delete(toBeDeleted)
                    }
                }
            }

            guard
                let request = OutfitCreationRequest(location: location,
                                                    articlesOfClothing: articlesOfClothing,
                                                    photo: welf.outfitPhotoViewModel.outfitImage.value,
                                                    notes: welf.notes.value,
                                                    rating: welf.comfortability)
                else {
                    welf.creatingOutfit.value = false
                    welf.delegate?.viewModel(welf, failedCreatingOutfit: .authenticationFailure)
                    return
                }

            request.create { [weak self] result in
                guard let welf = self else { return }

                switch result {
                case .success(let outfit):
                    welf.creatingOutfit.value = false
                    welf.delegate?.viewModel(welf, didCreateOutfit: outfit)

                case .failure:
                    welf.creatingOutfit.value = false
                    welf.delegate?.viewModel(welf, failedCreatingOutfit: .outfitCreationFailure)
                }
            }
        }
    }

    private func createArticleOfClothing(index: Int) -> [String]? {
        guard 0 ..< clothingItems.count ~= index else { return nil }

        let clothingItem = clothingItems[index]
        guard
            let category = ClothingCategory.with(id: clothingItem.categoryId),
            let request = ArticleOfClothingCreationRequest(description: clothingItem.name, category: category)
            else { return nil }

        // Using this semaphore to turn our asynchronous request into a synchronous operation with a timeout.
        let semaphore = DispatchSemaphore(value: 0)

        // This array will be populated by our request's completion handler with IDs of created articles of clothing.
        // The completion handler sets this to nil if an error occurs.
        var createdArticlesOfClothingIds: [String]? = [String]()

        request.create { [weak self] result in
            do {
                guard case .success(let articleOfClothing) = result else {
                    throw AddOutfitViewModelError.articleOfClothingCreationFailure
                }

                createdArticlesOfClothingIds?.append(articleOfClothing.id)

                let realm = try Realm()
                try realm.write {
                    realm.add(articleOfClothing)
                }

                if let moreArticlesOfClothing = self?.createArticleOfClothing(index: index + 1) {
                    createdArticlesOfClothingIds?.append(contentsOf: moreArticlesOfClothing)
                }
            }
            catch {
                createdArticlesOfClothingIds = nil
            }

            semaphore.signal()
        }

        let timer = DispatchTime.now() + .seconds(60)
        guard case .success = semaphore.wait(timeout: timer) else {
            return nil
        }

        return createdArticlesOfClothingIds
    }

    // MARK: - Initialization

    init() {

        if categories == nil || categories?.isEmpty == true {
            ClothingCategoryRequest().fetchCategories()
        }

        DispatchQueue.main.async { [weak self] in
            self?.categoriesNotificationToken = self?.categories?.addNotificationBlock { [weak self] changes in
                switch changes {
                case .initial, .update:
                    guard let welf = self else { return }
                    welf.delegate?.viewModelDidLoadCategories(welf)

                case .error:
                    break
                }
            }
        }
    }

}

private extension Int {

    func toCategoryIndexPath(categoriesPerSection: Int) -> IndexPath {
        let section = Int( floor(Double(self) / Double(categoriesPerSection)) )

        let sectionStartIndex = section * categoriesPerSection
        let row = self - sectionStartIndex

        return IndexPath(row: row, section: section)
    }

}

private extension IndexPath {

    func toCategoryIndex(categoriesPerSection: Int) -> Int {
        return section * categoriesPerSection + row
    }

}
