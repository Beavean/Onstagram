//
//  FollowLikeCell.swift
//  Outstagram
//
//  Created by Beavean on 20.01.2023.
//

import UIKit
import FirebaseAuth

protocol FollowCellDelegate: AnyObject {
    func handleFollowTapped(for cell: FollowLikeCell)
}

final class FollowLikeCell: UITableViewCell {

    // MARK: - UI Elements

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties

    static let reuseIdentifier = String(describing: FollowLikeCell.self)
    weak var delegate: FollowCellDelegate?
    var user: User? {
        didSet { configureCellWithUser() }
    }

    // MARK: - Handlers

    @objc private func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 8, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2

        addSubview(followButton)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3

        textLabel?.text = "Username"
        detailTextLabel?.text = "Full name"
        self.selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.frame = CGRect(x: 68,
                                        y: detailTextLabel!.frame.origin.y,
                                        width: self.frame.width - 108,
                                        height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCellWithUser() {
        guard let profileImageUrl = user?.profileImageUrl,
              let username = user?.username,
              let fullName = user?.name else { return }
        profileImageView.loadImage(with: profileImageUrl)
        self.textLabel?.text = username
        self.detailTextLabel?.text = fullName
        if user?.uid == Auth.auth().currentUser?.uid {
            followButton.isHidden = true
        }
        user?.checkIfUserIsFollowed { [weak self] followed in
            if followed {
                self?.followButton.configure(didFollow: true)
            } else {
                self?.followButton.configure(didFollow: false)
            }
        }
    }
}
