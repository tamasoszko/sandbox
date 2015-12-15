//
//  ViewAnimator.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 08/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation
import UIKit


public class Scheduler : NSObject {
    
    var timeout = 1.0
    weak var obj : AnyObject?
    var timer : NSTimer?
    var handler : ((AnyObject, NSInteger)->Void)?
    var count = 0
    
    init(obj: AnyObject) {
        self.obj = obj
    }
    
    public func start(timeout: Double, handler: (AnyObject, NSInteger)->Void) {
        count = 0;
        self.timeout = timeout
        self.handler = handler
        timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector:"onTimer:", userInfo: nil, repeats: true)
    }
    
    public func stop() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func onTimer(timer:NSTimer!) {
        doHandle()
    }
    
    func doHandle() {
        if let handler = self.handler, obj = self.obj {
            handler(obj, self.count)
            self.count++;
        }
    }
    
    
}
