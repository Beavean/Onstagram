//
//  FeedViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import ActiveLabel
import FirebaseAuth
import FirebaseDatabase

final class FeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: UserProfileViewController?
    // TODO: messageNotificationView

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: K.UI.cellIdentifier)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        configureNavigationBar()
        if !viewSinglePost {
            fetchPosts()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUnreadMessageCount()
    }

    // MARK: - UICollectionViewFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: width, height: height)
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.UI.cellIdentifier, for: indexPath) as? FeedCell
        else { return UICollectionViewCell() }
        cell.delegate = self
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.item]
        }
        handleHashtagTapped(forCell: cell)
        handleUsernameLabelTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        return cell
    }

    // MARK: - Handlers

    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }

    @objc func handleShowMessages() {
        // TODO: Messages
    }

    func handleHashtagTapped(forCell cell: FeedCell) {
        // TODO: handleHashtagTapped
    }

    func handleMentionTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleMentionTap { username in
            self.getMentionedUser(withUsername: username)
        }
    }

    func handleUsernameLabelTapped(forCell cell: FeedCell) {
        guard let user = cell.post?.user,
              let username = user.username
        else { return }
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        cell.captionLabel.handleCustomTap(for: customType) { _ in
            let userProfileController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }
    }

    func configureNavigationBar() {
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
            let image = UIImage(systemName: "paperplane")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleShowMessages))
        }
        self.navigationItem.title = "Feed"
    }

    func setUnreadMessageCount() {
        // TODO: setUnreadMessageCount
    }

    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch {
                print("Failed to sign out")
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - API

    func setUserFCMToken() {
       // TODO: setUserFCMToken
    }

    func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        if currentKey == nil {
            K.FB.userFeedReference.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                self.collectionView?.refreshControl?.endRefreshing()
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
            }
        } else {
            K.FB.userFeedReference
                .child(currentUid)
                .queryOrderedByKey()
                .queryEnding(atValue: self.currentKey)
                .queryLimited(toLast: 6)
                .observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
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
        Database.fetchPost(with: postId) { (post) in
            self.posts.append(post)
            self.posts.sort { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            }
            self.collectionView?.reloadData()
        }
    }

    func getUnreadMessageCount(withCompletion completion: @escaping(Int) -> Void) {
        // TODO: getUnreadMessageCount
    }
}

extension FeedViewController: FeedCellDelegate {

    func handleUsernameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    func handleOptionsTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        if post.ownerUid == Auth.auth().currentUser?.uid {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive) { _ in
                post.deletePost()
                if !self.viewSinglePost {
                    self.handleRefresh()
                } else {
                    if let userProfileController = self.userProfileController {
                        _ = self.navigationController?.popViewController(animated: true)
                        userProfileController.handleRefresh()
                    }
                }
            })

            alertController.addAction(UIAlertAction(title: "Edit Post", style: .default) { _ in
                let uploadPostController = UploadPostViewController()
                let navigationController = UINavigationController(rootViewController: uploadPostController)
                uploadPostController.postToEdit = post
                uploadPostController.uploadAction = UploadPostViewController.UploadAction(index: 1)
                self.present(navigationController, animated: true, completion: nil)
            })

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        guard let post = cell.post else { return }
        if post.didLike {
            if !isDoubleTap {
                post.adjustLikes(addLike: false) { likes in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        } else {
            post.adjustLikes(addLike: true) { likes in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
    }

    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post,
              let postId = post.postId else { return }
        let followLikeVC = FollowLikeViewController()
        followLikeVC.viewingMode = FollowLikeViewController.ViewingMode(rawValue: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }

    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post,
              let postId = post.postId,
              let currentUid = Auth.auth().currentUser?.uid else { return }
        K.FB.userLikesReference.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                post.didLike = false
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
    }

    func configureCommentIndicatorView(for cell: FeedCell) {
        guard let post = cell.post,
              let postId = post.postId else { return }
        K.FB.commentReference.child(postId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                cell.addCommentIndicatorView(toStackView: cell.stackView)
            } else {
                cell.commentIndicatorView.isHidden = true
            }
        }
    }

    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentVC = CommentaryViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
}
