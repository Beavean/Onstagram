//
//  SelectPhotoCell.swift
//  Outstagram
//
//  Created by Beavean on 23.01.2023.
//

import UIKit

final class SelectPhotoCell: UICollectionViewCell {
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }

    static let reuseIdentifier = String(describing: SelectPhotoCell.self)

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
