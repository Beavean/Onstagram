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
    var messageNotificationView: MessageNotificationView = {
        let view = MessageNotificationView()
        return view
    }()

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
        let messagesController = MessagesController()
        self.messageNotificationView.isHidden = true
        navigationController?.pushViewController(messagesController, animated: true)
    }

    func handleHashtagTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleHashtagTap { hashtag in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
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
        if !viewSinglePost {
            getUnreadMessageCount { unreadMessageCount in
                guard unreadMessageCount != 0 else { return }
                self.navigationController?.navigationBar.addSubview(self.messageNotificationView)
                self.messageNotificationView.anchor(top: self.navigationController?.navigationBar.topAnchor,
                                                    right: self.navigationController?.navigationBar.rightAnchor,
                                                    paddingRight: 4,
                                                    width: 20,
                                                    height: 20)
                self.messageNotificationView.layer.cornerRadius = 20 / 2
                self.messageNotificationView.notificationLabel.text = "\(unreadMessageCount)"
            }
        }
    }

    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            } catch {
                print("Failed to sign out")
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    // MARK: - API

    private func setUserFCMToken() {
       // TODO: setUserFCMToken
    }

    private func fetchPosts() {
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

    private func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { post in
            self.posts.append(post)
            self.posts.sort { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            }
            self.collectionView?.reloadData()
        }
    }

    private func getUnreadMessageCount(withCompletion completion: @escaping(Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var unreadCount = 0
        K.FB.userMessagesReference.child(currentUid).observe(.childAdded) { snapshot in
            let uid = snapshot.key
            K.FB.userMessagesReference.child(currentUid).child(uid).observe(.childAdded) { snapshot in
                let messageId = snapshot.key
                K.FB.messagesReference.child(messageId).observeSingleEvent(of: .value) { snapshot in
                    guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                    let message = Message(dictionary: dictionary)
                    if message.fromId != currentUid {
                        if !message.read {
                            unreadCount += 1
                        }
                    }
                    completion(unreadCount)
                }
            }
        }
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
                self.present(navigationController, animated: true)
            })

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true)
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
