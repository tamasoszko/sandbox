//
//  Cryptor.swift
//  NetBank
//
//  Created by Oszkó Tamás on 18/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import Foundation


class Cryptor: NSObject {
    
    let key: NSData
    
    init(key: NSData) {
        self.key = key
    }
    
    func encryptData(data: NSData) -> NSData? {
        return Crypto.encryptData(data, withKey: key)
    }

    func decryptData(data: NSData) -> NSData? {
        return Crypto.decryptData(data, withKey: key)
    }

}