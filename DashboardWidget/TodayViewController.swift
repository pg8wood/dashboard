//
//  TodayViewController.swift
//  DashboardWidget
//
//  Created by Patrick Gatewood on 3/31/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: ServiceCollectionViewController, NCWidgetProviding, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var vibrancyView: UIVisualEffectView!
    
    private final let cellHeight: CGFloat = 45
    private final let cellSpacing: CGFloat = 10
    
    private var widgetPreferredHeight: CGFloat {
        return (cellHeight + cellSpacing) * CGFloat(collectionView.numberOfItems(inSection: 0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width:self.view.frame.size.width, height: 250)
        extensionContext?.widgetLargestAvailableDisplayMode = database.numberOfServices() > 2 ? .expanded : .compact
        vibrancyView.effect = UIVibrancyEffect.widgetEffect(forVibrancyStyle: .fill)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode,
                                          withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: widgetPreferredHeight)
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 250)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ServiceCollectionViewCell else { return }
        adaptCellLayoutForWidgetView(cell)
    }
    
    private func adaptCellLayoutForWidgetView(_ cell: ServiceCollectionViewCell) {
        cell.backgroundColor = UIColor.clear
        cell.imageContainerView.backgroundColor = UIColor.clear
        cell.loadingIndicator.color = .widgetLoadingIndicatorColor
        cell.logoImageViewWidthConstraint.constant = cellHeight
        cell.logoImageView.layer.cornerRadius = 0
        cell.statusImageViewWidthConstraint.constant = 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 5, height: cellHeight)
    }
}
