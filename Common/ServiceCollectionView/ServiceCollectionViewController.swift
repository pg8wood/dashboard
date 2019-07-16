//
//  ServiceCollectionViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 3/31/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import PinkyPromise

class ServiceCollectionViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var services: [ServiceModel] = []
    var database: Database = PersistenceClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        services = database.getStoredServices()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pingServices()
    }
    
    func pingServices() {
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell), let cell = cell as? ServiceCollectionViewCell else {
                return
            }
            
            // Render each service status
            let serviceUrl = services[indexPath.row].url
            NetworkService.fetchServerStatus(url: serviceUrl).call { [weak self] result in
                DispatchQueue.main.async {
                    self?.onServiceStatusResult(result, for: cell)
                }
            }
        }
    }
    
    func onServiceStatusResult(_ result: Result<Int>, for cell: ServiceCollectionViewCell) {
        do {
            let _ = try result.value()
            cell.statusImageView.image = UIImage(named: "check")
        } catch {
            cell.statusImageView.image = UIImage(named: "server-error")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ServiceCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
}

// MARK: - UICollectionViewDelegate
extension ServiceCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell", for: indexPath) as! ServiceCollectionViewCell
        let service = services[indexPath.row]
        
        cell.logoImageView.image = service.image
        cell.nameLabel.text = service.name
        cell.statusImageView.image = UIImage(named: "server-error")
        cell.layer.cornerRadius = 20

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO indicate loading
        NetworkService.fetchServerStatus(url: services[indexPath.row].url).call { [weak self] result in
            DispatchQueue.main.async {
                let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                self?.onServiceStatusResult(result, for: cell)
            }
        }
    }
}
