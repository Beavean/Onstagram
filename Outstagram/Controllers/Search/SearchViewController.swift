//
//  SearchViewController.swift
//  Outstagram
//
//  Created by Beavean on 14.01.2023.
//

import UIKit

final class SearchViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: K.UI.searchUserCellIdentifier)
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.UI.searchUserCellIdentifier, for: indexPath) as? SearchUserCell
        else { return UITableViewCell() }
        return cell
    }
}
