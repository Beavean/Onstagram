//
//  MessageInputAccessoryView.swift
//  Outstagram
//
//  Created by Beavean on 08.02.2023.
//

import UIKit

protocol MessageInputAccessoryViewDelegate: AnyObject {
    func handleUploadMessage(message: String)
    func handleSelectImage()
}

final class MessageInputAccessoryView: UIView {
    // MARK: - Properties

    weak var delegate: MessageInputAccessoryViewDelegate?

    let messageInputTextView: MessageInputTextView = {
        let textView = MessageInputTextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        return textView
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadMessage), for: .touchUpInside)
        return button
    }()

    private let uploadImageIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "rectangle.stack.badge.plus")
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, right: rightAnchor, paddingRight: 8, width: 50, height: 50)
        addSubview(uploadImageIcon)
        uploadImageIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImage)))
        uploadImageIcon.isUserInteractionEnabled = true
        uploadImageIcon.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 8, width: 44, height: 44)
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor,
                                    left: uploadImageIcon.rightAnchor,
                                    bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: sendButton.leftAnchor,
                                    paddingTop: 8,
                                    paddingLeft: 4,
                                    paddingRight: 8)
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clearMessageTextView() {
        messageInputTextView.placeholderLabel.isHidden = false
        messageInputTextView.text = nil
    }

    // MARK: - Handlers

    @objc func handleUploadMessage() {
        guard let message = messageInputTextView.text else { return }
        delegate?.handleUploadMessage(message: message)
    }

    @objc func handleSelectImage() {
        delegate?.handleSelectImage()
    }
}
