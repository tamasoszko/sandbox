//
//  Heap.swift
//  Algorithms
//
//  Created by Tamás Oszkó on 2017. 08. 12..
//  Copyright © 2017. Tamás Oszkó. All rights reserved.
//

import Foundation


fileprivate class HeapItem<T> : Equatable, Hashable {

    let value: Float
    let data: T

    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    init(data: T, value: Float) {
        self.value = value
        self.data = data
    }
    
    public static func ==(lhs: HeapItem, rhs: HeapItem) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

public enum HeapType {
    case min, max
}

public class Heap<T>: CustomDebugStringConvertible {

    public let type: HeapType
    fileprivate var items = [HeapItem<T>]()
    
    public var debugDescription: String {
        
        let values = items.map { $0.value }
        return "<Heap: \(values)>"
    }
    
    init(type: HeapType = .max) {
        self.type = type
    }
    
    public var size: Int {
        return items.count
    }
    
    public var isEmpty: Bool {
        return items.isEmpty
    }
    
    public func insert(data: T, value: Float) {
        let item = HeapItem<T>(data: data, value: value)
        items.append(item)
        var index = items.count - 1
        while index > 0 {
            let parent = parentOf(index)
            if !isInOrder(parent: items[parent], child: items[index]) {
                swap(&items[index], &items[parent])
            }
            index = parent
        }
    }
    
    public func extract() -> T? {
        guard items.count > 0 else {
            return nil
        }
        let top = items.remove(at: 0)
        if items.count > 0 {
            let last = items.remove(at: items.count-1)
            items.insert(last, at: 0)
            heapify(index: 0)
        }
        return top.data
    }
    
    public func top() -> T? {
        return items.first?.data
    }
    
    fileprivate func parentOf(_ index: Int) -> Int {
        return (index + 1) / 2 - 1
    }
    
    fileprivate func leftOf(_ index: Int) -> Int {
        return (index + 1) * 2 - 1
    }
    
    fileprivate func rightOf(_ index: Int) -> Int {
        return (index + 1) * 2 + 1
    }
    
    fileprivate func isInOrder(parent: HeapItem<T>, child: HeapItem<T>) -> Bool {
        if type == .max {
            return parent.value >= child.value
        } else {
            return parent.value <= child.value
        }
    }
    
    fileprivate func heapify(index: Int) {
        let left = index * 2 + 1
        let right = index * 2 + 2
        var largest = index
        
        if left < size && !isInOrder(parent: items[largest], child: items[left]) {
            largest = left
        }
        if right < size && !isInOrder(parent: items[largest], child: items[right]) {
            largest = right
        }
        if largest != index {
            swap(&items[largest], &items[index])
            heapify(index: largest)
        }
    }
}

extension Heap {
    
    func isValid() -> Bool {
        for i in 0..<items.count {
            let left = leftOf(i)
            let right = rightOf(i)
            let parent = parentOf(i)
            if i > 0 {
                if !isInOrder(parent: items[parent], child: items[i]) {
                    return false
                }
            }
            if left < items.count - 1 {
                if !isInOrder(parent: items[i], child: items[left]) {
                    return false
                }
            }
            if right < items.count - 1 {
                if !isInOrder(parent: items[i], child: items[right]) {
                    return false
                }
            }
        }
        return true
    }
}
