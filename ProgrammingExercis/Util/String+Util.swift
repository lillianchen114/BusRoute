//
//  String+Util.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/14/21.
//

import Foundation

extension String {
    // A computed variable that returns the string by removing some html tags
    var removedHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
