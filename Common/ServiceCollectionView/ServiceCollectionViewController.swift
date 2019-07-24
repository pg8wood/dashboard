//
//  ServiceCollectionViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 3/31/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import PinkyPromise
import CoreData

class ServiceCollectionViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var database: Database = PersistenceClient()
    
    private var blockCollectionViewOperations: [BlockOperation] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database.fetchedResultsController.delegate = self
        setupCollectionView()
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
        
        let serviceUrl = database.getServiceModel(at: indexPath).url
        
        NetworkService.fetchServerStatus(url: serviceUrl).call { [weak self] result in
            DispatchQueue.main.async {
                self?.onServiceStatusResult(result, for: cell)
            }
        }
    }
    
    func onServiceStatusResult(_ result: Result<Int>, for cell: ServiceCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let service = database.getServiceModel(at: indexPath)
        
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
        return database.numberOfServices()
    }
}

// MARK: - UICollectionViewDelegate
extension ServiceCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell", for: indexPath) as! ServiceCollectionViewCell
        let service = database.getServiceModel(at: indexPath)
        
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

extension ServiceCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockCollectionViewOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let operation: BlockOperation
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { self.collectionView.insertItems(at: [newIndexPath]) }
        case .delete:
            guard let indexPath = indexPath else { return }
            operation = BlockOperation { self.collectionView.deleteItems(at: [indexPath]) }
        case .move:
            /* This case is handled implcitly by the database's `sortDescriptor`. When .update
            is handled, the items are sorted and moved by the collectionView */
            return
        case .update:
            guard let indexPath = indexPath else { return }
            operation = BlockOperation { self.collectionView.reloadItems(at: [indexPath]) }
        @unknown default:
            fatalError("Unknown BlockOperation type")
        }
        
        blockCollectionViewOperations.append(operation)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockCollectionViewOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockCollectionViewOperations.removeAll(keepingCapacity: false)
        })
    }
}
