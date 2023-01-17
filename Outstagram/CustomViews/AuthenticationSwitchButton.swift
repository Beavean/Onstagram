//
//  AuthenticationSwitchButton.swift
//  Outstagram
//
//  Created by Beavean on 12.01.2023.
//

import UIKit

final class AuthenticationSwitchButton: UIButton {

    init(firstLabelText: String, secondLabelText: String) {
        super.init(frame: .zero)
        let mainAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedTitle = NSMutableAttributedString(string: firstLabelText + " ", attributes: mainAttributes)
        let secondaryAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        attributedTitle.append(NSAttributedString(string: secondLabelText, attributes: secondaryAttributes))
        setAttributedTitle(attributedTitle, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
