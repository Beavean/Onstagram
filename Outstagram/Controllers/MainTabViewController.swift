//
//  MainTabViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseAuth

final class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Properties

    private let dot = UIView()
    private var isInitialLoad: Bool?

    private enum NavigationItems: String, CaseIterable {
        case feed
        case search
        case uploadPost
        case notifications
        case userProfile

        var controller: UIViewController {
            switch self {
            case .feed:
                return FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
            case .search:
                return SearchViewController()
            case .uploadPost:
                return UploadPostViewController()
            case .notifications:
                return NotificationsTableViewController()
            case .userProfile:
                return UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
            }
        }

        var unselectedImage: UIImage? {
            switch self {
            case .feed:
                return UIImage(systemName: "house")
            case .search:
                return UIImage(systemName: "magnifyingglass")
            case .uploadPost:
                return UIImage(systemName: "plus.app")
            case .notifications:
                return UIImage(systemName: "heart")
            case .userProfile:
                return UIImage(systemName: "person")
            }
        }

        var selectedImage: UIImage? {
            switch self {
            case .feed:
                return UIImage(systemName: "house.fill")
            case .search:
                return UIImage(systemName: "sparkle.magnifyingglass")
            case .uploadPost:
                return UIImage(systemName: "plus.app")
            case .notifications:
                return UIImage(systemName: "heart.fill")
            case .userProfile:
                return UIImage(systemName: "person.fill")
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureViewControllers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserIsLoggedIn()
    }

    // MARK: - Handlers

    func configureViewControllers() {
        var createdControllers = [UIViewController]()
        NavigationItems.allCases.forEach { item in
            createdControllers.append(createNavigationController(unselectedImage: item.unselectedImage,
                                                               selectedImage: item.selectedImage,
                                                               rootViewController: item.controller))
        }
        viewControllers = createdControllers
        tabBar.tintColor = .black
    }

    private func createNavigationController(unselectedImage: UIImage?,
                                            selectedImage: UIImage?,
                                            rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        return navController
    }

    private func checkIfUserIsLoggedIn() {
        guard Auth.auth().currentUser == nil else { return }
        let navigationController = UINavigationController(rootViewController: LoginViewController())
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
}