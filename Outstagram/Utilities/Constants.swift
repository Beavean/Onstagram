//
//  Constants.swift
//  Outstagram
//
//  Created by Beavean on 13.01.2023.
//

import FirebaseStorage
import FirebaseDatabase

enum FBConstants {
    enum DBReferences {
        static let databaseReference = Database.database().reference()
        static let profileImages = "profile_images"
        static let users = databaseReference.child("users")
        static let userFollowers = databaseReference.child("user-followers")
        static let userFollowing = databaseReference.child("user-following")
        static let notifications = databaseReference.child("notifications")
        static let userPosts = databaseReference.child("user-posts")
        static let userFeed = databaseReference.child("user-feed")
        static let postLikes = databaseReference.child("post-likes")
        static let userLikes = databaseReference.child("user-likes")
        static let posts = databaseReference.child("posts")
        static let comments = databaseReference.child("comments")
        static let hashtagPost = databaseReference.child("hashtag-post")
        static let messages = databaseReference.child("messages")
        static let userMessages = databaseReference.child("user-messages")
        static let userMessageNotifications = databaseReference.child("user-message-notifications")
    }

    enum StorageReferences {
        static let storageReference = Storage.storage().reference()
        static let postImages = storageReference.child("post_images")
        static let messageImages = storageReference.child("message_images")
        static let messageVideos = storageReference.child("video_messages")

    }

    enum Values {
        static let follow = 2
        static let comment = 1
        static let like = 0
        static let commentMention = 3
        static let postMention = 4
    }
}
