//
//  ServerPreTests.m
//  ServerPreTests
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"

#import "TimeMine.h"


@interface ServerPreTests : XCTestCase

@end

@implementation ServerPreTests

AppDelegate *appDel;

- (void)setUp {
    [super setUp];
    appDel = [[AppDelegate alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 キーの入力
 */
- (void) testKeyEntered {
    [appDel setState:BONJOUR_RECEIVER_ACCEPTED_IOS];
    
    CGPoint point;
    point.x = 100;
    point.y = 100;
    
    int type = 0;
    
    
    struct MousePadData mousePadData;
    mousePadData.mousePoint = point;
    mousePadData.mouseEventType = type;
    
    NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
//    [appDel execute:data];

    
    XCTAssert(false, @"not yet applied");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



@end
