//
//  UserProfileHeader.swift
//  Outstagram
//
//  Created by Beavean on 15.01.2023.
//

import UIKit
import FirebaseAuth

protocol UserProfileHeaderDelegate: AnyObject {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

final class UserProfileHeader: UICollectionViewCell {

    // MARK: - UI Elements

    private let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    lazy var postsLabel = createProfileLabel(title: "0", subTitle: "posts", selector: nil)
    lazy var followersLabel = createProfileLabel(title: "0", subTitle: "followers", selector: #selector(handleFollowersTapped))
    lazy var followingLabel = createProfileLabel(title: "0", subTitle: "following", selector: #selector(handleFollowingTapped))

    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
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
        let image = UIImage(systemName: "squareshape.split.3x3")
        button.setImage(image, for: .normal)
        return button
    }()

    private let listButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "rectangle.grid.1x2")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()

    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "bookmark")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: UserProfileHeader.self)
    weak var delegate: UserProfileHeaderDelegate?
    var user: User? {
        didSet {
            let fullName = user?.name
            nameLabel.text = fullName
            profileImageView.loadImage(with: user?.profileImageUrl)
            configureEditProfileFollowButton()
            setUserStats(for: user)
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 12, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
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
        delegate?.handleFollowersTapped(for: self)
    }

    @objc private func handleFollowingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }

    @objc private func handleEditProfileFollow() {
        delegate?.handleEditFollowTapped(for: self)
    }

    func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
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
        stackView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }

    private func configureUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor,
                         left: profileImageView.rightAnchor,
                         right: rightAnchor, paddingTop: 12,
                         paddingLeft: 12,
                         paddingRight: 12,
                         height: 50)
    }

    private func configureEditProfileFollowButton() {
        guard let currentUid = Auth.auth().currentUser?.uid, let user else { return }
        if currentUid == user.uid {
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        } else {
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = .systemBlue
            user.checkIfUserIsFollowed { [weak self] followed in
                self?.editProfileFollowButton.setTitle(followed ? "Following" : "Follow", for: .normal)
            }
        }
    }

    private func createProfileLabel(title: String, subTitle: String, selector: Selector?) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: title + "\n",
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: subTitle,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                              NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        if let selector {
            let followTap = UITapGestureRecognizer(target: self, action: selector)
            followTap.numberOfTapsRequired = 1
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(followTap)
        }
        return label
    }
}
