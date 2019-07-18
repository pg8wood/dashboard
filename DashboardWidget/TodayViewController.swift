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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width:self.view.frame.size.width, height: 250)
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        vibrancyView.effect = UIVibrancyEffect.widgetEffect(forVibrancyStyle: .fill)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode,
                                          withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 300)
            pingAppearingServices()
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 250)
        }
    }
    
    /// Pings the services about to show.  If this operation ever takes much longer, it may be a good candidate to
    /// start caching the responses instead of re-pinging each time
    private func pingAppearingServices() {
        let numberOfCells = collectionView.numberOfItems(inSection: 0)
        
        guard numberOfCells > 2 else {
            return
        }
        
        for i in 2..<numberOfCells {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: i, section:  0)) as? ServiceCollectionViewCell else {
                continue
            }
            
            pingService(for: cell)
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
        cell.statusImageViewWidthConstraint.constant = 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 5, height: cellHeight)
    }
}
