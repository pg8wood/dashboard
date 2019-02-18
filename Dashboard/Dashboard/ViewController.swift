//
//  ViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let serviceURLs = ["https://patrickgatewood.com", "https://google.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ServiceTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceTableViewCell")
    }

    // MARK: - TableView data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceURLs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableViewCell", for: indexPath) as! ServiceTableViewCell
        cell.serviceImageView.image = UIImage(named: "ghost")
        cell.serviceNameLabel.text = serviceURLs[indexPath.row]
        cell.statusImageView.image = UIImage(named: "server-error")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell")
        NetworkService.fetchServerStatus(url: serviceURLs[indexPath.row]).call { [weak self] result in
            DispatchQueue.main.async {
                let cell = tableView.cellForRow(at: indexPath) as! ServiceTableViewCell
                do {
                    let value = try result.value()
                    cell.statusImageView.image = UIImage(named: "check")
                } catch {
                    cell.statusImageView.image = UIImage(named: "server-error")
                }
            }
        }
    }
}
