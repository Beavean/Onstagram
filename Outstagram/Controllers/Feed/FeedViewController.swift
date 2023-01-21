//
//  FeedViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseAuth

final class FeedViewController: UICollectionViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: K.UI.cellIdentifier)
        configureLogoutButton()
    }

    // MARK: - Handlers

    @objc private func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            let navController = UINavigationController(rootViewController: LoginViewController())
            navController.modalPresentationStyle = .fullScreen
            do {
                try Auth.auth().signOut()
                self.present(navController, animated: true)
            } catch {
                self.showAlertWith(error)
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    @objc private func handleShowMessages() {
    }

    // MARK: - Helpers

    private func configureLogoutButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let shareImage = UIImage(systemName: "message")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: shareImage,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.UI.cellIdentifier, for: indexPath)
        return cell
    }
}
