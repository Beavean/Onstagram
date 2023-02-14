//
//  HashtagCell.swift
//  Outstagram
//
//  Created by Beavean on 13.02.2023.
//

import UIKit

final class HashtagCell: UICollectionViewCell {

    // MARK: - UI Elements

    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            postImageView.loadImage(with: imageUrl)
        }
    }

    let postImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    // MARK: - Properties

    static let reuseIdentifier = "HashtagCell"

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
