//
//  ViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import PinkyPromise

class ViewController: UITableViewController {
    
    // TODO: just for MVP. Future: let user add these, persist them
    let serviceNames = ["My website", "Google", "Always-off server"]
    let serviceURLs = ["https://patrickgatewood.com", "https://google.com", "https://fafhsdkfhdauiwhiufaehrg.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ServiceTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell), let cell = cell as? ServiceTableViewCell else {
                return
            }
            
            NetworkService.fetchServerStatus(url: serviceURLs[indexPath.row]).call { [weak self] result in
                DispatchQueue.main.async {
                    self?.onServiceStatusResult(result, for: cell)
                }
            }
        }
    }

    // MARK: - TableView data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceURLs.count
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableViewCell", for: indexPath) as! ServiceTableViewCell
        cell.serviceImageView.image = UIImage(named: "ghost")
        cell.serviceNameLabel.text = serviceNames[indexPath.row]
        cell.statusImageView.image = UIImage(named: "server-error")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NetworkService.fetchServerStatus(url: serviceURLs[indexPath.row]).call { [weak self] result in
            DispatchQueue.main.async {
                let cell = self?.tableView.cellForRow(at: indexPath) as! ServiceTableViewCell
                self?.onServiceStatusResult(result, for: cell)
            }
        }
    }
    
    func onServiceStatusResult(_ result: Result<Int>, for cell: ServiceTableViewCell) {
        do {
            let _ = try result.value()
            cell.statusImageView.image = UIImage(named: "check")
        } catch {
            cell.statusImageView.image = UIImage(named: "server-error")
        }
    }
}
