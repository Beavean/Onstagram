//
//  HashtagController.swift
//  Outstagram
//
//  Created by Beavean on 13.02.2023.
//

import FirebaseDatabase
import UIKit

final class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
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

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        1
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        1
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = HashtagCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? HashtagCell
        else { return UICollectionViewCell() }
        cell.post = posts[indexPath.item]
        return cell
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }

    // MARK: - Handlers

    func configureNavigationBar() {
        guard let hashtag = hashtag else { return }
        navigationItem.title = hashtag
    }

    // MARK: - API

    func fetchPosts() {
        guard let hashtag = hashtag else { return }
        FBConstants.DBReferences.hashtagPost.child(hashtag).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            Database.fetchPost(with: postId) { [weak self] post in
                self?.posts.append(post)
                self?.collectionView?.reloadData()
            }
        }
    }
}
