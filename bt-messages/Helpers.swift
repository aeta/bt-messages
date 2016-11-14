//
//  Dispatch.swift
//  APSwiftHelpers
//
//  https://github.com/alexpls/APSwiftHelpers
//

import Foundation

/**
 Perform a block on the specified queue. This is just a nicer wrapper around the dispatch_async()
 Grand Central Dispatch function.
 - Parameter queueType:  The queue to execute the block on
 - Parameter closure:    The block to execute
 *Example usage:*
 ```
 performOn(.Main) { self.tableView.reloadData() }
 ```
 */
public func performOn(_ queueType: QueueType, closure: @escaping () -> Void) {
    queueType.queue.async(execute: closure)
}

/**
 Perform a block on a queue after waiting the specified time.
 - Parameter delay:     Time to wait in seconds before performing the block
 - Parameter queueType: Queue to execute the block on (default is the main queue)
 - Parameter closure:   Block to execute after the time specified in delay has passed
 *Example usage:*
 ```
 // Wait for 200ms then run the block on the main queue
 delay(0.2) { alert.hide() }
 // Wait for 1s then run the block on a background queue
 delay(1.0, queueType: .Background) { alert.hide() }
 ```
 */
public func delay(_ delay: TimeInterval, queueType: QueueType = .main, closure: @escaping () -> Void) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    queueType.queue.asyncAfter(deadline: time, execute: closure)
}

/**
 A wrapper around GCD queues. This shouldn't be accessed directly, but rather through
 the helper functions supplied by the APSwiftHelpers package.
 */
public enum QueueType {
    case main
    case background
    case lowPriority
    case highPriority
    
    var queue: DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main
        case .background:
            return DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        case .lowPriority:
            return DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low)
        case .highPriority:
            return DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high)
        }
    }
}
