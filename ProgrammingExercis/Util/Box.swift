//
//  Box.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/10/21.
//

import Foundation

// A generic object type that allows binding
final class Box<T> {
    typealias Listener = (T) -> Void
    
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
