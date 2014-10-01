//
//  BonjourConnectionController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface BonjourConnectionController : NSObject <NSStreamDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

- (void) sendPoint:(CGPoint)point withType:(int)type andKeys:(int)key;

@end
