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

NSMutableDictionary *buttonDict;
KeysData currentKeysData;


- (id) initWithBaseView:(UIView *)baseView andSetting:(NSArray *)settings {
    if (self = [super init]) {        
        buttonDict = [[NSMutableDictionary alloc]init];
        
        int buttonIndex = 0;
        for (NSDictionary *buttonInfoDict in settings) {
            
            int inputType = [buttonInfoDict[@"inputType"] intValue];
            
            float x = [buttonInfoDict[@"x"] floatValue];
            float y = [buttonInfoDict[@"y"] floatValue];
            
            CGRect buttonFrame = CGRectMake(x, y, 100, 100);
            
            NSString *title = buttonInfoDict[@"title"];
            
            // set layout.
            switch (inputType) {
                case INPUT_TYPE_MOUSEBUTTON:{
                    
                    
                    MouseButtonViewController *mouseButtonViewCont = [[MouseButtonViewController alloc] initWithIndex:[NSNumber numberWithInt:buttonIndex] andTitle:title];
                    
                    {
                        UIView *buttonView = [mouseButtonViewCont view];
                        [buttonView setFrame:buttonFrame];
                        [baseView addSubview:[mouseButtonViewCont view]];
                    }
                    
                    mouseButtonViewCont.delegate = self;
                    
                    buttonDict[[NSNumber numberWithInt:buttonIndex]] = @{
                                                                         @"inputType":buttonInfoDict[@"inputType"],
                                                                         @"identity":buttonInfoDict[@"identity"],
                                                                         @"controller":mouseButtonViewCont
                                                                         };
                    
                    break;
                }
                case INPUT_TYPE_KEY:{
                    KeyButtonViewController *keyButtonViewCont = [[KeyButtonViewController alloc] initWithIndex:[NSNumber numberWithInt:buttonIndex] andTitle:title];
                    
                    {
                        UIView *buttonView = [keyButtonViewCont view];
                        [buttonView setFrame:buttonFrame];
                        [baseView addSubview:[keyButtonViewCont view]];
                    }
                    
                    keyButtonViewCont.delegate = self;
                    
                    buttonDict[[NSNumber numberWithInt:buttonIndex]] = @{
                                                                         @"inputType":buttonInfoDict[@"inputType"],
                                                                         @"identity":buttonInfoDict[@"identity"],
                                                                         @"controller":keyButtonViewCont
                                                                         };
                    
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
 ボタンが押されたことを受け取る
 */
- (void) touchDown:(int)index {
    NSString *input = buttonDict[[NSNumber numberWithInt:index]][@"identity"];
    int inputType = [buttonDict[[NSNumber numberWithInt:index]][@"inputType"] intValue];
    
    switch (inputType) {
        case INPUT_TYPE_MOUSEBUTTON:{
            if ([input isEqualToString:@"R"]) {
                currentKeysData.right = true;
            } else if ([input isEqualToString:@"L"]) {
                currentKeysData.left = true;
            } else if ([input isEqualToString:@"C"]) {
                currentKeysData.center = true;
            }
            break;
        }
        case INPUT_TYPE_KEY:{
            
            break;
        }
        default:
            break;
    }
}

- (void) touchUp:(int)index {
    NSString *input = buttonDict[[NSNumber numberWithInt:index]][@"identity"];
    int inputType = [buttonDict[[NSNumber numberWithInt:index]][@"inputType"] intValue];
    
    switch (inputType) {
        case INPUT_TYPE_MOUSEBUTTON:{
            if ([input isEqualToString:@"R"]) {
                currentKeysData.right = false;
            } else if ([input isEqualToString:@"L"]) {
                currentKeysData.left = false;
            } else if ([input isEqualToString:@"C"]) {
                currentKeysData.center = false;
            }
            break;
        }
        case INPUT_TYPE_KEY:{
            
            break;
        }
        default:
            break;
    }
}

/**
 現在押されているボタンの情報を返す
 */
- (KeysData)keysData {
    return currentKeysData;
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
