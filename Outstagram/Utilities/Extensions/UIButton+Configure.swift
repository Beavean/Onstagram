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
            setTitle("Following", for: .normal)
            setTitleColor(.black, for: .normal)
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.lightGray.cgColor
            backgroundColor = .white

        } else {
            setTitle("Follow", for: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
            backgroundColor = .systemBlue
        }
    }
}
