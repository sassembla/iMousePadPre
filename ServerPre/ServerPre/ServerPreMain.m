//
//  ServerPreMain.m
//  ServerPre
//
//  Created by illusionismine on 2014/10/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "ServerPreMain.h"
#import "AppDelegate.h"

@implementation ServerPreMain

int NSApplicationMain(int argc, const char *argv[]) {
    @autoreleasepool {
        AppDelegate * delegate = [[AppDelegate alloc] init];
        
        NSApplication * application = [NSApplication sharedApplication];
        [application setDelegate:delegate];
        [NSApp run];
        
        return 0;
    }
}
@end
