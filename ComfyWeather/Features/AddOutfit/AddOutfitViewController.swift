//
//  AddOutfitViewController.swift
//  ComfyWeather
//
//  Created by MIN BU on 9/27/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddOutfitViewController: UITableViewController, AddOutfitViewModelDelegate {

    private let addClothingViewIndexPath = IndexPath(row: 2, section: 0)
    private var addClothingViewRow: Int {
        return addClothingViewIndexPath.row
    }

    private let disposeBag = DisposeBag()
    private(set) var locationLabelText: Observable<String?>
        = LocationService.sharedInstance.geoLocationObservable.map {
            if case .success(let location) = $0 {
                return location
            } else {
                return LocationService.sharedInstance.lastGeoCode?.uppercased() ?? ""
            }
          }

    // MARK: - View models
    var viewModel = AddOutfitViewModel()
    var outfitPhotoViewModel: OutfitPhotoViewModel {
        return viewModel.outfitPhotoViewModel
    }

    // MARK: - IBOutlet
    @IBOutlet weak var addOutfitTable: UITableView!
    @IBOutlet weak var weatherStack: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextField!

    // MARK: - Subviews
    @IBOutlet weak var clothingItemsView: UICollectionView!
    @IBOutlet weak var addClothingContainerView: UIView!

    private let addOutfitHeaderView = Bundle.main.load(AddOutfitHeaderView.self)
    private let addClothingView = Bundle.main.load(AddClothingView.self)
    private var categoriesView: UICollectionView? {
        return addClothingView?.categoriesView
    }

    // MARK: - Data sources
    private let clothingItemsDataSource = ClothingItemsController()
    private let addClothingDataSource = AddClothingController()

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHeaderView()
        loadWeatherTypeView()
        changeLetterSpacing()

        setupViewModel()
        setupClothingItemsView()
        setupAddClothingView()
        setupNavigationItem()

        setGeoLocation()
        setDateLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setupForAddOutfitsStack()
    }

    private func setupNavigationItem() {
        navigationItem.title = "ADD OUTFIT"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exitMenuWhite"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(exitButtonTapped))

        guard let chivoRegularFont = UIFont.chivo(size: 13.0, style: .light) else { return }

        let rightBarButtonItem = UIBarButtonItem(title: "COMPLETE",
                                                 style: .done,
                                                 target: self,
                                                 action: #selector(completeButtonTapped))
        rightBarButtonItem.setTitleTextAttributes([NSFontAttributeName : chivoRegularFont], for: .normal)
        rightBarButtonItem.isEnabled = false

        viewModel.canCreateOutfit.bindTo(rightBarButtonItem.rx.enabled).addDisposableTo(disposeBag)

        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func setupViewModel() {
        viewModel.delegate = self

        notesTextField.rx.text.bindTo(viewModel.notes).addDisposableTo(disposeBag)
    }

    private func loadHeaderView() {
        guard let addOutfitHeaderView = addOutfitHeaderView else {return}
        addOutfitHeaderView.configure(with: viewModel.addOutfitHeaderViewModel)

        addOutfitTable.tableHeaderView = addOutfitHeaderView

        let gesture = UITapGestureRecognizer(target: self, action: #selector(addPhotoButtonPressed))
        addOutfitHeaderView.addGestureRecognizer(gesture)

        outfitPhotoViewModel.outfitImage.asObservable().bindTo(addOutfitHeaderView.imageView.rx.image)
                                                        .addDisposableTo(disposeBag)
    }

    private func setupClothingItemsView() {
        clothingItemsView.registerNib(of: ClothingItemCell.self)

        clothingItemsView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 30.0, bottom: -10.0, right: 30.0)
        clothingItemsView.contentInset = UIEdgeInsets(top: 0, left: 30.0, bottom: 0, right: 30.0)

        clothingItemsView.dataSource = clothingItemsDataSource
        clothingItemsView.delegate = clothingItemsDataSource

        clothingItemsDataSource.viewModel = viewModel
    }

    private func setupAddClothingView() {
        addClothingContainerView.fill(with: addClothingView ?? UIView())

        categoriesView?.dataSource = addClothingDataSource
        categoriesView?.delegate = addClothingDataSource

        addClothingDataSource.viewModel = viewModel
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    // MARK: - User interactions

    @objc private func exitButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func completeButtonTapped() {
        viewModel.createOutfit()
    }

    @objc private func addPhotoButtonPressed() {
        let storyboard = UIStoryboard(name: "AddPhotoStoryboard", bundle: nil)
        guard let addPhotoViewController = storyboard.instantiateViewController(withIdentifier: "AddPhotoView") as? AddPhotoViewController
            else { return }
        addPhotoViewController.viewModel = outfitPhotoViewModel
        navigationController?.pushViewController(addPhotoViewController, animated: true)
    }

    // MARK: - AddOutfitViewModelDelegate

    func viewModelDidLoadCategories(_ viewModel: AddOutfitViewModel) {
        updateAlphaOfVisibleClothingItemCells()
        categoriesView?.reloadData()
    }

    // These methods work with this controller and ClothingItemsDataSource to animate AddClothingView in when user
    // taps "Add Clothing" and out when user taps "Done".
    // --------------------

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didChangeClothingItemSelectionFrom fromIndex: Int?,
                   to toIndex: Int?) {
        prepareToAnimateAddClothingView()

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.animateClothingItems(fromIndex: fromIndex, toIndex: toIndex)
        }

        animateAddClothingViewRowInsertionOrDeletion()
    }

    private func prepareToAnimateAddClothingView() {
        if viewModel.isClothingItemSelected {
            categoriesView?.reloadData()
        }

        view.endEditing(false)
    }

    private func animateClothingItems(fromIndex: Int?, toIndex: Int?) {
        updateAlphaOfVisibleClothingItemCells()

        if let fromIndex = fromIndex {
            clothingItemsView.reloadItems(at: [IndexPath(row: fromIndex, section: 0)])
        }
        if let toIndex = toIndex {
            clothingItemsView.reloadItems(at: [IndexPath(row: toIndex, section: 0)])
        }
    }

    private func animateAddClothingViewRowInsertionOrDeletion() {
        tableView.beginUpdates()

        if viewModel.isClothingItemSelected {
            tableView.insertRows(at: [addClothingViewIndexPath], with: .none)
            tableView.reloadData()
        }
        else {
            tableView.deleteRows(at: [addClothingViewIndexPath], with: .none)
        }

        tableView.endUpdates()

        let clothingItemsViewIndexPath = IndexPath(row: addClothingViewIndexPath.row - 1,
                                                   section: addClothingViewIndexPath.section)
        tableView.scrollToRow(at: clothingItemsViewIndexPath, at: .top, animated: true)
    }

    // These methods work with AddClothingDataSource to animate AddClothingInputView when user taps a category.
    // --------------------

    func viewModel(_ viewModel: AddOutfitViewModel,
                   didChangeCategorySelectionFrom fromIndexPath: IndexPath?,
                   to toIndexPath: IndexPath?) {
        configureInputViews(from: fromIndexPath, to: toIndexPath)

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.animateAddClothingCategorySelection(from: fromIndexPath, to: toIndexPath)
        }

        animateAddClothingRowExpansion()
    }

    private func configureInputViews(from fromIndexPath: IndexPath?, to toIndexPath: IndexPath?) {
        view.endEditing(false)

        guard let toIndexPath = toIndexPath else { return }

        let supplementaryView = categoriesView?.supplementaryView(
            forElementKind: UICollectionElementKindSectionFooter,
            at: IndexPath(row: 0, section: toIndexPath.section)
        )
        guard let inputView = supplementaryView as? AddClothingInputView else { return }
        
        inputView.configure(
            withViewModel: viewModel.inputViewModelForCategory(at: toIndexPath),
            completion: { [weak self] in
                self?.viewModel.finalizeClothingItemAddition()
            }
        )
    }

    private func animateAddClothingCategorySelection(from fromIndexPath: IndexPath?, to toIndexPath: IndexPath?) {
        // This animates AddClothingInputViews and sections as necessary.
        if let toIndexPath = toIndexPath {
            categoriesView?.moveSection(toIndexPath.section, toSection: toIndexPath.section)
        }
        else if let fromIndexPath = fromIndexPath {
            categoriesView?.moveSection(fromIndexPath.section, toSection: fromIndexPath.section)
        }

        guard let indexPathsForVisibleItems = categoriesView?.indexPathsForVisibleItems else {
            return
        }
        for visibleIndexPath in indexPathsForVisibleItems {
            let alpha = viewModel.alphaForCategory(at: visibleIndexPath)
            categoriesView?.cellForItem(at: visibleIndexPath)?.contentView.alpha = alpha
        }
    }

    private func animateAddClothingRowExpansion() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // These methods animate AddClothingView out of view and animate the newly added clothing item into view.
    // --------------------

    func viewModel(_ viewModel: AddOutfitViewModel, didAddNewClothingItemAt index: Int) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.animateClothingItemAddition(index: index)
        }

        animateAddClothingViewRowInsertionOrDeletion()
    }

    private func animateClothingItemAddition(index: Int) {
        clothingItemsView.performBatchUpdates({ [weak self] in
            guard let welf = self else { return }

            let addClothingCellIndex = welf.viewModel.numberOfClothingItems - 2
            welf.clothingItemsView.reloadItems(at: [IndexPath(row: addClothingCellIndex, section: 0)])

            welf.clothingItemsView.insertItems(at: [IndexPath(row: index, section: 0)])
        })

        updateAlphaOfVisibleClothingItemCells()
    }

    // These methods animate AddClothingView out of view and changes the updated clothing item.
    // --------------------

    func viewModel(_ viewModel: AddOutfitViewModel, didUpdateClothingItemAt index: Int) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.animateClothingItemUpdate(index: index)
        }

        animateAddClothingViewRowInsertionOrDeletion()
    }

    private func animateClothingItemUpdate(index: Int) {
        clothingItemsView.reloadItems(at: [IndexPath(row: index, section: 0)])
        updateAlphaOfVisibleClothingItemCells()
    }

    // --------------------

    func viewModel(_ viewModel: AddOutfitViewModel, didCreateOutfit outfit: Outfit) {
        dismiss(animated: true)
    }

    func viewModel(_ viewModel: AddOutfitViewModel, failedCreatingOutfit error: AddOutfitViewModelError) {
        let alertController = UIAlertController(title: "Whoops!", message: "\(error)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController?.visibleViewController?.present(alertController, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !viewModel.isClothingItemSelected && indexPath.row >= addClothingViewRow {
            return super.tableView(tableView,
                                   cellForRowAt: IndexPath(row: indexPath.row + 1, section: indexPath.section))
        }
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isClothingItemSelected
            ? super.tableView(tableView, numberOfRowsInSection: section)
            : super.tableView(tableView, numberOfRowsInSection: section) - 1
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.isClothingItemSelected {
            if indexPath.row == addClothingViewRow {
                let flowLayout = categoriesView?.collectionViewLayout as? UICollectionViewFlowLayout
                let cellSize = flowLayout?.itemSize ?? CGSize.zero

                return viewModel.heightOfAddClothingView(cellSize: cellSize)
            }
            else {
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }
        else {
            if indexPath.row >= addClothingViewRow {
                return super.tableView(tableView,
                                       heightForRowAt: IndexPath(row: indexPath.row + 1, section: indexPath.section))
            }
            else {
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }
    }

    // MARK: - Helpers

    private func loadWeatherTypeView() {
        let viewModels = createWeatherTypes()

        for viewModel in viewModels {
            guard let addOutfitWeatherView = Bundle.main.load(WeatherTypeView.self)
                else {return}

            addOutfitWeatherView.viewModel = viewModel
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(comfyLevelSelected(sender:)))
            addOutfitWeatherView.addGestureRecognizer(gestureRecognizer)
            weatherStack.addArrangedSubview(addOutfitWeatherView)
        }
    }

    @objc private func comfyLevelSelected(sender: UITapGestureRecognizer) {
        guard let selectedView = sender.view as? WeatherTypeView,
                let selectedViewWeatherType = selectedView.viewModel?.weatherType
            else { return }

        for view in weatherStack.arrangedSubviews {
            guard let currentView = view as? WeatherTypeView,
                    let isSelected = currentView.viewModel?.isSelected
            else { return }

            if currentView.viewModel?.weatherType == selectedViewWeatherType {
                viewModel.comfortability = isSelected ? nil : selectedViewWeatherType
                currentView.viewModel?.isSelected = !isSelected
            } else {
                currentView.viewModel?.isSelected = false
            }
        }
    }

    private func createWeatherTypes() -> [WeatherTypeViewModel] {
        let chillyViewModel = WeatherTypeViewModel(weatherType: .chilly)
        let comfyViewModel = WeatherTypeViewModel(weatherType: .comfy)
        let toastyViewModel = WeatherTypeViewModel(weatherType: .toasty)

        return [chillyViewModel, comfyViewModel, toastyViewModel]
    }

    private func changeLetterSpacing() {
        locationLabel.ip_setCharacterSpacing(value: 0.3)
        locationLabel.ip_setLineHeight(lineHeight: 20)
        dateLabel.ip_setCharacterSpacing(value: 0.3)
        dateLabel.ip_setLineHeight(lineHeight: 20)
    }

    private func setGeoLocation() {
        locationLabelText.asObservable().bindTo(locationLabel.rx.text).addDisposableTo(disposeBag)
    }

    private func setDateLabel() {
        dateLabel.text = viewModel.dateText
    }

    private func updateAlphaOfVisibleClothingItemCells() {
        for indexPath in clothingItemsView.indexPathsForVisibleItems {
            let alpha = viewModel.alphaForClothingItems(at: indexPath.row)
            clothingItemsView.cellForItem(at: indexPath)?.contentView.alpha = alpha
        }
    }

}

