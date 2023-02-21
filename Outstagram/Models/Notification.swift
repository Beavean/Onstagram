//
//  Notification.swift
//  Outstagram
//
//  Created by Beavean on 27.01.2023.
//

import Foundation

protocol Printable {
    var description: String { get }
}

final class Notification {
    enum NotificationType: Int, Printable {
        case like
        case comment
        case follow
        case commentMention
        case postMention

        var description: String {
            switch self {
            case .like: return " liked your post"
            case .comment: return " commented on your post"
            case .follow: return " started following you"
            case .commentMention: return " mentioned you in a comment"
            case .postMention: return " mentioned you in a post"
            }
        }

        init(index: Int) {
            switch index {
            case 0: self = .like
            case 1: self = .comment
            case 2: self = .follow
            case 3: self = .commentMention
            case 4: self = .postMention
            default: self = .like
            }
        }
    }

    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User!
    var type: Int?
    var notificationType: NotificationType!
    var commentId: String?
    var commentText: String?
    var didCheck = false

    init(user: User, post: Post? = nil, dictionary: [String: AnyObject]) {
        self.user = user
        if let post = post {
            self.post = post
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        if let type = dictionary["type"] as? Int {
            notificationType = NotificationType(index: type)
        }
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        if let postId = dictionary["postId"] as? String {
            self.postId = postId
        }
        if let commentId = dictionary["commentId"] as? String {
            self.commentId = commentId
        }
        if let checked = dictionary["checked"] as? Int {
            if checked == 0 {
                didCheck = false
            } else {
                didCheck = true
            }
        }
    }
}
