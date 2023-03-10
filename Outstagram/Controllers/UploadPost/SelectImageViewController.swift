//
//  SelectImageViewController.swift
//  Outstagram
//
//  Created by Beavean on 23.01.2023.
//

import Photos
import UIKit

final class SelectImageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    private var images = [UIImage]()
    private var assets = [PHAsset]()
    private var selectedImage: UIImage?
    private var header: SelectPhotoHeader?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(SelectPhotoCell.self,
                                 forCellWithReuseIdentifier: SelectPhotoCell.reuseIdentifier)
        collectionView?.register(SelectPhotoHeader.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: SelectPhotoHeader.reuseIdentifier)
        collectionView?.backgroundColor = .white
        configureNavigationButtons()
        fetchPhotos()
    }

    // MARK: - UICollectionViewFlowLayout

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        referenceSizeForHeaderInSection _: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 1
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 1
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: SelectPhotoHeader.reuseIdentifier,
                                                                           for: indexPath) as? SelectPhotoHeader
        else { return UICollectionReusableView() }
        self.header = header
        if let selectedImage = selectedImage {
            if let index = images.firstIndex(of: selectedImage) {
                let selectedAsset = assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset,
                                          targetSize: targetSize,
                                          contentMode: .default,
                                          options: nil) { image, _ in
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectPhotoCell.reuseIdentifier,
                                                            for: indexPath) as? SelectPhotoCell
        else { return UICollectionViewCell() }
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - Handlers

    @objc private func handleCancel() {
        dismiss(animated: true)
    }

    @objc private func handleNext() {
        let uploadPostVC = UploadPostViewController()
        uploadPostVC.selectedImage = header?.photoImageView.image
        uploadPostVC.uploadAction = UploadPostViewController.UploadAction(index: 0)
        navigationController?.pushViewController(uploadPostVC, animated: true)
    }

    private func configureNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }

    private func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.fetchLimit = 45
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        return options
    }

    private func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { [weak self] asset, count, _ in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
                    if let image = image {
                        self?.images.append(image)
                        self?.assets.append(asset)
                        if self?.selectedImage == nil {
                            self?.selectedImage = image
                        }
                        if count == allPhotos.count - 1 {
                            DispatchQueue.main.async {
                                self?.collectionView?.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}
