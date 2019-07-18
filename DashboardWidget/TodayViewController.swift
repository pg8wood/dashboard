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
        
        // Since the ping call can return before the cell is set up, delay it by half a second. It may be better to ping first and
        // cache the response here. 
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.55) { [ weak self] in
            self?.pingService(for: cell)
        }
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
