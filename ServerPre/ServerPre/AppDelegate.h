//
//  AppDelegate.h
//  ServerPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Cocoa/Cocoa.h>



// 2014/10/12 14:13:16
struct MousePadData {
    CGPoint mousePoint;
    int mouseEventType;
    bool left;
    bool right;
    bool center;
    
    Byte keySlots[8];
};

typedef struct MousePadData MousePadData;


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

