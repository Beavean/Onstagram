//
//  NewMessageController.swift
//  Outstagram
//
//  Created by Beavean on 07.02.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

final class NewMessageController: UITableViewController {

    // MARK: - Properties

    var users = [User]()
    private var messagesController: MessagesController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: NewMessageCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        fetchUsers()
    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewMessageCell.reuseIdentifier,
                                                       for: indexPath) as? NewMessageCell
        else { return UITableViewCell() }
        cell.user = users[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
        }
    }

    // MARK: - Handlers

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    private func configureNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    // MARK: - API

    private func fetchUsers() {
        K.FB.usersReference.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            if uid != Auth.auth().currentUser?.uid {
                Database.fetchUser(with: uid) { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
}
