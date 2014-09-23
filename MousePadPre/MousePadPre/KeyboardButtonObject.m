//
//  KeyboardButtonObject.m
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "KeyboardButtonObject.h"
#import "TimeMine.h"


@implementation KeyboardButtonObject


int buttonIndex;
NSString *keyboardType;

- (id) initWithType:(NSString *)type withIndex:(int)index {
    if (self = [super init]) {
        [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:05:27" withLimitSec:10000 withComment:@"ボタン一個の初期化、typeはかぶっても良い前提、データとして表示のための情報を持つ。managerから取りにくる。 idはindexをもらう。"];
        
        buttonIndex = index;
        keyboardType = type;
    }
    return self;
}


@end
