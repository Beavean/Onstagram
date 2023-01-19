//
//  User.swift
//  Outstagram
//
//  Created by Beavean on 17.01.2023.
//

import Foundation
import FirebaseAuth

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
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = uid else { return }
        self.isFollowed = true
        K.FB.userFollowingRef.child(currentUid).updateChildValues([uid: 1])
        K.FB.userFollowersRef.child(uid).updateChildValues([currentUid: 1])
        uploadFollowNotificationToServer()
        K.FB.userPostsRef.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            K.FB.userFeedRef.child(currentUid).updateChildValues([postId: 1])
        }
    }

    private func uploadFollowNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": K.Values.followIntValue] as [String: Any]
        K.FB.notificationsReference.child(self.uid).childByAutoId().updateChildValues(values)
    }
}
