//
//  HashtagController.swift
//  Outstagram
//
//  Created by Beavean on 13.02.2023.
//

import UIKit
import FirebaseDatabase

class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    var posts = [Post]()
    var hashtag: String?

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        collectionView?.backgroundColor = .white
        collectionView?.register(HashtagCell.self, forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
        fetchPosts()
    }

    // MARK: - UICollectionViewFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = HashtagCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? HashtagCell
        else { return UICollectionViewCell() }
        cell.post = posts[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }

    // MARK: - Handlers

    func configureNavigationBar() {
        guard let hashtag = self.hashtag else { return }
        navigationItem.title = hashtag
    }

    // MARK: - API

    func fetchPosts() {
        guard let hashtag = self.hashtag else { return }
        K.FB.hashtagPostReference.child(hashtag).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            Database.fetchPost(with: postId) { post in
                self.posts.append(post)
                self.collectionView?.reloadData()
            }
        }
    }
}
