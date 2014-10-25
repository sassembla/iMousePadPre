//
//  AppDelegate.h
//  ServerPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KSMessenger.h"


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


@interface AppDelegate : NSObject <NSApplicationDelegate, NSPortDelegate, NSNetServiceDelegate, NSUserNotificationCenterDelegate> {
    KSMessenger *messenger;
}

- (void) setState:(int)nextState;
- (void) execute:(NSData *)data;
@end

