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
    var database: Database
    
    required init?(coder: NSCoder) {
        database = PersistenceClient()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database.getStoredServices { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                do {
                    self.services = try result.get()
                    self.setupCollectionView()
                } catch {
                    self.show(error: error)
                }
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pingServices()
    }
    
    func pingServices() {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? ServiceCollectionViewCell else {
                break
            }
            
            pingService(for: cell)
        }
    }
    
    func pingService(for cell: ServiceCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        cell.startLoading()
        
        let serviceUrl = services[indexPath.row].url
        
        OldNetworkService.fetchServerStatus(url: serviceUrl).call { [weak self] result in
            DispatchQueue.main.async {
                self?.onServiceStatusResult(result, for: cell)
            }
        }
    }
    
    func onServiceStatusResult(_ result: Result<Int>, for cell: ServiceCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let service = services[indexPath.row]
        
        cell.stopLoading()
        
        do {
            let _ = try result.value()
            
            database.updateLastOnlineDate(for: service, lastOnline: Date(timeIntervalSinceNow: 0))
            
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
        cell.statusImageView.image = service.wasOnlineRecently ? UIImage(named: "check") : UIImage(named: "server-error")
        cell.layer.cornerRadius = 20

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
        
        pingService(for: cell)
    }
}
