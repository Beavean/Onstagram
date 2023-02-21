//
//  Authenticationswift
//  Outstagram
//
//  Created by Beavean on 11.01.2023.
//

import UIKit

final class AuthenticationButton: UIButton {
    init(labelText: String) {
        super.init(frame: .zero)
        alpha = 0.5
        setTitle(labelText, for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .orange
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        isEnabled = false
        layer.cornerRadius = 5
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
