//
//  main.swift
//  Algorithms
//
//  Created by Tamás Oszkó on 2017. 08. 13..
//  Copyright © 2017. Tamás Oszkó. All rights reserved.
//

import Foundation


func doTestGraph() {
    
    let node1 = GraphNode(data: 1)
    let node2 = GraphNode(data: 2)
    let node3 = GraphNode(data: 3)
    let node4 = GraphNode(data: 4)
    let node5 = GraphNode(data: 5)
    
    _ = GraphBuilder<Int>()
        .node(node: node1)
        .node(node: node2)
        .node(node: node3)
        .node(node: node4)
        .node(node: node5)
        .edgeBetween(node1, node2, weight: 3)
        .edgeBetween(node1, node3, weight: 3)
        .edgeBetween(node1, node4, weight: 6)
        .edgeBetween(node2, node3, weight: 1)
        .edgeBetween(node2, node4, weight: 1)
        .edgeBetween(node2, node5, weight: 3)
        .edgeBetween(node3, node4, weight: 1)
        .edgeBetween(node4, node5, weight: 1)
        .edgeBetween(node1, node5, weight: 15.1)
        .build()
        let path = DijkstraSearch<Int>().pathFrom(node1, to: node5)
//    let path = AStarSearch<Int>(heuristic: { goal, next in
//        5 }) .pathFrom(node1, to: node5)

    
    let length = path?.map { $0.weight }.reduce(0, +) ?? 0
    print("lenght=\(length), paht=\(String(describing: path))")
    
}

doTestGraph()
