//
//  ServiceCollectionViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 3/31/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

class ServiceCollectionViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var services: [ServiceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
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
        cell.addShadow()
        return cell
    }
}
