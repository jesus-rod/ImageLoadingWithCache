//
//  ViewController.swift
//  ImageLoadingWithCache
//
//  Created by JesusR on 01.09.24.
//

import UIKit
import ImageLoaderPlusCache

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "ImageTableViewCell")
        return tableView
    }()
    let imageURLs: [URL] = [
        URL(string: "https://loremflickr.com/160/120/dog")!,
        URL(string: "https://loremflickr.com/160/120/cat")!,
        URL(string: "https://loremflickr.com/160/120/ant")!,
        URL(string: "https://loremflickr.com/160/120/lizard")!,
        URL(string: "https://loremflickr.com/160/120/bird")!,
        URL(string: "https://loremflickr.com/160/120/canary")!,
        URL(string: "https://loremflickr.com/160/120/bug")!,
        URL(string: "https://loremflickr.com/160/120/elephant")!,
        URL(string: "https://loremflickr.com/160/120/spider")!,
        URL(string: "https://loremflickr.com/160/120/giraffe")!,
        URL(string: "https://loremflickr.com/160/120/zebra")!,
        URL(string: "https://loremflickr.com/160/120/tiger")!,
        URL(string: "https://loremflickr.com/160/120/lion")!,
        URL(string: "https://loremflickr.com/160/120/eagle")!,
        URL(string: "https://loremflickr.com/160/120/dog")!,
        URL(string: "https://loremflickr.com/160/120/cat")!,
        URL(string: "https://loremflickr.com/160/120/ant")!,
        URL(string: "https://loremflickr.com/160/120/lizard")!,
        URL(string: "https://loremflickr.com/160/120/bird")!,
        URL(string: "https://loremflickr.com/160/120/canary")!,
        URL(string: "https://loremflickr.com/160/120/bug")!,
        URL(string: "https://loremflickr.com/160/120/elephant")!,
        URL(string: "https://loremflickr.com/160/120/spider")!,
        URL(string: "https://loremflickr.com/160/120/giraffe")!,
        URL(string: "https://loremflickr.com/160/120/zebra")!,
        URL(string: "https://loremflickr.com/160/120/tiger")!,
        URL(string: "https://loremflickr.com/160/120/lion")!,
        URL(string: "https://loremflickr.com/160/120/eagle")!
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageURLs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        let url = imageURLs[indexPath.row]

        cell.configure(with: "Image \(indexPath.row)")
        ImageClient.shared.setImage(on: cell.customImageView, fromURL: url, withPlaceholder: UIImage(systemName: "photo"))

        return cell
    }

}
