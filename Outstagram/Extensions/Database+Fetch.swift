//
//  Database+Fetch.swift
//  Outstagram
//
//  Created by Beavean on 21.01.2023.
//

import FirebaseDatabase

extension Database {

    static func fetchUser(with uid: String, completion: @escaping(User) -> Void) {
        K.FB.usersReference.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
}
