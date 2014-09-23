//
//  BonjourConnectionController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BonjourConnectionController : NSObject <NSStreamDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

- (void) sendData:(NSData *)data;

@end
