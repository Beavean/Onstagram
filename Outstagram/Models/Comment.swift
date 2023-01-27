//
//  Comment.swift
//  Outstagram
//
//  Created by Beavean on 27.01.2023.
//

import Foundation

final class Comment {

    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?

    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
