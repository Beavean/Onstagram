//
//  AuthenticationImageView.swift
//  Outstagram
//
//  Created by Beavean on 12.01.2023.
//

import UIKit

final class AuthenticationImageView: UIImageView {

    override init(image: UIImage?) {
        super.init(frame: .zero)
        self.image = image
        contentMode = .scaleAspectFit
        tintColor = .white
        setDimensions(height: 150, width: 150)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
