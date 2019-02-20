//
//  ViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import PinkyPromise

class ViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    // TODO: just for MVP. Future: let user add these, persist them
    let serviceNames = ["My website", "Apple", "Always-off server", "Discord Assistant Bot"]
    let serviceURLs = ["https://patrickgatewood.com", "https://apple.com", "https://fafhsdkfhdauiwhiufaehrg.com", "https://assistant.google.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            let url = serviceURLs[indexPath.row]
            
            // TODO: do this only when the user adds the service for the first time. Also let them change this image.
            NetworkService.fetchFavicon(for: url).call { result in
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
            
            NetworkService.fetchServerStatus(url: url).call { [weak self] result in
                DispatchQueue.main.async {
                    self?.onServiceStatusResult(result, for: cell)
                }
            }
        }
    }
    
    // MARK: - IBActions

    @IBAction func addService(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func editServices(_ sender: UIBarButtonItem) {
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
extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceURLs.count
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell", for: indexPath) as! ServiceCollectionViewCell
        cell.logoImageView.image = UIImage(named: "missing-image")
        cell.nameLabel.text = serviceNames[indexPath.row]
        cell.statusImageView.image = UIImage(named: "server-error")
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 6.0
        cell.layer.shadowOpacity = 0.25
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NetworkService.fetchServerStatus(url: serviceURLs[indexPath.row]).call { [weak self] result in
            DispatchQueue.main.async {
                let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                self?.onServiceStatusResult(result, for: cell)
            }
        }
    }
}
