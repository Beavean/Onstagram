//
//  SearchUserCell.swift
//  Outstagram
//
//  Created by Beavean on 18.01.2023.
//

import UIKit

final class SearchUserCell: UITableViewCell {
    // MARK: - Properties

    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl,
                  let username = user?.username,
                  let fullName = user?.name
            else { return }
            profileImageView.loadImage(with: profileImageUrl)
            textLabel?.text = username
            detailTextLabel?.text = fullName
        }
    }

    private let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: SearchUserCell.self)

    // MARK: - Lifecycle

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 8, width: 48, height: 48)
        profileImageView.centerY(inView: self)
        profileImageView.layer.cornerRadius = 48 / 2
        textLabel?.text = "Username"
        detailTextLabel?.text = "Full name"
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68,
                                  y: textLabel!.frame.origin.y - 2,
                                  width: (textLabel?.frame.width)!,
                                  height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.frame = CGRect(x: 68,
                                        y: detailTextLabel!.frame.origin.y,
                                        width: frame.width - 108,
                                        height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
