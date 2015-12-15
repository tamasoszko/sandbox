//
//  NetBankTests.swift
//  NetBankTests
//
//  Created by Oszkó Tamás on 29/03/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit
import XCTest
import NetBank

class NetBankTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCryptoDataEmpty() {
//        cryptoTestWithDataLength(0)
    }
    
    func testCryptoDataSmall() {
        cryptoTestWithDataLength(7)
    }

    func testCryptoDataBlockSize() {
        cryptoTestWithDataLength(16)
    }

    func testCryptoDataLarge() {
        cryptoTestWithDataLength(27)
    }
    
    func testCryptoDataMultiBlockSize() {
        cryptoTestWithDataLength(16*4)
    }
    
    
    func testCryptoStringEmpty() {
//        cryptoTestWithStringLength(0)
    }
    
    func testCryptoStringSmall() {
        cryptoTestWithStringLength(7)
    }
    
    func testCryptoStringBlockSize() {
        cryptoTestWithStringLength(16)
    }
    
    func testCryptoStringLarge() {
        cryptoTestWithStringLength(27)
    }
    
    func testCryptoStringMultiBlockSize() {
        cryptoTestWithStringLength(16*4)
    }
    
    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func cryptoTestWithDataLength(length: Int) {
        var plain = Crypto.generateRandomBytes(length)
        var key = Crypto.generateRandomBytes(Crypto.keyLengthAes256())
        
        var cryptor = Cryptor(key: key)
        var cipher = cryptor.encryptData(plain)
        var decyptedCipher = cryptor.decryptData(cipher!)
        XCTAssertEqual(plain!, decyptedCipher!, "Decrypted text differs from plain")
    }
    
    func cryptoTestWithStringLength(length: Int) {
        var plain = ""
        for var i = 0; i < length; i++ {
            plain = plain + "a"
        }
        var key = Crypto.generateRandomBytes(Crypto.keyLengthAes256())
        var cryptor = Cryptor(key: key)
        var cipher = cryptor.encryptData(NSData(base64EncodedString: plain, options: NSDataBase64DecodingOptions(0))!)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
        var decyptedCipher = cryptor.decryptData(NSData(base64EncodedString: cipher, options: NSDataBase64DecodingOptions(0))!)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
        XCTAssertEqual(plain, decyptedCipher!, "Decrypted text differs from plain")
    }
}
