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
    
    // TODO: Does this work properly for more than 1 instance of UIControl?
    private struct Storage {
        static var _gazeBeganDate: Date? = nil
    }
    var gazeBeganDate: Date? {
        get {
            Storage._gazeBeganDate
        } set {
            Storage._gazeBeganDate = newValue
        }
    }
    
    override var canReceiveGaze: Bool {
        return true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isHighlighted = true
        gazeBeganDate = Date()
//        gazeMovedDate = Date()
    }
    
    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeMoved(gaze, with: event)
        
//        if let gazeMovedDate = self.gazeMovedDate {
//            let timeElapsed = Date().timeIntervalSince(gazeMovedDate)
//            // TODO move this magic number to a more configurable location
//            if timeElapsed >= gazeMovedDelay {
//                sendActions(for: .gazeMoveInside)
//
//                self.gazeMovedDate = Date()
//            }
//        }
        
        guard let beganDate = gazeBeganDate else {
            return
        }

        let timeElapsed = Date().timeIntervalSince(beganDate)
        if timeElapsed >= gaze.selectionHoldDuration {
            isSelected = true
            gazeBeganDate = nil
            (self.window as? HeadGazeWindow)?.animateCursorSelection()
            didSelectFromGaze()
        }
    }
    
    /// Simulates a touch event.  UIControl subclasses should override this function for custom behavior.
    @objc func didSelectFromGaze() {
        sendActions(for: .touchUpInside)
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
    @objc override func didSelectFromGaze() {
        guard value != maximumValue else {
            setValue(0, animated: true)
            return
        }

        setValue(value + 1, animated: true)
    }
}

