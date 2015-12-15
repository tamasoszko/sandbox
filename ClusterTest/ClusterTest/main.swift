//
//  main.swift
//  ClusterTest
//
//  Created by Oszkó Tamás on 15/08/15.
//  Copyright (c) 2015 Oszi. All rights reserved.
//

import Foundation

println("Hello, World!")


//: Playground - noun: a place where people can play

//import UIKit

var str = "Hello, playground"

let a = "a"

struct Point : Printable {
    let x: Int
    let y: Int

    var description: String {
        get {
            return "Point: x=\(x), y=\(y)"
        }
    }
    
    func distFrom(point: Point) -> Int{
        let dx = self.x - point.x
        let dy = self.y - point.y
        return Int(sqrt(Float(dx * dx) + Float(dy * dy)))
    }
}

struct Size: Printable {
    let w: Int
    let h: Int
    
    var description: String {
        get {
            return "Size: w=\(w), h=\(h)";
        }
    }
}

class Object : Printable {
    
    let pos: Point
    let size: Size
    let center: Point
    var r = 0.0
    
    var description: String {
        get {
            return "Object: center=\(center)"
        }
    }
    
    init(pos: Point, size: Size) {
        self.pos = pos
        self.size = size
        self.center = Point(x: pos.x + size.w / 2, y: pos.y + size.h / 2)
    }
}

class Cluster: Printable {
    var center = Point(x: 0, y: 0)
    var objects = [Object]()
    
    var description: String {
        get {
            var str = "Cluster: center=\(center)"
            str +=  "\nobjects=[\n"
            for object in objects {
                str += "\t"
                str += "\(object)"
                str += "\n"
            }
            str += "]"
            return str
        }
    }
    
    init() {
    }
    
    func alike(object: Object, treshold: Int) -> Float {
        let dist = center.distFrom(object.center)
        // Todo implement
        if dist > treshold {
            return 0.4
        } else {
            return 0.6
        }
    }
    
    func add(object: Object) {
        objects.append(object)
        center = centerOf(objects)
    }
    
    private func centerOf(objects: [Object]) -> Point {
        var x = 0
        var y = 0
        for obj in objects {
            x += obj.pos.x
            y += obj.pos.y
        }
        x = x / objects.count
        y = y / objects.count
        return Point(x: x, y: y)
    }    
}

var canvas = Size(w: 1000, h: 1000)
var minObject = Size(w: 10, h: 10)
var maxObject = Size(w: 50, h: 50)


func randomObjectProperties() -> (x: Int, y: Int, w: Int, h: Int) {
    var x = arc4random_uniform(UInt32(canvas.w - 2 * maxObject.w))
    var y = arc4random_uniform(UInt32(canvas.h - 2 * maxObject.h))
    var w = arc4random_uniform(UInt32(maxObject.w - minObject.w)) + UInt32(minObject.w)
    var h = arc4random_uniform(UInt32(maxObject.h - minObject.h)) + UInt32(minObject.h)
    return(Int(x), Int(y), Int(w), Int(h))
}

func createObjects(count: Int) -> [Object] {
    var objects = [Object]()
    for i in 0...count {
        let rand = randomObjectProperties()
        objects.append(Object(pos: Point(x: rand.x, y: rand.y), size: Size(w: rand.w, h: rand.h)))
    }
    return objects
}

func analyzeObjects(objects: [Object]) -> (minDist: Int, maxDist: Int, avgDist: Int) {
    var minDist: Int?
    var maxDist: Int?
    var sumDist = 0
    for i in 0...objects.count-2 {
        let obj = objects[i]
        for j in i+1...objects.count-1 {
            let obj2 = objects[j]
            let dist = obj.center.distFrom(obj2.center)
            sumDist = sumDist + dist
//            println("dist of \(obj) and \(obj2) is \(dist)")
            if minDist == nil || dist < minDist {
                minDist = dist
            }
            if maxDist == nil || dist > maxDist {
                maxDist = dist
            }
        }
    }
    let count = objects.count * (objects.count-1)
    return (minDist!, maxDist!, sumDist/(count/2))
}

func makeClusters(objects: [Object], treshold: Int) -> [Cluster]{
    var clusters = [Cluster]()
    for object in objects {
        var bestCluster : Cluster?
        var bestAlike : Float = 0.0
        for cluster in clusters {
            let alike = cluster.alike(object, treshold: treshold)
//            println("alike=\(alike)")
            if(bestCluster == nil) {
                bestCluster = cluster
                bestAlike = alike
            } else {
                if(alike > bestAlike) {
                    bestAlike = alike
                    bestCluster = cluster
                }
            }
        }
        if(bestCluster == nil || bestAlike < 0.5) {
            bestCluster = Cluster()
            clusters.append(bestCluster!)
        }
        bestCluster!.add(object)
    }
    return clusters
}

let objects = createObjects(5)

let minMax = analyzeObjects(objects)
println("minDist=\(minMax.minDist), maxDist=\(minMax.maxDist), avgDist=\(minMax.avgDist)")

let clusters = makeClusters(objects, minMax.avgDist - minMax.minDist)

for cluster in clusters {
    println("\(cluster)\n")
}

































