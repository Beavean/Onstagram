//
//  NotificationsViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

final class NotificationsViewController: UITableViewController, NotificationCellDelegate {

    // MARK: - Properties

    private var timer: Timer?
    var notifications = [Notification]()
    private var refresher = UIRefreshControl()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .clear
        navigationItem.title = "Notifications"
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)
        fetchNotifications()
        configureRefreshControl()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifier, for: indexPath) as? NotificationCell
        else { return UITableViewCell() }
        let notification = notifications[indexPath.row]
        cell.notification = notification
        if notification.notificationType == .comment {
            if let commentText = notification.commentText {
                cell.configureNotificationLabel(withCommentText: commentText)
            }
        }
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    // MARK: - NotificationCellDelegate

    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        if user.isFollowed {
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }

    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        guard let notification = cell.notification else { return }
        if notification.notificationType == .comment {
            let commentController = CommentaryViewController(collectionViewLayout: UICollectionViewFlowLayout())
            commentController.post = post
            navigationController?.pushViewController(commentController, animated: true)
        } else {
            let feedController = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
            feedController.viewSinglePost = true
            feedController.post = post
            navigationController?.pushViewController(feedController, animated: true)
        }
    }

    // MARK: - Handlers

    @objc private func handleRefresh() {
        self.notifications.removeAll()
        self.tableView.reloadData()
        fetchNotifications()
        refresher.endRefreshing()
    }

    @objc private func handleSortNotifications() {
        self.notifications.sort { $0.creationDate > $1.creationDate }
        self.tableView.reloadData()
    }

    func handleReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                          target: self,
                                          selector: #selector(handleSortNotifications),
                                          userInfo: nil,
                                          repeats: false)
    }

    func configureRefreshControl() {
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refresher
    }

    // MARK: - API

    func getCommentData(forNotification notification: Notification) {
        guard let postId = notification.postId else { return }
        guard let commentId = notification.commentId else { return }
        FBConstants.DBReferences.comments.child(postId).child(commentId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject],
                  let commentText = dictionary["commentText"] as? String
            else { return }
            notification.commentText = commentText
        }
    }

    func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FBConstants.DBReferences.notifications.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.forEach { snapshot in
                let notificationId = snapshot.key
                guard let dictionary = snapshot.value as? [String: AnyObject],
                      let uid = dictionary["uid"] as? String
                else { return }
                Database.fetchUser(with: uid) { [weak self] user in
                    if let postId = dictionary["postId"] as? String {
                        Database.fetchPost(with: postId) { post in
                            let notification = Notification(user: user, post: post, dictionary: dictionary)
                            if notification.notificationType == .comment {
                                self?.getCommentData(forNotification: notification)
                            }
                            self?.notifications.append(notification)
                            self?.handleReloadTable()
                        }
                    } else {
                        let notification = Notification(user: user, dictionary: dictionary)
                        self?.notifications.append(notification)
                        self?.handleReloadTable()
                    }
                }
                FBConstants.DBReferences.notifications.child(currentUid).child(notificationId).child("checked").setValue(1)
            }
        }
    }
}
