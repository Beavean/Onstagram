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
    }

    enum UI {
        static let cellIdentifier = "Cell"
        static let searchUserCellIdentifier = "SearchUserCell"
        static let headerIdentifier = String(describing: UserProfileHeader.self)
    }
}

// swiftlint:enable type_name
