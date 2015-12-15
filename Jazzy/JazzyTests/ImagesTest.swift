//
//  ImagesTest.swift
//  Jazzy
//
//  Created by Oszkó Tamás on 07/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import XCTest
@testable import Jazzy

class ImagesTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        
        
        let url = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=jazzy%20radio"
        
        
        let expectation = expectationWithDescription("playListDownloader.download")
        let imgDownloader = ImagesDownloader(url: NSURL(string: url)!)
        imgDownloader.download { (images: [UIImage]?, error: NSError?) -> Void in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(60) { (error: NSError?) -> Void in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }


}
