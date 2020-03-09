//
//  VocableUIControl.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIControl {
    
    private struct Storage {
        static var _gazeBeganDate: Date? = nil
        static var _gazeMovedDate: Date? = nil
    }
    var gazeBeganDate: Date? {
        get {
            Storage._gazeBeganDate
        } set {
            Storage._gazeBeganDate = newValue
        }
    }
    var gazeMovedDate: Date? {
        get {
            Storage._gazeMovedDate
        } set {
            Storage._gazeMovedDate = newValue
        }
    }
    
    override var canReceiveGaze: Bool {
        return true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isHighlighted = true
        gazeBeganDate = Date()
        gazeMovedDate = Date()
    }
    
    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeMoved(gaze, with: event)
        
        if let gazeMovedDate = self.gazeMovedDate {
            let timeElapsed = Date().timeIntervalSince(gazeMovedDate)
            // TODO move this magic number to a more configurable location
            let gazeMovedGovernorDuration: TimeInterval = 0.25
            if timeElapsed >= gazeMovedGovernorDuration {
                sendActions(for: .gazeMoveInside)
                self.gazeMovedDate = Date()
            }
        }
        
        guard let beganDate = gazeBeganDate else {
            return
        }

        let timeElapsed = Date().timeIntervalSince(beganDate)
        if timeElapsed >= gaze.selectionHoldDuration {
            isSelected = true
            sendActions(for: .gazeEndInside)
            gazeBeganDate = nil
            (self.window as? HeadGazeWindow)?.animateCursorSelection()
        }
    }
    
    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeEnded(gaze, with: event)
        
        gazeBeganDate = nil
        isSelected = false
        isHighlighted = false
    }
    
    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeCancelled(gaze, with: event)
        isHighlighted = false
        isSelected = false
        gazeBeganDate = .distantFuture
    }
}

extension UIControl.Event {
    // TODO: what the heck rawValue should we have here
    static var gazeEndInside: UIControl.Event = .primaryActionTriggered
    static var gazeMoveInside: UIControl.Event = .init(rawValue: 78234)
}

extension UISwitch {
    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        addTarget(self, action: #selector(didSelectFromGaze(_:)), for: .gazeEndInside)
    }
    
    @objc func didSelectFromGaze(_ sender: UISwitch) {
        setOn(!isOn, animated: true)
    }
}

extension UISegmentedControl {
    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        addTarget(self, action: #selector(didSelectFromGaze(_:)), for: .gazeEndInside)
    }
    
    @objc func didSelectFromGaze(_ sender: UISegmentedControl) {
        guard selectedSegmentIndex != numberOfSegments - 1 else {
            selectedSegmentIndex = 0
            return
        }
        
        selectedSegmentIndex += 1
    }
}

extension UISlider {
    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        addTarget(self, action: #selector(didSelectFromGaze(_:)), for: .gazeMoveInside)
    }
    
    @objc func didSelectFromGaze(_ sender: UISlider) {
        guard value != maximumValue else {
            setValue(0, animated: true)
            return
        }
        
        setValue(value + 1, animated: true)
    }
    
}

