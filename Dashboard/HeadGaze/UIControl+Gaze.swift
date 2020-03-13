//
//  VocableUIControl.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension UIControl {
    
    private struct Storage {
        // TODO: use associated objects for gaze began and gaze moved dates to allow for different values
        // for different instances
        static var _gazeBeganDate: Date? = nil
        static var _lastGazeMovedDate: Date? = nil
        static var _gazeMovedDelay: TimeInterval = 1
        static var _gazeMovedFrequency: TimeInterval = 0.5
    }
    private var gazeBeganDate: Date? {
        get {
            Storage._gazeBeganDate
        } set {
            Storage._gazeBeganDate = newValue
        }
    }
    private var lastGazeMovedDate: Date? {
        get {
            Storage._lastGazeMovedDate
        } set {
            Storage._lastGazeMovedDate = newValue
        }
    }
    var gazeMovedDelay: TimeInterval? {
        get {
            return objc_getAssociatedObject(self, &Storage._gazeMovedDelay) as? TimeInterval
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Storage._gazeMovedDelay, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var gazeMovedFrequency: TimeInterval? {
        get {
            return objc_getAssociatedObject(self, &Storage._gazeMovedFrequency) as? TimeInterval
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Storage._gazeMovedFrequency, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override var canReceiveGaze: Bool {
        return true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isHighlighted = true
        gazeBeganDate = Date()
        lastGazeMovedDate = gazeBeganDate
    }
    
    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeMoved(gaze, with: event)
        
        guard let beganDate = gazeBeganDate else {
            return
        }

        let now = Date()
        
        let timeSinceGazeBegan = now.timeIntervalSince(beganDate)
        
        if let gazeMovedDelay = gazeMovedDelay,
            timeSinceGazeBegan >= gazeMovedDelay,
            let lastGazeMovedDate = lastGazeMovedDate,
            let gazeMovedFrequency = gazeMovedFrequency,
            now.timeIntervalSince(lastGazeMovedDate) >= gazeMovedFrequency {
            gazeMovedInside()
            self.lastGazeMovedDate = now
        }
        
        if timeSinceGazeBegan >= gaze.selectionHoldDuration, !isSelected {
            isSelected = true
            (self.window as? HeadGazeWindow)?.animateCursorSelection()
            didSelectFromGaze()
        }
    }
    
    /// No-op.  UIControl subclasses should override this function for custom behavior.
    @objc func gazeMovedInside() { }
    
    /// Simulates a touch event.  UIControl subclasses should override this function for custom behavior.
    @objc func didSelectFromGaze() {
        sendActions(for: .touchUpInside)
    }
    
    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeEnded(gaze, with: event)
        print("gaze ended")
        
        gazeBeganDate = nil
        lastGazeMovedDate = nil
        isSelected = false
        isHighlighted = false
    }
    
    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeCancelled(gaze, with: event)
        print("gaze cancelled")
        isHighlighted = false
        isSelected = false
        gazeBeganDate = .distantFuture
    }
}

extension UIButton {
    @objc override func didSelectFromGaze() {
        sendActions(for: .touchUpInside)
    }
}

extension UISwitch {
    @objc override func didSelectFromGaze() {
        setOn(!isOn, animated: true)
    }
}

extension UISegmentedControl {
    @objc override func didSelectFromGaze() {
        guard selectedSegmentIndex != numberOfSegments - 1 else {
            selectedSegmentIndex = 0
            return
        }
        
        selectedSegmentIndex += 1
    }
}

extension UISlider {
    @objc override func gazeMovedInside() {
        guard value != maximumValue else {
            setValue(0, animated: true)
            return
        }

        setValue(value + 1, animated: true)
    }
}
