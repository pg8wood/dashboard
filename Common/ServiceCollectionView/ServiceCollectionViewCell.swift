//
//  ServiceCollectionViewCell.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import CoreMotion

class ServiceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var logoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusImageViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        logoImageView.layer.cornerRadius = 15
        nameLabel.textColor = UIColor.label
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.color = .loadingIndicatorColor
    }
    
    func startLoading() {
        loadingIndicator.startAnimating()
        statusImageView.image = nil
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
}
