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


- (void) testMouseEntered {
    [appDel setState:BONJOUR_RECEIVER_ACCEPTED_IOS];
    
    // 現在のマウス位置を取得
    NSPoint mousePoint = [NSEvent mouseLocation];
    
    // タッチ開始イベント
    {
        CGPoint point;
        point.x = mousePoint.x;
        point.y = mousePoint.y;
        
        struct MousePadData mousePadData;
        mousePadData.mousePoint = point;
        mousePadData.mouseEventType = 0;
        
        NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
        [appDel execute:data];
    }
    
    // タッチ移動のイベント
    {
        CGPoint point;
        point.x = mousePoint.x + 1;
        point.y = mousePoint.y + 1;
        
        struct MousePadData mousePadData;
        mousePadData.mousePoint = point;
        mousePadData.mouseEventType = 1;
        
        NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
        [appDel execute:data];
    }
    
//    マウスの位置が差100,100に来てる
    NSPoint finalMousePoint = [NSEvent mouseLocation];
    XCTAssert(finalMousePoint.x == mousePoint.x + 1, @"not match, %f", mousePoint.x - finalMousePoint.x);
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/13 17:14:50" withLimitSec:1000000 withComment:@"ポイントマッチしなかった"];
}

/**
 マウスのボタン入力を行う
 */
- (void) testMouseButtonEntered {
    
    [appDel setState:BONJOUR_RECEIVER_ACCEPTED_IOS];
    
    // right
    {
        CGPoint point;
        point.x = 0;
        point.y = 0;
        
        int type = 0;
        
        struct MousePadData mousePadData;
        mousePadData.mousePoint = point;
        mousePadData.mouseEventType = type;
        mousePadData.right = true;
        
        NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
//        [appDel execute:data];
        
        XCTAssert([appDel isRightClicking], @"not right click on");
    }
    
    // left
    {
        CGPoint point;
        point.x = 0;
        point.y = 0;
        
        int type = 0;
        
        struct MousePadData mousePadData;
        mousePadData.mousePoint = point;
        mousePadData.mouseEventType = type;
        mousePadData.left = true;
        
        NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
//        [appDel execute:data];
        
        XCTAssert([appDel isLeftClicking], @"not right click on");
    }
    
    // center
    {
        CGPoint point;
        point.x = 0;
        point.y = 0;
        
        int type = 0;
        
        struct MousePadData mousePadData;
        mousePadData.mousePoint = point;
        mousePadData.mouseEventType = type;
        mousePadData.center = true;
        
        NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
//        [appDel execute:data];
        
        XCTAssert([appDel isCenterClicking], @"not right click on");
    }
    
    // combination
    {
        CGPoint point;
        point.x = 0;
        point.y = 0;
        
        int type = 0;
        
        struct MousePadData mousePadData;
        mousePadData.mousePoint = point;
        mousePadData.mouseEventType = type;
        mousePadData.left = true;
        mousePadData.right = true;
        
        NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(mousePadData)];
//        [appDel execute:data];
        
        XCTAssert([appDel isRightClicking], @"not right click on");
        XCTAssert([appDel isLeftClicking], @"not right click on");
        XCTAssert([appDel isCenterClicking], @"not right click on");
    }
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
