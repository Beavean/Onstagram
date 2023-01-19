//
//  SearchViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseDatabase

final class SearchViewController: UITableViewController {

    // MARK: - Properties

    var users = [User]() {
        didSet { self.tableView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: K.UI.searchUserCellIdentifier)
        tableView.separatorStyle = .none
        fetchUsers()
    }

    // MARK: - Table view methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.UI.searchUserCellIdentifier, for: indexPath) as? SearchUserCell
        else { return UITableViewCell() }
        cell.user = users[indexPath.row]
        return cell
    }

    // MARK: - API

    private func fetchUsers() {
        K.FB.usersReference.observe(.childAdded) { [weak self] snapshot, _ in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            self?.users.append(user)
        }
    }
}
