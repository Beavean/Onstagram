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

    private let logoContainerView: UIImageView = {
        let logoImageView = UIImageView(image: UIImage(systemName: "camera"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .white
        logoImageView.setDimensions(height: 150, width: 150)
        return logoImageView
    }()

    private let emailTextField = CustomTextField(placeholder: "Email")
    private let passwordTextField = CustomTextField(placeholder: "Password", isSecureField: true)

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.5
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    }()

    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let mainAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: mainAttributes)
        let secondaryAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: secondaryAttributes))
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()

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
        stackView.anchor(top: logoContainerView.bottomAnchor,
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
