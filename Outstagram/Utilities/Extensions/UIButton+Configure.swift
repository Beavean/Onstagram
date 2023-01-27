//
//  UIButton+Configure.swift
//  Outstagram
//
//  Created by Beavean on 20.01.2023.
//

import UIKit

extension UIButton {
    func configure(didFollow: Bool) {
        if didFollow {
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white

        } else {
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = .systemBlue
        }
    }
}
