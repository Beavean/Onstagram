//
//  SearchViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseDatabase

final class SearchViewController: UITableViewController,
                                  UISearchBarDelegate,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    private var users = [User]()
    private var filteredUsers = [User]()
    private var searchBar = UISearchBar()
    private var inSearchMode = false
    private var collectionView: UICollectionView!
    private var collectionViewEnabled = true
    private var posts = [Post]()
    private var currentKey: String?
    private var userCurrentKey: String?

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: SearchUserCell.reuseIdentifier)
        tableView.separatorStyle = .none
        configureSearchBar()
        configureCollectionView()
        configureRefreshControl()
        fetchPosts()
    }

    // MARK: - UITableView

   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredUsers.count
        } else {
            return users.count
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user: User!
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchUserCell.reuseIdentifier,
                                                       for: indexPath) as? SearchUserCell
        else { return UITableViewCell() }
        var user: User!
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.user = user
        return cell
    }

    // MARK: - UICollectionView

    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let frame = CGRect(x: 0,
                           y: 0,
                           width: view.frame.width,
                           height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: "SearchPostCell")
        configureRefreshControl()
        tableView.addSubview(collectionView)
        tableView.separatorColor = .clear
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 20 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPostCell.reuseIdentifier,
                                                            for: indexPath) as? SearchPostCell else { return UICollectionViewCell() }
        cell.post = posts[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }

    // MARK: - UISearchBar

    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = .systemGray5
        searchBar.tintColor = .black
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        fetchUsers()
        collectionView.isHidden = true
        collectionViewEnabled = false
        tableView.separatorColor = .lightGray
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            tableView.reloadData()
        } else {
            inSearchMode = true
            filteredUsers = users.filter { (user) -> Bool in
                return user.username.contains(searchText)
            }
            tableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        inSearchMode = false
        collectionViewEnabled = true
        collectionView.isHidden = false
        tableView.separatorColor = .clear
        tableView.reloadData()
    }

    // MARK: - Handlers

    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }

    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }

    // MARK: - API

    func fetchUsers() {
        if userCurrentKey == nil {
            K.FB.usersReference.queryLimited(toLast: 10).observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.forEach { snapshot in
                    let uid = snapshot.key
                    Database.fetchUser(with: uid) { user in
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                }
                self.userCurrentKey = first.key
            }
        } else {
            K.FB.usersReference
                .queryOrderedByKey()
                .queryEnding(atValue: userCurrentKey)
                .queryLimited(toLast: 5)
                .observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.removeAll(where: { $0.key == self.userCurrentKey })
                allObjects.forEach { snapshot in
                    let uid = snapshot.key
                    if uid != self.userCurrentKey {
                        Database.fetchUser(with: uid) { user in
                            self.users.append(user)
                            if self.users.count == allObjects.count  {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                self.userCurrentKey = first.key
            }
        }
    }

    func fetchPosts() {
        if currentKey == nil {
            K.FB.postsReference.queryLimited(toLast: 21).observeSingleEvent(of: .value) { snapshot in
                self.tableView.refreshControl?.endRefreshing()
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    Database.fetchPost(with: postId) { post in
                        self.posts.append(post)
                        self.collectionView.reloadData()
                    }
                }
                self.currentKey = first.key
            }
        } else {
            K.FB.postsReference.queryOrderedByKey()
                .queryEnding(atValue: self.currentKey)
                .queryLimited(toLast: 10)
                .observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    if postId != self.currentKey {
                        Database.fetchPost(with: postId) { post in
                            self.posts.append(post)
                            self.collectionView.reloadData()
                        }
                    }
                }
                self.currentKey = first.key
            }
        }
    }
}
