//
//  UIApplication+Util.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/11/21.
//

import UIKit

extension UIApplication {
    // A computed var that returns the top padding of current Application window
    var topPadding: CGFloat {
        let window = UIApplication.shared.windows[0]
        return window.safeAreaInsets.top
    }
}
