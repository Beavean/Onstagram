//
//  UploadPostViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

final class UploadPostViewController: UIViewController, UITextViewDelegate {

    // MARK: - Properties

    enum UploadAction: Int {
        case uploadPost
        case saveChanges

        init(index: Int) {
            switch index {
            case 0: self = .uploadPost
            case 1: self = .saveChanges
            default: self = .uploadPost
            }
        }
    }

    var uploadAction: UploadAction!
    var selectedImage: UIImage?
    var postToEdit: Post?

    private let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let captionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.systemGroupedBackground
        textView.font = UIFont.systemFont(ofSize: 12)
        return textView
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        loadImage()
        captionTextView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController(forUploadAction: uploadAction)
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            actionButton.isEnabled = false
            actionButton.backgroundColor = .systemBlue.withAlphaComponent(0.5)
            return
        }
        actionButton.isEnabled = true
        actionButton.backgroundColor = .systemBlue
    }

    // MARK: - Handlers

    @objc private func handleUploadAction() {
        buttonSelector(uploadAction: uploadAction)
    }

    @objc private func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    private func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .uploadPost:
            handleUploadPost()
        case .saveChanges:
            handleSavePostChanges()
        }
    }

    private func configureViewController(forUploadAction uploadAction: UploadAction) {
        if uploadAction == .saveChanges {
            guard let post = self.postToEdit else { return }
            actionButton.setTitle("Save Changes", for: .normal)
            self.navigationItem.title = "Edit Post"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationController?.navigationBar.tintColor = .black
            photoImageView.loadImage(with: post.imageUrl)
            captionTextView.text = post.caption
        } else {
            actionButton.setTitle("Share", for: .normal)
            self.navigationItem.title = "Upload Post"
        }
    }

    private func loadImage() {
        guard let selectedImage = self.selectedImage else { return }
        photoImageView.image = selectedImage
    }

    private func configureViewComponents() {
        view.backgroundColor = .white

        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 92, paddingLeft: 12, width: 100, height: 100)

        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor,
                               left: photoImageView.rightAnchor,
                               right: view.rightAnchor,
                               paddingTop: 92,
                               paddingLeft: 12,
                               paddingRight: 12,
                               width: view.frame.width - photoImageView.frame.width - 36,
                               height: 100)

        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor,
                            left: view.leftAnchor,
                            right: view.rightAnchor,
                            paddingTop: 12,
                            paddingLeft: 24,
                            paddingRight: 24,
                           
                            height: 40)
    }

    // MARK: - API

    private func handleSavePostChanges() {
        guard let post = self.postToEdit else { return }
        guard let updatedCaption = captionTextView.text else { return }
        if updatedCaption.contains("#") {
            self.uploadHashtagToServer(withPostId: post.postId)
        }
        K.FB.postsReference.child(post.postId).child("caption").setValue(updatedCaption) { [weak self] _, _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func handleUploadPost() {
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid,
            let uploadData = postImg.jpegData(compressionQuality: 0.5)
        else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let filename = NSUUID().uuidString
        let storageRef = K.FBSTORE.storagePostImageReference.child(filename)
        storageRef.putData(uploadData, metadata: nil) { [weak self] _, error in
            if let error {
                self?.showAlertWith(error)
                return
            }
            storageRef.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else { return }
                if let error {
                    self?.showAlertWith(error)
                    return
                }
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageUrl,
                              "ownerUid": currentUid] as [String: Any]
                let postId = K.FB.postsReference.childByAutoId()
                guard let postKey = postId.key else { return }
                postId.updateChildValues(values) { error, _ in
                    if let error {
                        self?.showAlertWith(error)
                        return
                    }
                    let userPostsRef = K.FB.userPostsReference.child(currentUid)
                    userPostsRef.updateChildValues([postKey: 1])
                    self?.updateUserFeeds(with: postKey)
                    if caption.contains("#") {
                        self?.uploadHashtagToServer(withPostId: postKey)
                    }
                    if caption.contains("@") {
                        self?.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: false)
                    }
                    self?.dismiss(animated: true) {
                        self?.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
    }

    func updateUserFeeds(with postId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let values = [postId: 1]
        K.FB.userFollowersReference.child(currentUid).observe(.childAdded) { snapshot in
            let followerUid = snapshot.key
            K.FB.userFeedReference.child(followerUid).updateChildValues(values)
        }
        K.FB.userFeedReference.child(currentUid).updateChildValues(values)
    }

    func uploadHashtagToServer(withPostId postId: String) {
        guard let caption = captionTextView.text else { return }
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        for var word in words where word.hasPrefix("#") {
            word = word.trimmingCharacters(in: .punctuationCharacters)
            word = word.trimmingCharacters(in: .symbols)
            let hashtagValues = [postId: 1]
            K.FB.hashtagPostReference.child(word.lowercased()).updateChildValues(hashtagValues)
        }
    }
}
