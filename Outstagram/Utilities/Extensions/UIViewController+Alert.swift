//
//  UIViewController+Alert.swift
//  Outstagram
//
//  Created by Beavean on 13.01.2023.
//

import UIKit

extension UIViewController {
    func showAlertWith(_ error: Error?) {
        guard let error else { return }
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    func showAlertWith(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
