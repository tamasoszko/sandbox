//
//  PriorityQueue.swift
//  Algorithms
//
//  Created by Tamás Oszkó on 2017. 08. 13..
//  Copyright © 2017. Tamás Oszkó. All rights reserved.
//

import Foundation

public class PriorityQueue<T> {

    
    fileprivate var heap = Heap<T>(type: .min)

    public var isEmpty: Bool {
        return heap.isEmpty
    }
    public var size: Int {
        return heap.size
    }
    
    public func push(data: T, priority: Float) {
        heap.insert(data: data, value: priority)
    }
    
    public func pop() -> T? {
        return heap.extract()
    }
    
    public func peek() -> T? {
        return heap.top()
    }
}
