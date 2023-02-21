//
//  MessageCell.swift
//  Outstagram
//
//  Created by Beavean on 07.02.2023.
//

import FirebaseAuth
import UIKit

protocol MessageCellDelegate: AnyObject {
    func configureUserData(for cell: MessageCell)
}

final class MessageCell: UITableViewCell {
    // MARK: - UI Elements

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.text = "2h"
        return label
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: MessageCell.self)
    weak var delegate: MessageCellDelegate?
    var message: Message? {
        didSet {
            configureWithMessage()
        }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingTop: 4, paddingLeft: 8)
        addSubview(messageTextLabel)
        messageTextLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 6, paddingLeft: 8)

        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 20, paddingRight: 12)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    private func configureTimestamp(forMessage message: Message) {
        if let seconds = message.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            timestampLabel.text = dateFormatter.string(from: seconds)
        }
    }

    private func configureWithMessage() {
        guard let message = message else { return }
        guard let messageText = message.messageText else { return }
        guard let read = message.read else { return }
        if !read && message.fromId != Auth.auth().currentUser?.uid {
            messageTextLabel.font = UIFont.boldSystemFont(ofSize: 12)
        } else {
            messageTextLabel.font = UIFont.systemFont(ofSize: 12)
        }
        messageTextLabel.text = messageText
        configureTimestamp(forMessage: message)
        delegate?.configureUserData(for: self)
    }
}
