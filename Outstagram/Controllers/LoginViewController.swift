//
//  LoginViewController.swift
//  Outstagram
//
//  Created by Beavean on 09.01.2023.
//

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {

    // MARK: - UI Elements

    private let logoContainerView = AuthenticationImageView(image: UIImage(systemName: "camera"))
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "O U T S T A G R A M"
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        label.textAlignment = .center
        return label
    }()
    private let emailTextField = AuthenticationTextField(placeholder: "Email")
    private let passwordTextField = AuthenticationTextField(placeholder: "Password", isSecureField: true)
    private let loginButton = AuthenticationButton(labelText: "Login")
    private let dontHaveAccountButton = AuthenticationSwitchButton(firstLabelText: "Don't have an account?", secondLabelText: "Sign Up")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureActions()
    }

    // MARK: - Actions

    @objc private func handleShowSignUp() {
        let controller = SignUpViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func handleLogin() {
    }

    @objc private func formValidation() {
        if emailTextField.hasText, passwordTextField.hasText {
            loginButton.isEnabled = true
            loginButton.alpha = 1
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        }
    }

    // MARK: - Helpers

    private func configureUI() {
        configureGradientLayer()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 150)
        view.addSubview(logoLabel)
        logoLabel.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 60)
        configureStackView()
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
    }

    private func configureStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoLabel.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingTop: 40,
                         paddingLeft: 40,
                         paddingRight: 40,
                         height: 140)
    }

    private func configureActions() {
        emailTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
    }
}
