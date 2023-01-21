//
//  UserProfileViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

final class UserProfileViewController: UICollectionViewController {

    // MARK: - Properties

    var user: User? {
        didSet { collectionView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fetchCurrentUserData()
    }

    // MARK: - Helpers

    private func configure() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: K.UI.cellIdentifier)
        collectionView.register(UserProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: K.UI.headerIdentifier)
        collectionView.backgroundColor = .white
    }

    // MARK: - API

    private func fetchCurrentUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid, user == nil else { return }
        K.FB.usersReference.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot, _ in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self?.user = user
            self?.navigationItem.title = user.username
            self?.collectionView?.reloadData()
        }
    }
}

// MARK: UICollectionView

extension UserProfileViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: K.UI.headerIdentifier,
                                                                           for: indexPath) as? UserProfileHeader
        else { return UICollectionReusableView() }
        header.user = self.user
        header.delegate = self
        navigationItem.title = user?.username
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.UI.cellIdentifier, for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: view.frame.width, height: 200)
    }
}

// MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: UserProfileHeaderDelegate {

    func handleFollowersTapped(for header: UserProfileHeader) {
        let followViewController = FollowLikeViewController()
        followViewController.viewingMode = .followers
        followViewController.uid = user?.uid
        navigationController?.pushViewController(followViewController, animated: true)
    }

    func handleFollowingTapped(for header: UserProfileHeader) {
        let followViewController = FollowLikeViewController()
        followViewController.viewingMode = .following
        followViewController.uid = user?.uid
        navigationController?.pushViewController(followViewController, animated: true)
    }

    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }
        // FIXME: - Edit profile
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
        } else {
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }

    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else { return }
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        K.FB.userFollowersReference.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? [String: AnyObject] {
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n",
                                                           attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                  NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followersLabel.attributedText = attributedText
        }

        K.FB.userFollowingReference.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? [String: AnyObject] {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n",
                                                           attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                  NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followingLabel.attributedText = attributedText
        }

        K.FB.userPostsReference.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            let postCount = snapshot.count
            let attributedText = NSMutableAttributedString(string: "\(postCount)\n",
                                                           attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "posts",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                  NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.postsLabel.attributedText = attributedText
        }
    }
}
