//
//  SignUpViewController.swift
//  Outstagram
//
//  Created by Beavean on 11.01.2023.
//

import UIKit

final class SignUpViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - UI Elements

    private let profilePhotoImageView = AuthenticationImageView(image: UIImage(systemName: "person.crop.circle.badge.plus"))
    private let emailTextField = AuthenticationTextField(placeholder: "Email")
    private let fullNameTextField = AuthenticationTextField(placeholder: "Full Name")
    private let usernameTextField = AuthenticationTextField(placeholder: "Username")
    private let passwordTextField = AuthenticationTextField(placeholder: "Password", isSecureField: true)
    private let signUpButton = AuthenticationButton(labelText: "Sign Up")
    private let alreadyHaveAccountButton = AuthenticationSwitchButton(firstLabelText: "Already have an account?", secondLabelText: "Sign In")

    // MARK: - Properties

    var imageSelected = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureActions()
    }

    // MARK: - Actions

    @objc func handleSelectProfilePhoto() {
    }

    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }

    @objc func handleSignUp() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let fullName = fullNameTextField.text,
              let username = usernameTextField.text?.lowercased()
        else { return }

    }

    @objc func formValidation() {
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullNameTextField.hasText,
            usernameTextField.hasText,
            imageSelected else {
            signUpButton.isEnabled = false
            signUpButton.alpha = 0.5
            return
        }
        signUpButton.isEnabled = true
        signUpButton.alpha = 1
    }

    // MARK: - Helpers

    private func configureUI() {
        configureGradientLayer()
        view.addSubview(profilePhotoImageView)
        profilePhotoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 40, width: 140, height: 140)
        profilePhotoImageView.centerX(inView: view)
        configureStackView()
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
    }

    private func configureStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: profilePhotoImageView.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingTop: 24,
                         paddingLeft: 40,
                         paddingRight: 40,
                         height: 240)
    }

    private func configureActions() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfilePhoto))
        profilePhotoImageView.addGestureRecognizer(gesture)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
    }
}
