//
//  FollowViewController.swift
//  Outstagram
//
//  Created by Beavean on 20.01.2023.
//

import UIKit

final class FollowLikeViewController: UITableViewController {

    // MARK: - Properties

    var followCurrentKey: String?
    var likeCurrentKey: String?

    enum ViewingMode: Int {
        case following = 0
        case followers = 1
        case likes = 2
    }

    var postId: String?
    var viewingMode: ViewingMode!
    var uid: String?
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
        fetchUsers()
        tableView.separatorColor = .clear
    }

    // MARK: - UITableView

   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.UI.followCellIdentifier,
                                                       for: indexPath) as? FollowLikeCell
        else { return UITableViewCell() }
        cell.delegate = self
        cell.user = users[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    // MARK: - FollowCellDelegate Protocol

    func handleFollowTapped(for cell: FollowLikeCell) {
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)

        } else {
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }

    // MARK: - Handlers

    func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }
        switch viewingMode {
        case .followers: navigationItem.title = "Followers"
        case .following: navigationItem.title = "Following"
        case .likes: navigationItem.title = "Likes"
        }
    }

    // MARK: - API

    func fetchUser(withUid uid: String) {
    }

    func fetchUsers() {
    }
}

extension FollowLikeViewController: FollowCellDelegate {
}
