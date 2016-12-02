//
//  LoginViewModel.swift
//  ComfyWeather
//
//  Created by Son Le on 9/27/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import FacebookCore
import FacebookLogin

struct LoginViewModel {

    private var facebookLoginManager = LoginManager()

    weak var delegate: LoginViewModelDelegate?

    // MARK: - Login via Facebook

    func loginViaFacebook() {
        if let token = AccessToken.current {
            handle(token: token)
        }
        else {
            facebookLoginManager.logIn([.publicProfile, .email], viewController: nil) { result in
                switch result {
                case let .success(_, _, token):
                    self.handle(token: token)

                case let .failed(error):
                    self.delegate?.viewModel(self, loginFailed: error)

                case .cancelled:
                    self.delegate?.userCancelledLogin(viewModel: self)
                }
            }
        }
    }

    private func handle(token: AccessToken) {
        let authRequest = LoginRequest(facebookToken: token.authenticationToken)
        authRequest.authenticate { result in
            switch result {
            case .success(let user):
                self.delegate?.viewModel(self, userLoggedIn: user)
            case .failure(let error):
                self.facebookLoginManager.logOut()
                self.delegate?.viewModel(self, loginFailed: error)
            }
        }
    }

}

/// These delegate methods are most likely not going to be called on the main thread.
protocol LoginViewModelDelegate: class {

    func viewModel(_ viewModel: LoginViewModel, userLoggedIn user: User)

    func userCancelledLogin(viewModel: LoginViewModel)

    func viewModel(_ viewModel: LoginViewModel, loginFailed error: Error)

}
