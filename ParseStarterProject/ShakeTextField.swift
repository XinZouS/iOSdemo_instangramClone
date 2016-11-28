//
//  ShakeTextField.swift
//  ParseStarterProject-Swift
//
//  Created by Xin Zou on 11/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ShakeTextField : UITextField {
    
    func shake(duration: TimeInterval, repeatCount: Float) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        animation.toValue   = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        
        self.layer.add(animation, forKey: "position")
    }
    
}
