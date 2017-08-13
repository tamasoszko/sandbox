//
//  Graphs.swift
//  Algorithms
//
//  Created by Tamás Oszkó on 2017. 08. 12..
//  Copyright © 2017. Tamás Oszkó. All rights reserved.
//

import Foundation


public class Edge<T>: CustomDebugStringConvertible  {
    weak var from: GraphNode<T>!
    weak var to: GraphNode<T>!
    let weight: Float
    
    public var debugDescription: String {
        return "<Edge: from=\(String(describing: from.data)), to=\(String(describing: to.data)), weight=\(weight)>"
    }
    
    init(from: GraphNode<T>!, to: GraphNode<T>, weight: Float) {
        self.from = from
        self.to = to
        self.weight = weight
    }
}

public class Node<T> : Hashable, Equatable, CustomDebugStringConvertible {
    
    let data: T?
    
    public var debugDescription: String {
        return "<Node: id=\(UInt(bitPattern: ObjectIdentifier(self)))>"
    }
    
    init(data: T?) {
        self.data = data
    }
    
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    public static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }    
}

public class GraphNode<T> : Node<T> {
    
    fileprivate var edges = [Edge<T>]()
    
    public var neighbours: [GraphNode<T>] {
        return edges.map{ $0.to }
    }
    
    fileprivate func edgeTo(_ to: GraphNode<T>) -> Edge<T>? {
        let edge = edges.first {
            $0.to == to
        }
        if let edge = edge {
            return edge
        }
        return nil
    }
    
    override public var debugDescription: String {
        return "<GraphNode: id=\(String(describing: data)): edges=\(edges)>"
    }
}

public protocol GraphPathSearching {
    associatedtype T
    func pathFrom(_ from: GraphNode<T>, to: GraphNode<T>) -> [Edge<T>]?
}


public class Graph<T> : CustomDebugStringConvertible {
    fileprivate var nodes: [GraphNode<T>]
        
    init(nodes: [GraphNode<T>]) {
        self.nodes = nodes
    }
    
    public var debugDescription: String {
        return "<Graph: nodes=\(nodes)>"
    }
}

public class GraphBuilder<T> {
    var nodes = [GraphNode<T>]()
    
    func node(node: GraphNode<T>) -> GraphBuilder<T> {
        nodes.append(node)
        return self
    }
    
    func edgeBetween(_ node1: GraphNode<T>, _ node2: GraphNode<T>, weight: Float) -> GraphBuilder<T> {
        guard nodes.contains(node1) && nodes.contains(node2) else {
            print("Warning: edge not added, add node to grap first!")
            return self
        }
        return edge(from: node1, to: node2, weight: weight)
            .edge(from: node2, to: node1, weight: weight)
        
    }
    
    func edge(from: GraphNode<T>, to: GraphNode<T>, weight: Float) -> GraphBuilder<T> {
        if from != to {
            from.edges.append(Edge(from: from, to: to, weight: weight))
        }
        return self
    }
    
    func build() -> Graph<T> {
        return Graph(nodes: nodes)
    }
}

public class BfSearch<T>: GraphPathSearching {
    
    public func pathFrom(_ from: GraphNode<T>, to: GraphNode<T>) ->[Edge<T>]? {
        var toProcess = [GraphNode<T>]()
        var visited = Set<GraphNode<T>>()
        var pathFrom = [AnyHashable: Edge<T>]()
        
        toProcess.append(from)
        pathFrom[from] = nil
        while !toProcess.isEmpty {
            let node = toProcess.remove(at: 0)
            if node == to {
                var path = [Edge<T>]()
                var item = node
                while item != from {
                    let edge = pathFrom[item]!
                    path.append(edge)
                    item = edge.from!
                }
                return path.reversed()
            }
            for edge in node.edges {
                let neighbour = edge.to!
                if visited.insert(neighbour).inserted {
                    pathFrom[neighbour] = edge
                    toProcess.append(neighbour)
                }
            }
        }
        return nil
    }
}

public class DijkstraSearch<T>: GraphPathSearching {

    public func pathFrom(_ from: GraphNode<T>, to: GraphNode<T>) ->[Edge<T>]? {
        
        let toProcess = PriorityQueue<GraphNode<T>>()
        var pathFrom = [AnyHashable: Edge<T>]()
        var costOf = [AnyHashable: Float]()
        
        toProcess.push(data: from, priority: 0)
        pathFrom[from] = nil
        costOf[from] = 0
        
        while !toProcess.isEmpty {
            let node = toProcess.pop()!
            if node == to {
                var path = [Edge<T>]()
                var item = node
                while item != from {
                    let edge = pathFrom[item]!
                    path.append(edge)
                    item = edge.from!
                }
                return path.reversed()
            }
            for edge in node.edges {
                let next = edge.to!
                let newCost = costOf[node]! + edge.weight
                if costOf[next] == nil || newCost < costOf[next]! {
                    costOf[next] = newCost
                    pathFrom[next] = edge
                    toProcess.push(data: next, priority: newCost)
                }
            }
        }
        return nil
    }
}

public class AStarSearch<T>: GraphPathSearching {
    
    typealias Heuristic = (_: GraphNode<T>, _: GraphNode<T>)->Float
    
    let heuristic: Heuristic
    
    init(heuristic: @escaping Heuristic) {
        self.heuristic = heuristic
    }
    
    public func pathFrom(_ from: GraphNode<T>, to: GraphNode<T>) ->[Edge<T>]? {
        
        let toProcess = PriorityQueue<GraphNode<T>>()
        var pathFrom = [AnyHashable: Edge<T>]()
        var costOf = [AnyHashable: Float]()
        
        toProcess.push(data: from, priority: 0)
        pathFrom[from] = nil
        costOf[from] = 0
        
        while !toProcess.isEmpty {
            let node = toProcess.pop()!
            if node == to {
                var path = [Edge<T>]()
                var item = node
                while item != from {
                    let edge = pathFrom[item]!
                    path.append(edge)
                    item = edge.from!
                }
                return path.reversed()
            }
            for edge in node.edges {
                let next = edge.to!
                let newCost = costOf[node]! + edge.weight
                if costOf[next] == nil || newCost < costOf[next]! {
                    costOf[next] = newCost
                    pathFrom[next] = edge
                    let priority = heuristic(to, next)
                    toProcess.push(data: next, priority: priority)
                }
            }
        }
        return nil
    }
}




