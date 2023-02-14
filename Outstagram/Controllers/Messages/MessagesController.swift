//
//  MessagesController.swift
//  Outstagram
//
//  Created by Beavean on 07.02.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

final class MessagesController: UITableViewController {

    // MARK: - Properties

    var messages = [Message]()
    var messagesDictionary = [String: Message]()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        fetchMessages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message = messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        FBConstants.DBReferences.userMessages.child(uid).child(chatPartnerId).removeValue { _, _ in
            self.messages.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier,
                                                       for: indexPath) as? MessageCell
        else { return UITableViewCell() }
        cell.delegate = self
        cell.message = messages[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MessageCell else { return }
        let message = messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        Database.fetchUser(with: chatPartnerId) { user in
            self.showChatController(forUser: user)
            cell.messageTextLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }

    // MARK: - Handlers

    @objc private func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        self.present(navigationController, animated: true)
    }

    func showChatController(forUser user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }

    private func configureNavigationBar() {
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }

    // MARK: - API

    private func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()
        FBConstants.DBReferences.userMessages.child(currentUid).observe(.childAdded) { snapshot in
            let uid = snapshot.key
            FBConstants.DBReferences.userMessages.child(currentUid).child(uid).observe(.childAdded) { snapshot in
                let messageId = snapshot.key
                self.fetchMessage(withMessageId: messageId)
            }
        }
    }

    private func fetchMessage(withMessageId messageId: String) {
        FBConstants.DBReferences.messages.child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let message = Message(dictionary: dictionary)
            let chatPartnerId = message.getChatPartnerId()
            self.messagesDictionary[chatPartnerId] = message
            self.messages = Array(self.messagesDictionary.values)
            self.messages.sort { (message1, message2) -> Bool in
                return message1.creationDate > message2.creationDate
            }
            self.tableView?.reloadData()
        }
    }
}

extension MessagesController: MessageCellDelegate {
    func configureUserData(for cell: MessageCell) {
        guard let chatPartnerId = cell.message?.getChatPartnerId() else { return }
        Database.fetchUser(with: chatPartnerId) { user in
            cell.profileImageView.loadImage(with: user.profileImageUrl)
            cell.usernameLabel.text = user.username
        }
    }
}
