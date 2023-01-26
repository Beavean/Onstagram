//
//  Constants.swift
//  Outstagram
//
//  Created by Beavean on 13.01.2023.
//

import FirebaseStorage
import FirebaseDatabase

// swiftlint:disable type_name

enum K {

    enum FB {
        static let databaseReference = Database.database().reference()
        static let profileImageReference = "profile_images"
        static let usersReference = databaseReference.child("users")
        static let userFollowersReference = databaseReference.child("user-followers")
        static let userFollowingReference = databaseReference.child("user-following")
        static let notificationsReference = databaseReference.child("notifications")
        static let userPostsReference = databaseReference.child("user-posts")
        static let userFeedReference = databaseReference.child("user-feed")
        static let postLikesReference = databaseReference.child("post-likes")
        static let userLikesReference = databaseReference.child("user-likes")
        static let postsReference = databaseReference.child("posts")
        static let commentReference = databaseReference.child("comments")
        static let hashtagPostReference = databaseReference.child("hashtag-post")
    }

    enum FBSTORE {
        static let storageReference = Storage.storage().reference()
        static let storagePostImageReference = storageReference.child("post_images")
    }

    enum UI {
        static let cellIdentifier = "Cell"
        static let searchUserCellIdentifier = String(describing: SearchUserCell.self)
        static let followCellIdentifier = String(describing: FollowLikeCell.self)
        static let selectPhotoCellIdentifier = String(describing: SelectPhotoCell.self)
        static let selectPhotoHeaderIdentifier = String(describing: SelectPhotoHeader.self)
        static let userProfileHeaderIdentifier = String(describing: UserProfileHeader.self)
    }

    enum Values {
        static let followIntValue = 2
        static let likeIntValue = 0
        static let commentMentionIntValue = 3
        static let postMentionIntValue = 4
    }
}

// TODO: Rebuild utilities folder

// swiftlint:enable type_name
