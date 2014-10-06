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

#import "MouseButtonViewController.h"
#import "KeyButtonViewController.h"


@implementation KeyboardButtonManager

NSMutableArray *buttons;

- (id) initWithBaseView:(UIView *)baseView andSetting:(NSArray *)settings {
    if (self = [super init]) {        
        buttons = [[NSMutableArray alloc]init];
        
        int buttonIndex = 0;
        for (NSDictionary *buttonDict in settings) {

            int type = [buttonDict[@"type"] intValue];
            
            float x = [buttonDict[@"x"] floatValue];
            float y = [buttonDict[@"y"] floatValue];
            
            CGRect buttonFrame = CGRectMake(x, y, 100, 100);
            
            NSString *title = buttonDict[@"title"];
            
            switch (type) {
                case INPUT_TYPE_MOUSEBUTTON:{
                    int mouseButtonIdentity = 0;
                    MouseButtonViewController *mouseButtonViewCont = [[MouseButtonViewController alloc] initWithKeyType:mouseButtonIdentity withIndex:[NSNumber numberWithInt:buttonIndex] andTitle:title];
                    
                    UIView *buttonView = [mouseButtonViewCont view];
                    [buttonView setFrame:buttonFrame];
                    [baseView addSubview:[mouseButtonViewCont view]];
                    
                    mouseButtonViewCont.delegate = self;
                    
                    [buttons addObject:mouseButtonViewCont];
                    break;
                }
                case INPUT_TYPE_KEY:{
                    int keyButtonIdentity = 0;
                    KeyButtonViewController *keyButtonViewCont = [[KeyButtonViewController alloc] initWithKeyType:keyButtonIdentity withIndex:[NSNumber numberWithInt:buttonIndex] andTitle:title];
                    
                    UIView *buttonView = [keyButtonViewCont view];
                    [buttonView setFrame:buttonFrame];
                    [baseView addSubview:[keyButtonViewCont view]];
                    
                    keyButtonViewCont.delegate = self;
                    
                    [buttons addObject:keyButtonViewCont];
                    break;
                }
                    
                default:
                    break;
            }
            

            
            buttonIndex ++;
        }
    }
    return self;
}

/**
 ボタンが押された場合に伝達を行う。
 */
- (void) touchDown:(int)index {
    NSLog(@"a%d", index);
}

- (void) touchUp:(int)index {
    NSLog(@"b%d", index);
}

/**
 現在押されているボタンの情報を返す
 */
- (KeysData *)keysData {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/04 22:35:52" withLimitSec:100000 withComment:@"押されているキーのデータを返す"];
    return nil;
}





- (void) addButton {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:08:21" withLimitSec:10000 withComment:@"初期化時にも呼ばれて、設定からボタンを配置する。"];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:03:50" withLimitSec:10000 withComment:@"このメソッドを押すためのエディット中ボタンが必要"];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 17:56:20" withLimitSec:10000 withComment:@"ボタンの定義追加、画面への追加、ボタンオブジェクトの辞書への追加、を行う。何が必要かなー。キーの内容、位置、indexは必要っぽい。"];
    
    
}

- (void) removeButton {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 17:57:15" withLimitSec:10000 withComment:@"ボタンの定義を消す。画面からも消す。"];
}







/**
 ボタンから呼ばれる、キー/マウスボタンの入力に関するイベント
 */
- (void) mouseDown:(Byte)buttonIdentity {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/04 22:46:17" withLimitSec:100000 withComment:@"マウスが押されたときに発生するイベント。記録とイベントの発信を行う"];
}

- (void) mouseUp:(Byte)buttonIdentity {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/04 22:46:17" withLimitSec:100000 withComment:@"マウスが押されたときに発生するイベント。記録とイベントの発信を行う"];
}


- (void) keyDown:(Byte)keyIdentity {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/04 22:46:17" withLimitSec:100000 withComment:@"キーが押されたときに発生するイベント。記録とイベントの発信を行う"];
}

- (void) keyUp:(Byte)keyIdentity {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/04 22:46:17" withLimitSec:100000 withComment:@"キーが押されたときに発生するイベント。記録とイベントの発信を行う"];
}



@end
