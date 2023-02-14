//
//  CommentaryCell.swift
//  Outstagram
//
//  Created by Beavean on 31.01.2023.
//

import UIKit
import ActiveLabel

final class CommentaryCell: UICollectionViewCell {

    // MARK: - UI Elements

    private let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    let commentLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: CommentaryCell.self)
    var comment: Commentary? {
        didSet {
            configureWithComment()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 8, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        addSubview(commentLabel)
        commentLabel.anchor(top: topAnchor,
                            left: profileImageView.rightAnchor,
                            bottom: bottomAnchor,
                            right: rightAnchor,
                            paddingTop: 4,
                            paddingLeft: 4,
                            paddingBottom: 4,
                            paddingRight: 4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    private func configureCommentLabel() {
        guard let comment = self.comment,
              let user = comment.user,
              let username = user.username,
              let commentText = comment.commentText
        else { return }
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        commentLabel.enabledTypes = [.hashtag, .mention, .url, customType]
        commentLabel.configureLinkAttribute = { type, receivedAttributes, _ in
            var attributes = receivedAttributes
            switch type {
            case .custom:
                attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return attributes
        }
        commentLabel.customize { label in
            label.text = "\(username) \(commentText)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.numberOfLines = 0
        }
    }

    private func configureWithComment() {
        guard let user = comment?.user,
              let profileImageUrl = user.profileImageUrl
        else { return }
        profileImageView.loadImage(with: profileImageUrl)
        configureCommentLabel()
    }

    private func getCommentTimeStamp() -> String? {
        guard let comment = self.comment else { return nil }
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        return dateFormatter.string(from: comment.creationDate, to: now)
    }
}
