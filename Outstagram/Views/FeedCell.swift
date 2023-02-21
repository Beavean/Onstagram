//
//  FeedCell.swift
//  Outstagram
//
//  Created by Beavean on 26.01.2023.
//

import ActiveLabel
import FirebaseDatabase
import UIKit

protocol FeedCellDelegate: AnyObject {
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
    func configureCommentIndicatorView(for cell: FeedCell)
}

final class FeedCell: UICollectionViewCell {
    // MARK: - UI Elements

    private let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return button
    }()

    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()

    private lazy var postImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray

        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike))
        likeTap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(likeTap)

        return imageView
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()

    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .black
        return button
    }()

    private let savePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .black
        return button
    }()

    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "3 likes"
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        return label
    }()

    let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 0
        return label
    }()

    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = "2 DAYS AGO"
        return label
    }()

    let commentIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: FeedCell.self)
    weak var delegate: FeedCellDelegate?
    var stackView: UIStackView!
    var post: Post? {
        didSet {
            configureWithPost()
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        addSubview(usernameButton)
        usernameButton.anchor(left: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 8)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addSubview(optionsButton)
        optionsButton.anchor(right: rightAnchor, paddingRight: 8, width: 40, height: 40)
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        configureActionButtons()
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, paddingTop: -4, paddingLeft: 8, height: 16)
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8)
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    @objc private func handleUsernameTapped() {
        delegate?.handleUsernameTapped(for: self)
    }

    @objc private func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }

    @objc private func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    }

    @objc private func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }

    @objc private func handleShowLikes() {
        delegate?.handleShowLikes(for: self)
    }

    @objc private func handleDoubleTapToLike() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }

    private func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }

    private func configureCommentIndicatorView() {
        delegate?.configureCommentIndicatorView(for: self)
    }

    private func configurePostCaption(user _: User) {
        guard let post = post,
              let caption = post.caption,
              let username = post.user?.username
        else { return }
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        captionLabel.configureLinkAttribute = { type, defaultAttributes, _ in
            var attributes = defaultAttributes
            switch type {
            case .custom:
                attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return attributes
        }
        captionLabel.customize { label in
            label.text = "\(username) \(caption)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            captionLabel.numberOfLines = 2
        }
        postTimeLabel.text = post.creationDate.timeAgoToDisplay()
    }

    private func configureWithPost() {
        guard let ownerUid = post?.ownerUid,
              let imageUrl = post?.imageUrl,
              let likes = post?.likes else { return }
        Database.fetchUser(with: ownerUid) { [weak self] user in
            self?.profileImageView.loadImage(with: user.profileImageUrl)
            self?.usernameButton.setTitle(user.username, for: .normal)
            self?.configurePostCaption(user: user)
        }
        postImageView.loadImage(with: imageUrl)
        likesLabel.text = "\(likes) likes"
        configureLikeButton()
        configureCommentIndicatorView()
    }

    private func configureActionButtons() {
        stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, width: 120, height: 50)
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 8, width: 20, height: 24)
    }

    func addCommentIndicatorView(toStackView stackView: UIStackView) {
        commentIndicatorView.isHidden = false
        stackView.addSubview(commentIndicatorView)
        commentIndicatorView.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, paddingTop: 14, paddingLeft: 64, width: 10, height: 10)
        commentIndicatorView.layer.cornerRadius = 10 / 2
    }
}
