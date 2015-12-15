//
//  PlayListTest.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 07/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import XCTest
@testable import Jazzy

class PlayListTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        let url = NSURL(string: "http://www.jazzy.hu/playlist.php")
        let playListDownloader = PlayListDownloader(url: url!)
        
        let expectation = expectationWithDescription("playListDownloader.download")
        
        var downloadedItems = [PlayListItem]()
        
        playListDownloader.download { (items: [PlayListItem]?, error: NSError?) -> Void in
            expectation.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            downloadedItems = items!
        }
        waitForExpectationsWithTimeout(60) { (error: NSError?) -> Void in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssert(downloadedItems.count == playListDownloader.maxCount, "")
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
