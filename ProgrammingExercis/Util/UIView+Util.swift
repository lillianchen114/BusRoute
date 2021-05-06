//
//  UIView+Util.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/11/21.
//

import UIKit

extension UIView {
    static let defaultSystemSpacing: CGFloat = 8.0
    
    static let defaultAnimationDuration: TimeInterval = 0.5
    
    // A convenient method that animates the showing/hiding of any UIView
    func animateShowing(show: Bool) {
        if show {
            self.isHidden = false
        }
        UIView.animate(withDuration: UIView.defaultAnimationDuration) {
            self.alpha = show ? 1 : 0
        } completion: { _ in
            if !show {
                self.isHidden = true
            }
        }
    }
}
