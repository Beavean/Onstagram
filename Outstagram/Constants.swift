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

    }

    enum Values {
        static let followIntValue = 2
    }

    enum UI {
        static let cellIdentifier = "Cell"
        static let searchUserCellIdentifier = "SearchUserCell"
        static let followCellIdentifier = "FollowCell"
        static let headerIdentifier = String(describing: UserProfileHeader.self)
    }
}

// swiftlint:enable type_name
