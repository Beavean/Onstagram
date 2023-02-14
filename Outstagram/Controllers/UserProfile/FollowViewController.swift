//
//  FollowViewController.swift
//  Outstagram
//
//  Created by Beavean on 20.01.2023.
//

import UIKit
import FirebaseDatabase

final class FollowLikeViewController: UITableViewController {

    // MARK: - Properties

    enum ViewingMode: Int {
        case following = 0
        case followers = 1
        case likes = 2
    }

    private var followCurrentKey: String?
    private var likeCurrentKey: String?
    var postId: String?
    private var users = [User]()
    var viewingMode: ViewingMode!
    var uid: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: FollowLikeCell.reuseIdentifier)
        configureNavigationTitle()
        fetchUsers()
        tableView.separatorColor = .clear
    }

    // MARK: - Handlers

    private func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }
        switch viewingMode {
        case .followers: navigationItem.title = "Followers"
        case .following: navigationItem.title = "Following"
        case .likes: navigationItem.title = "Likes"
        }
    }

    // MARK: - API

    private func fetchUser(withUid uid: String) {
        Database.fetchUser(with: uid) { [weak self] user in
            self?.users.append(user)
            self?.tableView.reloadData()
        }
    }

    private func fetchUsers() {
        guard let databaseReference = getDatabaseReference(), let viewingMode = self.viewingMode else { return }
        switch viewingMode {
        case .followers, .following:
            guard let uid = self.uid else { return }
            if followCurrentKey == nil {
                getFollowCurrentKey(reference: databaseReference, uid: uid)
            } else {
                setFollowCurrentKey(reference: databaseReference, uid: uid)
            }
        case .likes:
            guard let postId = self.postId else { return }
            if likeCurrentKey == nil {
                getLikeCurrentKey(reference: databaseReference, postId: postId)
            } else {
                setLikeCurrentKey(reference: databaseReference, postId: postId)
            }
        }
    }

    private func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil }
        switch viewingMode {
        case .followers:
            return FBConstants.DBReferences.userFollowers
        case .following:
            return FBConstants.DBReferences.userFollowing
        case .likes:
            return FBConstants.DBReferences.postLikes
        }
    }

    private func getFollowCurrentKey(reference: DatabaseReference, uid: String) {
        reference.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = snapshot.children.allObjects as? [DataSnapshot]
            else { return }
            allObjects.forEach { snapshot in
                let followUid = snapshot.key
                self?.fetchUser(withUid: followUid)
            }
            self?.followCurrentKey = first.key
        }
    }

    private func setFollowCurrentKey(reference: DatabaseReference, uid: String) {
        reference.child(uid)
            .queryOrderedByKey()
            .queryEnding(atValue: self.followCurrentKey)
            .queryLimited(toLast: 5)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
                allObjects.forEach { snapshot in
                    let followUid = snapshot.key
                    if followUid != self?.followCurrentKey {
                        self?.fetchUser(withUid: followUid)
                    }
                }
                self?.followCurrentKey = first.key
            }
    }

    private func getLikeCurrentKey(reference: DatabaseReference, postId: String) {
        reference.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = snapshot.children.allObjects as? [DataSnapshot]
            else { return }
            allObjects.forEach { snapshot in
                let likeUid = snapshot.key
                self?.fetchUser(withUid: likeUid)
            }
            self?.likeCurrentKey = first.key
        }
    }

    private func setLikeCurrentKey(reference: DatabaseReference, postId: String) {
        reference.child(postId)
            .queryOrderedByKey()
            .queryEnding(atValue: self.likeCurrentKey)
            .queryLimited(toLast: 5)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
                allObjects.forEach { snapshot in
                    let likeUid = snapshot.key
                    if likeUid != self?.likeCurrentKey {
                        self?.fetchUser(withUid: likeUid)
                    }
                }
                self?.likeCurrentKey = first.key
            }
    }
}

// MARK: - UITableView

extension FollowLikeViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowLikeCell.reuseIdentifier,
                                                       for: indexPath) as? FollowLikeCell
        else { return UITableViewCell() }
        cell.delegate = self
        cell.user = users[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}

// MARK: - FollowCellDelegate

extension FollowLikeViewController: FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell) {
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = .systemBlue
        } else {
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }
}
