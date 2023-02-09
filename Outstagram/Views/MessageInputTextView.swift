//
//  MessageInputTextView.swift
//  Outstagram
//
//  Created by Beavean on 08.02.2023.
//

import UIKit

final class MessageInputTextView: UITextView {

    // MARK: - UI Elements

    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter message.."
        label.textColor = .lightGray
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInputTextChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
        addSubview(placeholderLabel)
        placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handlers

    @objc private func handleInputTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
