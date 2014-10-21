//
//  AppDelegate.h
//  ServerPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Cocoa/Cocoa.h>



// 2014/10/22 4:16:51
struct MousePadData {
    bool isHeartBeat;
    
    CGPoint mousePoint;
    Byte mouseEventType;
    
    Byte left;
    Byte right;
    Byte center;
    
    Byte keySlots[8];
};

typedef struct MousePadData MousePadData;

typedef struct MousePadData MousePadData;


typedef NS_ENUM(int, BONJOUR_RECEIVER_STATE) {
    BONJOUR_RECEIVER_FAILED_OPEN_PORT,
    BONJOUR_RECEIVER_FAILED_OPEN_BONJOUR,
    BONJOUR_RECEIVER_FAILED_PUBLISH_BONJOUR,
    BONJOUR_RECEIVER_ACCEPTED_IOS
};

@interface AppDelegate : NSObject <NSApplicationDelegate, NSPortDelegate, NSNetServiceDelegate, NSUserNotificationCenterDelegate>

- (void) setState:(int)nextState;
- (void) execute:(NSData *)data;
@end

