//
//  Post.swift
//  Outstagram
//
//  Created by Beavean on 25.01.2023.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

final class Post {

    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false

    init(postId: String!, user: User, dictionary: [String: AnyObject]) {
        self.postId = postId
        self.user = user
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }

    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        if addLike {
            K.FB.userLikesReference.child(currentUid).updateChildValues([postId: 1]) { [weak self] _, _ in
                self?.sendLikeNotificationToServer()
                guard let postId = self?.postId else { return }
                K.FB.postLikesReference.child(postId).updateChildValues([currentUid: 1]) { _, _ in
                    self?.likes += 1
                    self?.didLike = true
                    K.FB.postsReference.child(postId).child("likes").setValue(self?.likes)
                    guard let likes = self?.likes else { return }
                    completion(likes)
                }
            }
        } else {
            K.FB.userLikesReference.child(currentUid).child(postId).observeSingleEvent(of: .value) { [weak self] snapshot in
                if let notificationID = snapshot.value as? String {
                    guard let ownerUid = self?.ownerUid else { return }
                    K.FB.notificationsReference.child(ownerUid).child(notificationID).removeValue { _, _ in
                        self?.removeLike { likes in
                            completion(likes)
                        }
                    }
                } else {
                    self?.removeLike { likes in
                        completion(likes)
                    }
                }
            }
        }
    }

    func removeLike(withCompletion completion: @escaping (Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        K.FB.userLikesReference.child(currentUid).child(self.postId).removeValue { [weak self] _, _ in
            guard let postId = self?.postId, var likes = self?.likes else { return }
            K.FB.postLikesReference.child(postId).child(currentUid).removeValue { _, _  in
                guard likes > 0 else { return }
                likes -= 1
                self?.likes -= likes
                self?.didLike = false
                K.FB.postsReference.child(postId).child("likes").setValue(likes)
                completion(likes)
            }
        }
    }

    func deletePost() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        K.FB.userFollowersReference.child(currentUid).observe(.childAdded) { [weak self] snapshot in
            guard let postId = self?.postId else { return }
            let followerUid = snapshot.key
            K.FB.userFeedReference.child(followerUid).child(postId).removeValue()
        }
        K.FB.userFeedReference.child(currentUid).child(postId).removeValue()
        K.FB.userPostsReference.child(currentUid).child(postId).removeValue()
        K.FB.postLikesReference.child(postId).observe(.childAdded) { [weak self] snapshot in
            guard let postId = self?.postId, let ownerUid = self?.ownerUid else { return }
            let uid = snapshot.key
            K.FB.userLikesReference.child(uid).child(postId).observeSingleEvent(of: .value) { snapshot in
                guard let notificationId = snapshot.value as? String else { return }
                K.FB.notificationsReference.child(ownerUid).child(notificationId).removeValue { _, _ in
                    K.FB.postLikesReference.child(postId).removeValue()
                    K.FB.userLikesReference.child(uid).child(postId).removeValue()
                }
            }
        }
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        for var word in words where word.hasPrefix("#") {
            word = word.trimmingCharacters(in: .punctuationCharacters)
            word = word.trimmingCharacters(in: .symbols)
            K.FB.hashtagPostReference.child(word).child(postId).removeValue()
        }
        K.FB.commentReference.child(postId).removeValue()
        K.FB.postsReference.child(postId).removeValue()
    }

    func sendLikeNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        if currentUid != self.ownerUid {
            let values = ["checked": 0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": K.Values.likeIntValue,
                          "postId": postId!] as [String: Any]
            let notificationRef = K.FB.notificationsReference.child(self.ownerUid).childByAutoId()
            notificationRef.updateChildValues(values) { [weak self] _, _ in
                guard let postId = self?.postId else { return }
                K.FB.userLikesReference.child(currentUid).child(postId).setValue(notificationRef.key)
            }
        }
    }
}
