//
//  TodayViewController.swift
//  DashboardWidget
//
//  Created by Patrick Gatewood on 3/31/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: ServiceCollectionViewController, NCWidgetProviding {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:210)
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 3 * collectionView.frame.size.height)
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
}
