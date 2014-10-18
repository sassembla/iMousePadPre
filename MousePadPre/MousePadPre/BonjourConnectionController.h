//
//  BonjourConnectionController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "KeysData.h"

#import "KSMessenger.h"

typedef NS_ENUM(int, MESSAGE_BONJOUR) {
    BONJOUR_MESSAGE_SEARCHING,
    BONJOUR_MESSAGE_SEARCHED,
    BONJOUR_MESSAGE_FAILED_TO_SEARCH,
    
    BONJOUR_MESSAGE_CONNECTING,
    BONJOUR_MESSAGE_CONNECTED,
    BONJOUR_MESSAGE_CONNECT_FAILED,
    
    BONJOUR_MESSAGE_MISC
};

@interface BonjourConnectionController : NSObject <NSStreamDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
    KSMessenger *messenger;
}

- (void) sendPoint:(CGPoint)point withType:(Byte)type andKeysData:(KeysData)KeysData;
- (void) resetSearchBonjourNetwork;

@end
