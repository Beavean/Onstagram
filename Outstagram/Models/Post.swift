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
            FBConstants.DBReferences.userLikes.child(currentUid).updateChildValues([postId: 1]) { [weak self] _, _ in
                self?.sendLikeNotificationToServer()
                guard let postId = self?.postId else { return }
                FBConstants.DBReferences.postLikes.child(postId).updateChildValues([currentUid: 1]) { _, _ in
                    self?.likes += 1
                    self?.didLike = true
                    FBConstants.DBReferences.posts.child(postId).child("likes").setValue(self?.likes)
                    guard let likes = self?.likes else { return }
                    completion(likes)
                }
            }
        } else {
            FBConstants.DBReferences.userLikes.child(currentUid).child(postId).observeSingleEvent(of: .value) { [weak self] snapshot in
                if let notificationID = snapshot.value as? String {
                    guard let ownerUid = self?.ownerUid else { return }
                    FBConstants.DBReferences.notifications.child(ownerUid).child(notificationID).removeValue { _, _ in
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
        FBConstants.DBReferences.userLikes.child(currentUid).child(self.postId).removeValue { [weak self] _, _ in
            guard let postId = self?.postId, var likes = self?.likes else { return }
            FBConstants.DBReferences.postLikes.child(postId).child(currentUid).removeValue { _, _  in
                guard likes > 0 else { return }
                likes -= 1
                self?.likes -= likes
                self?.didLike = false
                FBConstants.DBReferences.posts.child(postId).child("likes").setValue(likes)
                completion(likes)
            }
        }
    }

    func deletePost() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        FBConstants.DBReferences.userFollowers.child(currentUid).observe(.childAdded) { [weak self] snapshot in
            guard let postId = self?.postId else { return }
            let followerUid = snapshot.key
            FBConstants.DBReferences.userFeed.child(followerUid).child(postId).removeValue()
        }
        FBConstants.DBReferences.userFeed.child(currentUid).child(postId).removeValue()
        FBConstants.DBReferences.userPosts.child(currentUid).child(postId).removeValue()
        FBConstants.DBReferences.postLikes.child(postId).observe(.childAdded) { [weak self] snapshot in
            guard let postId = self?.postId, let ownerUid = self?.ownerUid else { return }
            let uid = snapshot.key
            FBConstants.DBReferences.userLikes.child(uid).child(postId).observeSingleEvent(of: .value) { snapshot in
                guard let notificationId = snapshot.value as? String else { return }
                FBConstants.DBReferences.notifications.child(ownerUid).child(notificationId).removeValue { _, _ in
                    FBConstants.DBReferences.postLikes.child(postId).removeValue()
                    FBConstants.DBReferences.userLikes.child(uid).child(postId).removeValue()
                }
            }
        }
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        for var word in words where word.hasPrefix("#") {
            word = word.trimmingCharacters(in: .punctuationCharacters)
            word = word.trimmingCharacters(in: .symbols)
            FBConstants.DBReferences.hashtagPost.child(word).child(postId).removeValue()
        }
        FBConstants.DBReferences.comments.child(postId).removeValue()
        FBConstants.DBReferences.posts.child(postId).removeValue()
    }

    func sendLikeNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        if currentUid != self.ownerUid {
            let values = ["checked": 0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": FBConstants.Values.like,
                          "postId": postId!] as [String: Any]
            let notificationRef = FBConstants.DBReferences.notifications.child(self.ownerUid).childByAutoId()
            notificationRef.updateChildValues(values) { [weak self] _, _ in
                guard let postId = self?.postId else { return }
                FBConstants.DBReferences.userLikes.child(currentUid).child(postId).setValue(notificationRef.key)
            }
        }
    }
}
