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

    var posts = [Post]()
    var currentKey: String?
    var user: User? {
        didSet { collectionView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fetchCurrentUserData()
        configureRefreshControl()
        fetchPosts()
    }

    // MARK: - Helpers

    private func configure() {
        collectionView.register(UserPostCell.self, forCellWithReuseIdentifier: UserPostCell.reuseIdentifier)
        collectionView.register(UserProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: UserProfileHeader.reuseIdentifier)
        collectionView.backgroundColor = .white
    }

    // MARK: - Handlers

    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }

    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }

    // MARK: - API

    func fetchPosts() {
        var uid: String!
        if let user = self.user {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }
        if currentKey == nil {
            FBConstants.DBReferences.userPosts.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value) { [weak self] snapshot in
                self?.collectionView?.refreshControl?.endRefreshing()
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    self?.fetchPost(withPostId: postId)
                }
                self?.currentKey = first.key
            }
        } else {
            FBConstants.DBReferences.userPosts
                .child(uid)
                .queryOrderedByKey()
                .queryEnding(atValue: self.currentKey)
                .queryLimited(toLast: 7)
                .observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                }
                self.currentKey = first.key
            }
        }
    }

    func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { post in
            self.posts.append(post)
            self.posts.sort { (firstPost, secondPost) -> Bool in
                return firstPost.creationDate > secondPost.creationDate
            }
            self.collectionView?.reloadData()
        }
    }

    private func fetchCurrentUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid, user == nil else { return }
        FBConstants.DBReferences.users.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot, _ in
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
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 9 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: UserProfileHeader.reuseIdentifier,
                                                                           for: indexPath) as? UserProfileHeader
        else { return UICollectionReusableView() }
        header.delegate = self
        header.user = self.user
        navigationItem.title = user?.username
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserPostCell.reuseIdentifier,
                                                            for: indexPath) as? UserPostCell
        else { return UICollectionViewCell() }
        cell.post = posts[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.userProfileController = self
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

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
        FBConstants.DBReferences.userFollowers.child(uid).observe(.value) { snapshot in
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

        FBConstants.DBReferences.userFollowing.child(uid).observe(.value) { snapshot in
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

        FBConstants.DBReferences.userPosts.child(uid).observeSingleEvent(of: .value) { snapshot in
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
