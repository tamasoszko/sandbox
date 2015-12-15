//
//  ViewAnimators.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 08/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation
import UIKit

public class LabelAnimator : NSObject{
    
    private var context = 0
    let blinkAnimationDuration = 0.33
    weak var label : UILabel?
    var scheduler : Scheduler?
    var blinkOnTextChange = true
    
    init(label : UILabel) {
        super.init()
        self.label = label
        self.scheduler = Scheduler(obj: label)
        self.label?.addObserver(self, forKeyPath: "text", options: .Old, context: &context)
    }
    
    deinit {
        self.label?.removeObserver(self, forKeyPath: "text", context: &context)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &self.context {
            if let oldValue = change?[NSKeyValueChangeOldKey] as! String! {
                if oldValue != self.label!.text && self.blinkOnTextChange {
                    self.blink()
                    scheduler!.start(3 * blinkAnimationDuration, handler: { (obj: AnyObject, count: NSInteger) -> Void in
                        if count < 5 {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.blink()
                            })
                        } else {
                            self.scheduler!.stop()
                        }
                    })
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func blink() {
        UIView.animateWithDuration(blinkAnimationDuration, animations: { () -> Void in
            if let label = self.label {
                label.alpha = 0
            }
            }, completion: { (finishe: Bool) -> Void in
                UIView.animateWithDuration(self.blinkAnimationDuration, animations: { () -> Void in
                    if let label = self.label {
                        label.alpha = 1
                    }
                })
        })
    }
    
}

