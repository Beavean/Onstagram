//
//  UIViewController+MentionedUser.swift
//  Outstagram
//
//  Created by Beavean on 24.01.2023.
//

import FirebaseAuth
import FirebaseDatabase
import UIKit

extension UIViewController {
    func getMentionedUser(withUsername username: String) {
        FBConstants.DBReferences.users.observe(.childAdded) { [weak self] snapshot in
            let uid = snapshot.key
            FBConstants.DBReferences.users.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                if username == dictionary["username"] as? String {
                    Database.fetchUser(with: uid) { user in
                        let userProfileController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
                        userProfileController.user = user
                        self?.navigationController?.pushViewController(userProfileController, animated: true)
                    }
                }
            }
        }
    }

    func uploadMentionNotification(forPostId postId: String, withText text: String, isForComment: Bool) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var mentionIntegerValue: Int!
        if isForComment {
            mentionIntegerValue = FBConstants.Values.commentMention
        } else {
            mentionIntegerValue = FBConstants.Values.postMention
        }
        for var word in words where word.hasPrefix("@") {
            word = word.trimmingCharacters(in: .symbols)
            word = word.trimmingCharacters(in: .punctuationCharacters)
            FBConstants.DBReferences.users.observe(.childAdded) { snapshot in
                let uid = snapshot.key
                FBConstants.DBReferences.users.child(uid).observeSingleEvent(of: .value) { snapshot in
                    guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                    if word == dictionary["username"] as? String {
                        let notificationValues = ["postId": postId,
                                                  "uid": currentUid,
                                                  "type": mentionIntegerValue as Int,
                                                  "creationDate": creationDate] as [String: Any]
                        if currentUid != uid {
                            FBConstants.DBReferences.notifications.child(uid).childByAutoId().updateChildValues(notificationValues)
                        }
                    }
                }
            }
        }
    }
}
