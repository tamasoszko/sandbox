//
//  JazzyTests.m
//  JazzyTests
//
//  Created by Oszkó Tamás on 02/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface JazzyTests : XCTestCase

@end

@implementation JazzyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHtmlParser {
    
    NSString* txt = @"<table cellpadding=\"2\" cellspacing=\"2\" border=\"0\"><tr>\n<td>12:34</td>\n<td>Lee Ritenour and Chris Botti</td>\n<td>Papa Was A Rolling Stone</td>\n</tr><tr>\n<td>10:59</td>\n<td>Szekszárd Junior Stars</td>\n<td>Zug Blues</td>\n</tr><tr>";
    
    NSDateFormatter* df = [NSDateFormatter new];
    df.dateFormat = @"HH:mm";
    df.defaultDate = [NSDate date];
    
//    
//    NSArray<PlayListItem*>* expItems = @[
//                    [[PlayListItem alloc] initWithDate:[df dateFromString:@"12:34"] title:@"Papa Was A Rolling Stone" artist:@"Lee Ritenour and Chris Botti"],
//                    [[PlayListItem alloc] initWithDate:[df dateFromString:@"10:59"] title:@"Zug Blues" artist:@"Szekszárd Junior Stars"]];
//    
//    NSCalendar* cal = [NSCalendar currentCalendar];
//    id<PlayListParser> parser = [PlayListParsers htmlParser];
//    NSArray<PlayListItem*>* items = [parser parseData:[txt dataUsingEncoding:NSUTF8StringEncoding]];
//    XCTAssertNotNil(items);
//    XCTAssertEqual(expItems.count, items.count);
//    for(NSInteger i = 0; i < expItems.count; i++) {
//        PlayListItem* expItem = expItems[i];
//        PlayListItem* item = items[i];
//        
//        NSDateComponents* expDateComp = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:expItem.date];
//        NSDateComponents* dateComp = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:item.date];
//        
//        XCTAssertEqual([expDateComp day], [dateComp day]);
//        XCTAssertEqual([expDateComp hour], [dateComp hour]);
//        XCTAssertEqual([expDateComp minute], [dateComp minute]);
//        XCTAssertTrue([expItem.title isEqual:item.title]);
//        XCTAssertTrue([expItem.artist isEqual:item.artist]);
//    }
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
