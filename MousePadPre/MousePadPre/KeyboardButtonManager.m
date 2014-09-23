//
//  KeyboardButtonManager.m
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardButtonManager.h"
#import "TimeMine.h"


@implementation KeyboardButtonManager

UIView *view;
NSMutableArray *buttons;
NSMutableArray *buttonsStatuss;

- (id) initWithBaseView:(UIView *)baseView andSetting:(NSDictionary *)settings {
    if (self = [super init]) {
        view = baseView;
        buttons = [[NSMutableArray alloc]init];
        buttonsStatuss = [[NSMutableArray alloc]init];
        
        for (NSString *buttonIdentity in [settings keyEnumerator]) {
            NSLog(@"buttonIdentity %@", buttonIdentity);
            NSLog(@"val %@", settings[buttonIdentity]);
        }
    }
    return self;
}


- (NSArray * ) statuss {
    return buttonsStatuss;
}


- (void) addButton {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:08:21" withLimitSec:10000 withComment:@"初期化時にも呼ばれて、設定からボタンを配置する。"];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:03:50" withLimitSec:10000 withComment:@"このメソッドを押すためのエディット中ボタンが必要"];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 17:56:20" withLimitSec:10000 withComment:@"ボタンの定義追加、画面への追加、ボタンオブジェクトの辞書への追加、を行う。何が必要かなー。キーの内容、位置、indexは必要っぽい。"];
    
    
}


- (void) removeButton {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 17:57:15" withLimitSec:10000 withComment:@"ボタンの定義を消す。画面からも消す。"];
}


@end
