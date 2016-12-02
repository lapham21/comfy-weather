//
//  LoginViewController.swift
//  ComfyWeather
//
//  Created by Son Le on 9/27/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import CoreLocation

final class LoginViewController: UIViewController, UIViewControllerTransitioningDelegate, LocationServiceDelegate  {

    @IBOutlet fileprivate weak var loginButton: UIButton!

    private var viewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        setUpLetterSpacing()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.startUpdatingLocation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LocationService.sharedInstance.delegate = nil
    }

    @IBAction func loginViaFacebookButtonPressed(_ sender: UIButton) {
        loginButton.isEnabled = false
        viewModel.loginViaFacebook()
    }

    // MARK: LocationServiceDelegate
    internal func tracingLocation(currentLocation: CLLocation) {
    }

    internal func tracingLocationDidFailWithError(error: NSError) {
        if !LocationService.sharedInstance.isAuthorized {
            let permissionViewController = PermissionLocationViewController()
            permissionViewController.modalPresentationStyle = .custom
            permissionViewController.transitioningDelegate = permissionViewController
            navigationController?.visibleViewController?.present(permissionViewController, animated: true)
        }
    }

    private func setUpLetterSpacing() {
        guard let title = loginButton.titleLabel?.text else {return}
        let attributedTitle = NSAttributedString(string: title, attributes: [NSKernAttributeName: 0.5])
        loginButton.setAttributedTitle(attributedTitle, for: .normal)
    }

}

extension LoginViewController: LoginViewModelDelegate {

    func viewModel(_ viewModel: LoginViewModel, userLoggedIn user: User) {
        // TODO: Integrate with app flow.
        print(user)

        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(HomeScreenController(), animated: true)
        }
    }

    func userCancelledLogin(viewModel: LoginViewModel) {
        // TODO: Get designs for screen to show when user cancels log in.
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Please log in.", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alertController, animated: true) { [weak self] in
                self?.loginButton.isEnabled = true
            }
        }
    }

    func viewModel(_ viewModel: LoginViewModel, loginFailed error: Error) {
        // TODO: Get designs for screen to show when log in process fails.
        DispatchQueue.main.async { [weak self] in
            guard let error = error as? BackendRequestError else { return }

            let alertController = UIAlertController(title: "Uh oh…", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Nice", style: .default))
            self?.present(alertController, animated: true) { [weak self] in
                self?.loginButton.isEnabled = true
            }
        }
    }

}
