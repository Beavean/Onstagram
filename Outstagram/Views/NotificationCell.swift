//
//  NotificationCell.swift
//  Outstagram
//
//  Created by Beavean on 02.02.2023.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

final class NotificationCell: UITableViewCell {

  // MARK: - UI Elements

    private let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()

    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()

    private lazy var postImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(postTap)
        return imageView
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: NotificationCell.self)
    weak var delegate: NotificationCellDelegate?
    var notification: Notification? {
        didSet {
            configureWithNotification()
        }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 8, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    @objc private func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }

    @objc private func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }

    func configureNotificationLabel(withCommentText commentText: String?) {
        guard let notification = self.notification,
              let user = notification.user,
              let username = user.username,
              let notificationDate = getNotificationTimeStamp()
        else { return }
        var notificationMessage: String!
        if let commentText = commentText {
            if notification.notificationType != .commentMention {
                notificationMessage = "\(notification.notificationType.description): \(commentText)"
            }
        } else {
            notificationMessage = notification.notificationType.description
        }
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(notificationDate)",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                    NSAttributedString.Key.foregroundColor: UIColor.lightGray
                                                 ]))
        notificationLabel.attributedText = attributedText
    }

    private func configureWithNotification() {
        guard let user = notification?.user, let profileImageUrl = user.profileImageUrl else { return }
        configureNotificationType()
        configureNotificationLabel(withCommentText: nil)
        profileImageView.loadImage(with: profileImageUrl)
        if let post = notification?.post {
            postImageView.loadImage(with: post.imageUrl)
        }
    }

    private func configureNotificationType() {
        guard let notification = self.notification,
              let user = notification.user
        else { return }
        if notification.notificationType != .follow {
            addSubview(postImageView)
            postImageView.anchor(right: rightAnchor, paddingRight: 8, width: 40, height: 40)
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.isHidden = true
            postImageView.isHidden = false
        } else {
            addSubview(followButton)
            followButton.anchor(right: rightAnchor, paddingRight: 8, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.layer.cornerRadius = 3
            followButton.isHidden = false
            postImageView.isHidden = true
            user.checkIfUserIsFollowed { followed in
                if followed {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = .systemBlue
                }
            }
        }
        addSubview(notificationLabel)
        notificationLabel.anchor(left: profileImageView.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 108)
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    private func getNotificationTimeStamp() -> String? {
        guard let notification = self.notification else { return nil }
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        return dateFormatter.string(from: notification.creationDate, to: now)
    }
}
