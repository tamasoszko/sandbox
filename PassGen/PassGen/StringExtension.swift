//
//  StringExtension.swift
//  PassGen
//
//  Created by Oszkó Tamás on 07/12/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation


extension String {
    
    func sensitiveString() -> String {
        var ret = ""
        for var i = 0; i < self.characters.count; i++ {
            ret += "*"
        }
        return ret
    }
    
}