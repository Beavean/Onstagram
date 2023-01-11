//
//  SignUpViewController.swift
//  Outstagram
//
//  Created by Beavean on 11.01.2023.
//

import UIKit

final class SignUpViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - UI Elements

    private lazy var profilePhotoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.badge.plus"))
        imageView.setDimensions(height: 150, width: 150)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()

    private let emailTextField = CustomTextField(placeholder: "Email")
    private let fullNameTextField = CustomTextField(placeholder: "Full Name")
    private let usernameTextField = CustomTextField(placeholder: "Username")
    private let passwordTextField = CustomTextField(placeholder: "Password", isSecureField: true)

    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.5
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    }()

    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let mainAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: mainAttributes)
        let secondaryAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: secondaryAttributes))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()

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
        configureViewComponents()
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
    }

    private func configureViewComponents() {
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
    }
}
