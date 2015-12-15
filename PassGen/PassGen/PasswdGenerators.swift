//
//  PasswdGenerator.swift
//  PassGen
//
//  Created by Oszkó Tamás on 06/12/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import Foundation
import Security


protocol PasswdGenerator {

    func generate(count: Int) -> String?
}

class SimplePasswdGenerator : PasswdGenerator {
    
    let Alphabet = "abcdefghijklmnopqrstvwuxyzABCDEFGHIJKLMNOPQRSTVWUXYZ1234567890-_!#*;,./"
    
    func generate(count: Int) -> String? {
        var randomBytes = [UInt8](count: count, repeatedValue: 0)
        SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
        
        var passwd = ""
        for var i = 0; i < count; i++ {
            let b = randomBytes[i]
            let index = Int(b) % Alphabet.characters.count
            passwd += String(Alphabet[Alphabet.startIndex.advancedBy(index)])
        }
        return passwd
    }
    
}


