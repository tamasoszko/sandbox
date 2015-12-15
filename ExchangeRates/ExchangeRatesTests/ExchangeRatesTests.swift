//
//  ExchangeRatesTests.swift
//  ExchangeRatesTests
//
//  Created by Oszkó Tamás on 21/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import XCTest
@testable import ExchangeRates

class ExchangeRatesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRandomRates() {
        
        let expectation = expectationWithDescription("expectation")
        let ratesDownloader = RandomRatesDownloader(currencyFrom: "RND", base: 100, chg: 20)
        
        ratesDownloader.getRates { (rates: [Rate]?, error: NSError?) -> () in
            XCTAssertNil(error)
            XCTAssertEqual(30, rates?.count)
            for var i = 0; i < rates?.count; i++ {
                let rate = rates![i]
                XCTAssertGreaterThan(rate.value.doubleValue, 99.99)
                XCTAssertLessThan(rate.value.doubleValue, 119.99)
                XCTAssertEqual("HUF", rate.currencyTo)
                XCTAssertEqual("RND", rate.currencyFrom)
            }
            expectation.fulfill()
        }
        
        
        waitForExpectationsWithTimeout(60) { (error: NSError?) -> Void in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testMNBRates() {
        
        let expectation = expectationWithDescription("expectation")
        let ratesDownloader = MNBRatesDownloader(currency: "EUR")
        
        ratesDownloader.getRates { (rates: [Rate]?, error: NSError?) -> () in
            XCTAssertNil(error)
            XCTAssert(rates?.count > 0)
            for var i = 0; i < rates?.count; i++ {
                let rate = rates![i]
                XCTAssertGreaterThan(rate.value.doubleValue, 0.0)
                XCTAssertLessThan(rate.value.doubleValue, 999.99)
                XCTAssertEqual("HUF", rate.currencyTo)
                XCTAssertEqual("EUR", rate.currencyFrom)
            }
            expectation.fulfill()
        }
        
        
        waitForExpectationsWithTimeout(60) { (error: NSError?) -> Void in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
