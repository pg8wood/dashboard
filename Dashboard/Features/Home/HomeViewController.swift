//
//  ViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

class HomeViewController: ServiceCollectionViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override var isEditing: Bool {
        didSet {
            guard let leftBarButtonItem = navigationBar.items?.first?.leftBarButtonItem else {
                return
            }
            
            leftBarButtonItem.title = isEditing ? "Done" : "Edit"
            leftBarButtonItem.style = isEditing ? .done : .plain
        }
    }
    
    var editingIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress)))
        setupNavigationBar()
    }
 
    private func setupNavigationBar() {
        navigationBar.delegate = self
        
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editServicesTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServiceTapped(_:)))
        
        navigationBar.items = [navigationItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hides the navigationBar's separator
        navigationController?.navigationBar.clipsToBounds = true
    }
    
    // MARK: - BarButtonItem actions
    @objc func addServiceTapped(_ sender: UIBarButtonItem) {
        presentAddServiceViewController()
    }
    
    func presentAddServiceViewController(serviceToEdit: ServiceModel? = nil) {
        let storyboard = UIStoryboard(name: "AddServiceViewController", bundle: nil)
        let addServiceViewController = storyboard.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
        addServiceViewController.mode = serviceToEdit == nil ? .create : .edit
        addServiceViewController.serviceDelegate = self
        addServiceViewController.serviceToEdit = serviceToEdit
        addServiceViewController.database = database
        
        let navigationController = UINavigationController(rootViewController: addServiceViewController)
        
        present(navigationController, animated: true)
    }
    
    @objc func editServicesTapped(_ sender: UIBarButtonItem) {
        isEditing.toggle()
    }
    
    @objc func onLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) else {
                return
            }
            
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(sender.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        case .cancelled:
            collectionView.cancelInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            editingIndexPath = indexPath
            
            let serviceToEdit = database.getServiceModel(at: indexPath)
            presentAddServiceViewController(serviceToEdit: serviceToEdit)
        } else {
            super.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        database.swap(itemAt: sourceIndexPath, with: destinationIndexPath)
    }
}

// MARK: - ServiceDelegate
extension HomeViewController: ServiceDelegate {
    func onNewServiceCreated(newService: ServiceModel) {
        let newIndexPath = IndexPath(row: 0, section: 0)
        pingService(for: collectionView.cellForItem(at: newIndexPath) as! ServiceCollectionViewCell)
    }
    
    func onServiceChanged(service: ServiceModel) {
        isEditing = false
        
        guard let editingIndexPath = editingIndexPath else {
            fatalError("A UICollectionViewCell was edited but its IndexPath is unknown!")
        }
        
        pingService(for: collectionView.cellForItem(at: editingIndexPath) as! ServiceCollectionViewCell)
        self.editingIndexPath = nil
    }
}

// MARK - NavigationBarDelegate

extension HomeViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
