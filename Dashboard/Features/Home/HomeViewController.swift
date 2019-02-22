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
    
    @IBOutlet var collectionView: UICollectionView!
    
    var services: [ServiceModel] = []
    var database: Database = PersistenceClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
        services = database.getStoredServices().reversed()
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
            
            let serviceUrl = services[indexPath.row].url
            
            // TODO: do this only when the user adds the service for the first time. Also let them change this image.
            NetworkService.fetchFavicon(for: serviceUrl).call { result in
                do {
                    let favicon = try result.value()
                    cell.logoImageView.image = favicon
                    
                    // If an image is more than twice as wide as it is tall, ensure it doesn't get
                    // clipped to oblivion
                    let shouldScaleImage = favicon.size.width / favicon.size.height > 2
                    cell.logoImageView.contentMode = shouldScaleImage ? .scaleAspectFit : .scaleAspectFill
                } catch {
                    cell.logoImageView.image = UIImage(named: "missing-image")
                }
            }
            
            NetworkService.fetchServerStatus(url: serviceUrl).call { [weak self] result in
                DispatchQueue.main.async {
                    self?.onServiceStatusResult(result, for: cell)
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func addServiceTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "AddServiceViewController", bundle: nil)
        let addServiceViewController = storyboard.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
        addServiceViewController.newServiceDelegate = self
        
        present(addServiceViewController, animated: true)
    }
    
    @IBAction func editServicesTapped(_ sender: UIBarButtonItem) {
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
        cell.logoImageView.image = UIImage(named: "missing-image")
        cell.nameLabel.text = services[indexPath.row].name
        cell.statusImageView.image = UIImage(named: "server-error")
        cell.layer.cornerRadius = 20
        cell.addShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NetworkService.fetchServerStatus(url: services[indexPath.row].url).call { [weak self] result in
            DispatchQueue.main.async {
                let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                self?.onServiceStatusResult(result, for: cell)
            }
        }
    }
}

// MARK: - NewServiceDelegate
extension HomeViewController: NewServiceDelegate {
    func onSaved(newService: ServiceModel) {
        services.insert(newService, at: 0)
        collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
    }
}
