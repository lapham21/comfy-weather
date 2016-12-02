//
//  HomeScreenController.swift
//  ComfyWeather
//
//  Created by Son Le on 10/4/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxSwift
import RxCocoa

final class HomeScreenController: UIViewController {

    private let viewModel = HomeScreenViewModel()
    private let weatherAssetsViewModel = WeatherAssetsViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - Outlets

    @IBOutlet weak var previousOutfitsLabel: UILabel!
    @IBOutlet weak var recommendedLabel: UILabel!
    @IBAction func previousOutfitViewTapped(_ sender: UITapGestureRecognizer) {
        let previousOutfitsViewController = PreviousOutfitsViewController()
        let previousOutfitsNavController = UINavigationController(rootViewController: previousOutfitsViewController)
        navigationController?.visibleViewController?.present(previousOutfitsNavController, animated: true)
    }

    // MARK: - Child views

    @IBOutlet weak var weatherIllustrationImageView: UIImageView!
    @IBOutlet weak var morningForecastContainerView: UIView!
    @IBOutlet weak var afternoonForecastContainerView: UIView!
    @IBOutlet weak var eveningForecastContainerView: UIView!

    @IBOutlet weak var recommendedOutfitsView: UICollectionView!
    @IBOutlet weak var recommendedOutfitsFlowLayout: UICollectionViewFlowLayout!

    private let morningForecastView = Bundle.main.load(ForecastColumnView.self)
    private let afternoonForecastView = Bundle.main.load(ForecastColumnView.self)
    private let eveningForecastView = Bundle.main.load(ForecastColumnView.self)

    private let weatherHomeScreenView = Bundle.main.load(WeatherHomeScreenView.self)

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserInterface()
        setupBindings()
        loadChildViews()
        setupWeatherAssets()

        viewModel.requestForecasts()
        viewModel.fetchRecommendedOutfits()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setupforHomeScreen()
    }

    private func setupBindings() {
        viewModel.location.asObservable().bindTo(rx.title).addDisposableTo(disposeBag)

        viewModel.recommendedOutfits.asObservable()
            .bindTo(recommendedOutfitsView.rx.items(cellIdentifier: "\(ClothingItemCell.self)",
                                                    cellType: ClothingItemCell.self))
            { _, model, cell in
                cell.configure(with: model)
            }
            .addDisposableTo(disposeBag)

        guard
            let morningForecastView = morningForecastView,
            let afternoonForecastView = afternoonForecastView,
            let eveningForecastView = eveningForecastView
        else {
            return
        }

        morningForecastView.configure(with: viewModel.morningForecastViewModel)
        afternoonForecastView.configure(with: viewModel.afternoonForecastViewModel)
        eveningForecastView.configure(with: viewModel.eveningForecastViewModel)
    }

    private func setupUserInterface() {
        recommendedLabel.ip_setCharacterSpacing(value: 0.5)
        previousOutfitsLabel.ip_setCharacterSpacing(value: 0.5)

        recommendedOutfitsView.registerNib(of: ClothingItemCell.self)

        edgesForExtendedLayout = .bottom

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain,
                                                           target: self, action: #selector(menuButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addOutfit"), style: .plain,
                                                            target: self, action: #selector(addOutfitButtonTapped))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func loadChildViews() {
        guard
            let morningForecastView = morningForecastView,
            let afternoonForecastView = afternoonForecastView,
            let eveningForecastView = eveningForecastView
        else {
            return
        }

        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay = TimeOfDay(hour: hour) ?? .afternoon
        switch timeOfDay { 
        case .afternoon:
            morningForecastView.alpha = 0.4
            eveningForecastView.alpha = 0.4
        case .evening:
            morningForecastView.alpha = 0.4
            afternoonForecastView.alpha = 0.4
        default:
            afternoonForecastView.alpha = 0.4
            eveningForecastView.alpha = 0.4
        }

        morningForecastContainerView.fill(with: morningForecastView)
        afternoonForecastContainerView.fill(with: afternoonForecastView)
        eveningForecastContainerView.fill(with: eveningForecastView)
    }

    // MARK: - Navigation bar buttons

    @objc private func addOutfitButtonTapped() {
        let storyboard = UIStoryboard.init(name: "AddOutfitStoryboard", bundle: nil)
        let addOutfitViewController = storyboard.instantiateViewController(withIdentifier: "AddOutfitViewController")
        let addOutfitNavController = UINavigationController(rootViewController: addOutfitViewController)

        navigationController?.visibleViewController?.present(addOutfitNavController, animated: true)
    }

    @objc private func menuButtonTapped() {
        // TODO: Show user's profile.
    }

    private func setupWeatherAssets() {
        weatherHomeScreenView?.configure(with: viewModel.weatherAssetsViewModel)
        guard let weatherHomeScreenView = weatherHomeScreenView else {return}
        weatherIllustrationImageView.fill(with: weatherHomeScreenView)

    }

}
