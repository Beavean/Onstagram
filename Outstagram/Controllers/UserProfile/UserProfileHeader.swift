//
//  UserProfileHeader.swift
//  Outstagram
//
//  Created by Beavean on 15.01.2023.
//

import UIKit
import FirebaseAuth

class UserProfileHeader: UICollectionViewCell {

    // MARK: - UI Elements

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    private let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                              NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()

    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                              NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()

    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes:
                                                    [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                     NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()

    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()

    private let gridButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart")
        button.setImage(image, for: .normal)
        return button
    }()

    private let listButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()

    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 16, paddingLeft: 12, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2

        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, paddingTop: 12, paddingLeft: 12)

        configureUserStats()

        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor,
                                       left: postsLabel.leftAnchor,
                                       right: self.rightAnchor,
                                       paddingTop: 4,
                                       paddingLeft: 8,
                                       paddingRight: 12,
                                       height: 30)
        configureBottomToolBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    @objc private func handleFollowersTapped() {
    }

    @objc private func handleFollowingTapped() {
    }

    @objc private func handleEditProfileFollow() {
    }

    // MARK: - Helpers

    private func configureBottomToolBar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray

        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray

        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)

        stackView.anchor(left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }

    private func configureUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.anchor(top: self.topAnchor,
                         left: profileImageView.rightAnchor,
                         right: rightAnchor, paddingTop: 12,
                         paddingLeft: 12,
                         paddingRight: 12,
                         height: 50)
    }
}
