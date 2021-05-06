//
//  Protected.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/14/21.
//

import Foundation

// simple lock implementation for dealing with concurrently writing/reading to the same object from different threads
class ReadWriteLock {
    private let queue: DispatchQueue

    init(label: String) {
        queue = DispatchQueue(label: label, attributes: .concurrent) // (1)
    }

    func read<T>(closure: () -> T) -> T {
        return queue.sync { // (2)
            closure()
        }
    }

    func write(closure: @escaping () -> Void) {
        // using the barrier flag ensures that no
        // other operation will run during a write
        queue.async(flags: .barrier) { // (3)
            closure()
        }
    }
}

// A custom thread safe generic type that can be used across the app
class Protected<Resource: Any> {
    private let lock: ReadWriteLock
    private var resource: Resource

    init(resource: Resource) {
        self.lock = ReadWriteLock(label: "\(Resource.self)")
        self.resource = resource
    }

    func read() -> Resource {
        return lock.read {
            self.resource
        }
    }

    func mutate(closure: @escaping (Resource) -> Resource) {
        lock.write {
            self.resource = closure(self.resource)
        }
    }
}
