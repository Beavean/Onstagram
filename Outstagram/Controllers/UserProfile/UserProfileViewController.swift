//
//  UserProfileViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

final class UserProfileViewController: UICollectionViewController {

    // MARK: - Properties

    var user: User? {
        didSet { collectionView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fetchCurrentUserData()
    }

    // MARK: - Helpers

    private func configure() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: K.UI.cellIdentifier)
        collectionView.register(UserProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: K.UI.headerIdentifier)
        collectionView.backgroundColor = .white
    }

    // MARK: - API

    func fetchCurrentUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid, user == nil else { return }
        K.FB.usersReference.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot, _ in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self?.user = user
            self?.navigationItem.title = user.username
            self?.collectionView?.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: K.UI.headerIdentifier,
                                                                           for: indexPath) as? UserProfileHeader
        else { return UICollectionReusableView() }
        header.user = self.user
        navigationItem.title = user?.username
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.UI.cellIdentifier, for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: view.frame.width, height: 200)
    }
}
