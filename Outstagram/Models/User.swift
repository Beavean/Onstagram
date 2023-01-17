//
//  User.swift
//  Outstagram
//
//  Created by Beavean on 17.01.2023.
//

import Foundation

class User {

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
}
