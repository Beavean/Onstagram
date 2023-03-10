//
//  CommentaryViewController.swift
//  Outstagram
//
//  Created by Beavean on 31.01.2023.
//

import FirebaseAuth
import FirebaseDatabase
import UIKit

final class CommentaryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    var comments = [Commentary]()
    var post: Post?

    lazy var containerView: CommentaryInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containerView = CommentaryInputView(frame: frame)
        containerView.delegate = self
        return containerView
    }()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        configureCollectionView()
        fetchComments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override var inputAccessoryView: UIView? {
        return containerView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - UICollectionView

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentaryCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentaryCell.reuseIdentifier, for: indexPath) as? CommentaryCell
        else { return UICollectionViewCell() }
        handleHashtagTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        cell.comment = comments[indexPath.item]
        return cell
    }

    // MARK: - Handlers

    func handleHashtagTapped(forCell cell: CommentaryCell) {
        cell.commentLabel.handleHashtagTap { [weak self] hashtag in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag.lowercased()
            self?.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }

    func handleMentionTapped(forCell cell: CommentaryCell) {
        cell.commentLabel.handleMentionTap { [weak self] username in
            self?.getMentionedUser(withUsername: username)
        }
    }

    // MARK: - API

    func fetchComments() {
        guard let postId = post?.postId else { return }
        FBConstants.DBReferences.comments.child(postId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject], let uid = dictionary["uid"] as? String
            else { return }
            Database.fetchUser(with: uid) { [weak self] user in
                guard let self else { return }
                let comment = Commentary(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView?.reloadData()
            }
        }
    }

    func uploadCommentNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let postId = post?.postId,
              let uid = post?.user?.uid
        else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FBConstants.Values.comment,
                      "postId": postId] as [String: Any]
        if uid != currentUid {
            FBConstants.DBReferences.notifications.child(uid).childByAutoId().updateChildValues(values)
        }
    }

    // MARK: - Helpers

    private func configureCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(CommentaryCell.self, forCellWithReuseIdentifier: CommentaryCell.reuseIdentifier)
    }
}

// MARK: - CommentInputAccessoryViewDelegate

extension CommentaryViewController: CommentaryInputViewDelegate {
    func didSubmit(forComment comment: String) {
        guard let postId = post?.postId, let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = ["commentText": comment,
                      "creationDate": creationDate,
                      "uid": uid] as [String: Any]
        FBConstants.DBReferences.comments.child(postId).childByAutoId().updateChildValues(values) { [weak self] _, _ in
            self?.uploadCommentNotificationToServer()
            if comment.contains("@") {
                self?.uploadMentionNotification(forPostId: postId, withText: comment, isForComment: true)
            }
            self?.containerView.clearCommentTextView()
        }
    }
}
