//
//  ViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import PinkyPromise

class ViewController: UICollectionViewController {
    
    // TODO: just for MVP. Future: let user add these, persist them
    let serviceNames = ["My website", "Google", "Always-off server"]
    let serviceURLs = ["https://patrickgatewood.com", "https://google.com", "https://fafhsdkfhdauiwhiufaehrg.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell), let cell = cell as? ServiceCollectionViewCell else {
                return
            }
            
            let url = serviceURLs[indexPath.row]
            
            // TODO: do this only when the user adds the service for the first time. Also let them change this image.
            NetworkService.fetchFavicon(for: url).call { result in
                do {
                    let favicon = try result.value()
                    cell.logoImageView.image = favicon
                } catch {
                    cell.logoImageView.image = UIImage(named: "ghost")
                }
            }
            
            NetworkService.fetchServerStatus(url: url).call { [weak self] result in
                DispatchQueue.main.async {
                    self?.onServiceStatusResult(result, for: cell)
                }
            }
        }
    }

    // MARK: - CollectionView data source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceURLs.count
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell", for: indexPath) as! ServiceCollectionViewCell
        cell.logoImageView.image = UIImage(named: "ghost")
        cell.nameLabel.text = serviceNames[indexPath.row]
        cell.statusImageView.image = UIImage(named: "server-error")
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NetworkService.fetchServerStatus(url: serviceURLs[indexPath.row]).call { [weak self] result in
            DispatchQueue.main.async {
                let cell = self?.collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                self?.onServiceStatusResult(result, for: cell)
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

//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//    }
//}
