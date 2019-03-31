//
//  TodayViewController.swift
//  DashboardWidget
//
//  Created by Patrick Gatewood on 3/31/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO duplicated code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
        
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:210)
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 3 * collectionView.frame.size.height)
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
}

// MARK: - UICollectionViewDataSource
// TODO duplicated code
extension TodayViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}

// MARK: - UICollectionViewDelegate
// TODO duplicated code
extension TodayViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell", for: indexPath) as! ServiceCollectionViewCell
//        let service = services[indexPath.row]

        cell.logoImageView.image = UIImage(named: "server-error")
        cell.nameLabel.text = "Hello, world!"
        cell.statusImageView.image = UIImage(named: "server-error")
        cell.layer.cornerRadius = 20
//        cell.addShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if isEditing {
//            editingIndexPath = indexPath
//
//            let serviceToEdit = services[indexPath.row]
//            presentAddServiceViewController(serviceToEdit: serviceToEdit)
//        } else {
//            // TODO indicate loading
//            NetworkService.fetchServerStatus(url: services[indexPath.row].url).call { [weak self] result in
//                DispatchQueue.main.async {
//                    let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
//                    self?.onServiceStatusResult(result, for: cell)
//                }
//            }
//        }
    }
}
