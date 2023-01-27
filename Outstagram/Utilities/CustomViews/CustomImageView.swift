//
//  CustomImageView.swift
//  Outstagram
//
//  Created by Beavean on 17.01.2023.
//

import UIKit

final class CustomImageView: UIImageView {

    var imageCache = [String: UIImage]()

    var lastImgUrlUsedToLoadImage: String?

    func loadImage(with urlString: String?) {
        guard let urlString else { return }
        self.image = nil
        lastImgUrlUsedToLoadImage = urlString
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            if self?.lastImgUrlUsedToLoadImage != url.absoluteString {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            self?.imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self?.image = photoImage
            }
        }.resume()
    }
}
