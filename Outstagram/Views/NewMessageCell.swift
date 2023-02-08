//
//  NewMessageCell.swift
//  Outstagram
//
//  Created by Beavean on 07.02.2023.
//

import UIKit

final class NewMessageCell: UITableViewCell {

    // MARK: - Properties
    static let reuseIdentifier = String(describing: NewMessageCell.self)
    weak var delegate: MessageCellDelegate?
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

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textLabel?.text = "Username"
        detailTextLabel?.text = "Full Name"
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: (textLabel!.frame.height))
        detailTextLabel?.frame = CGRect(x: 68,
                                        y: detailTextLabel!.frame.origin.y + 2,
                                        width: self.frame.width - 108,
                                        height: (detailTextLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
