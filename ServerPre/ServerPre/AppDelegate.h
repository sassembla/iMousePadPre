//
//  AppDelegate.h
//  ServerPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Cocoa/Cocoa.h>



struct MousePadData {
    CGPoint mousePoint;
    int mouseEventType;
    bool left;
    bool right;
    bool center;
    
    Byte key0;
    Byte key1;
    Byte key2;
    Byte key3;
    Byte key4;
    Byte key5;
    Byte key6;
    Byte key7;
};


typedef NS_ENUM(int, BONJOUR_RECEIVER_STATE) {
    BONJOUR_RECEIVER_FAILED_OPEN_PORT,
    BONJOUR_RECEIVER_FAILED_OPEN_BONJOUR,
    BONJOUR_RECEIVER_FAILED_PUBLISH_BONJOUR,
    BONJOUR_RECEIVER_ACCEPTED_IOS
};

@interface AppDelegate : NSObject <NSApplicationDelegate, NSPortDelegate, NSNetServiceDelegate, NSUserNotificationCenterDelegate>

- (NSWindow *)window;
- (void) setState:(int)nextState;
- (void) execute:(NSData *)data;


- (bool) isRightClicking;
- (bool) isLeftClicking;
- (bool) isCenterClicking;

@end

