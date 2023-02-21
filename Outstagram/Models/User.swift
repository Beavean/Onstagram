//
//  User.swift
//  Outstagram
//
//  Created by Beavean on 17.01.2023.
//

import FirebaseAuth
import Foundation

final class User {
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    var isFollowed = false

    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }

    func follow() {
        guard let currentUid = Auth.auth().currentUser?.uid, let uid else { return }
        isFollowed = true
        FBConstants.DBReferences.userFollowing.child(currentUid).updateChildValues([uid: 1])
        FBConstants.DBReferences.userFollowers.child(uid).updateChildValues([currentUid: 1])
        uploadFollowNotificationToServer()
        FBConstants.DBReferences.userPosts.child(uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            FBConstants.DBReferences.userFeed.child(currentUid).updateChildValues([postId: 1])
        }
    }

    func unfollow() {
        guard let currentUid = Auth.auth().currentUser?.uid, let uid else { return }
        isFollowed = false
        FBConstants.DBReferences.userFollowing.child(currentUid).child(uid).removeValue()
        FBConstants.DBReferences.userFollowers.child(uid).child(currentUid).removeValue()
        FBConstants.DBReferences.userPosts.child(uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            FBConstants.DBReferences.userFeed.child(currentUid).child(postId).removeValue()
        }
    }

    func checkIfUserIsFollowed(completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FBConstants.DBReferences.userFollowing.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }

    private func uploadFollowNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FBConstants.Values.follow] as [String: Any]
        FBConstants.DBReferences.notifications.child(uid).childByAutoId().updateChildValues(values)
    }
}