/// This class serves as the data source and delegate of the collection view displaying added articles of clothing.
private final class ClothingItemsController: NSObject,
                                             UICollectionViewDataSource,
                                             UICollectionViewDelegate {

    weak var viewModel: AddOutfitViewModel?

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfClothingItems ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let genericCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ClothingItemCell.self)",
                                                             for: indexPath)

        guard
            let viewModel = viewModel,
            let cell = genericCell as? ClothingItemCell
            else {
                return genericCell
            }

        cell.configure(with: viewModel.cellModelForClothingItem(at: indexPath.row))

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        cell.contentView.alpha = viewModel?.alphaForClothingItems(at: indexPath.row) ?? 1.0
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel?.canSelectClothingItem(at: indexPath.row) ?? false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectClothingItem(at: indexPath.row)
    }

}

/// This class serves as the data source and delegate of the collection view the user sees after tapping "Add Clothing".
private final class AddClothingController: NSObject,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegate,
                                           UICollectionViewDelegateFlowLayout {

    weak var viewModel: AddOutfitViewModel?

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.numberOfCategorySections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfCategories(in: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let genericCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ClothingItemCell.self)",
                                                             for: indexPath)

        guard
            let viewModel = viewModel,
            let cell = genericCell as? ClothingItemCell
            else {
                return genericCell
        }

        if let cellViewModel = viewModel.cellModelForCategory(at: indexPath) {
            cell.configure(with: cellViewModel)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: "\(AddClothingInputView.self)",
                                                               for: indexPath)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        cell.contentView.alpha = viewModel?.alphaForCategory(at: indexPath) ?? 1.0
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel?.canSelectCategory(at: indexPath) ?? false
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        guard
            let inputView = view as? AddClothingInputView,
            let selectedCategoryIndexPath = viewModel?.selectedCategoryIndexPath
            else { return }

        inputView.configure(
            withViewModel: viewModel?.inputViewModelForCategory(at: selectedCategoryIndexPath),
            completion: { [weak self] in
                self?.viewModel?.finalizeClothingItemAddition()
            }
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectCategory(at: indexPath)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if viewModel?.selectedCategoryIndexPath?.section == section {
            return CGSize(width: collectionView.bounds.width, height: viewModel?.heightOfAddClothingInputView ?? 0.0)
        }
        else {
            return CGSize(width: collectionView.bounds.width, height: 0.01)
        }
    }

}
