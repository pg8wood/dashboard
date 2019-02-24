//
//  ViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import PinkyPromise

class HomeViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var collectionView: UICollectionView!
    
    var services: [ServiceModel] = []
    var database: Database = PersistenceClient()
    
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
        setupNavigationBar()
        setupCollectionView()
        services = database.getStoredServices().reversed()
    }
 
    private func setupNavigationBar() {
        navigationBar.delegate = self
        
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editServicesTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServiceTapped(_:)))
        
        navigationBar.items = [navigationItem]
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hides the navigationBar's separator
        navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    // MARK: - BarButtonItem actions
    @objc func addServiceTapped(_ sender: UIBarButtonItem) {
        presentAddServiceViewController()
    }
    
    func presentAddServiceViewController(serviceToEdit: ServiceModel? = nil) {
        let storyboard = UIStoryboard(name: "AddServiceViewController", bundle: nil)
        let addServiceViewController = storyboard.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
        
        addServiceViewController.serviceDelegate = self
        addServiceViewController.serviceToEdit = serviceToEdit
        
        present(addServiceViewController, animated: true)
    }
    
    @objc func editServicesTapped(_ sender: UIBarButtonItem) {
        isEditing.toggle()
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
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell", for: indexPath) as! ServiceCollectionViewCell
        let service = services[indexPath.row]

        cell.logoImageView.image = service.image
        cell.nameLabel.text = service.name
        cell.statusImageView.image = UIImage(named: "server-error")
        cell.layer.cornerRadius = 20
        cell.addShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            editingIndexPath = indexPath
            
            let serviceToEdit = services[indexPath.row]
            presentAddServiceViewController(serviceToEdit: serviceToEdit)
        } else {
            // TODO indicate loading
            NetworkService.fetchServerStatus(url: services[indexPath.row].url).call { [weak self] result in
                DispatchQueue.main.async {
                    let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                    self?.onServiceStatusResult(result, for: cell)
                }
            }
        }
    }
}

// MARK: - ServiceDelegate
extension HomeViewController: ServiceDelegate {
    func onNewServiceCreated(newService: ServiceModel) {
        services.insert(newService, at: 0)
        collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
    }
    
    func onServiceChanged(service: ServiceModel) {
        isEditing = false
        guard let editingIndexPath = editingIndexPath else {
            fatalError("A UICollectionViewCell was edited but its IndexPath is unknown!")
        }
        
        services[editingIndexPath.row] = service
        collectionView.reloadItems(at: [editingIndexPath])
        self.editingIndexPath = nil
    }
}

// MARK - NavigationBarDelegate

extension HomeViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
