//
//  CommentInputAccessoryView.swift
//  Outstagram
//
//  Created by Beavean on 31.01.2023.
//

import UIKit

protocol CommentInputAccessoryViewDelegate: AnyObject {
    func didSubmit(forComment comment: String)
}

final class CommentInputAccessoryView: UIView {

    // MARK: - Properties

    weak var delegate: CommentInputAccessoryViewDelegate?

    private let commentTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        return textView
    }()

    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        autoresizingMask = .flexibleHeight

        backgroundColor = .white

        addSubview(postButton)
        postButton.anchor(top: topAnchor, right: rightAnchor, paddingRight: 8, width: 50, height: 50)

        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor,
                               left: leftAnchor,
                               bottom: safeAreaLayoutGuide.bottomAnchor,
                               right: postButton.leftAnchor,
                               paddingTop: 8,
                               paddingLeft: 8,
                               paddingRight: 8,
                               width: 0,
                               height: 0)

        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        addSubview(separatorView)
        separatorView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, width: 0, height: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }

    func clearCommentTextView() {
        commentTextView.placeholderLabel.isHidden = false
        commentTextView.text = nil
    }

    // MARK: - Handlers

    @objc func handleUploadComment() {
        guard let comment = commentTextView.text else { return }
        delegate?.didSubmit(forComment: comment)
    }
}
