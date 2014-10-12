//
//  ViewController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "ViewController.h"
#import "TimeMine.h"

#import "KeyboardButtonManager.h"
#import "BonjourConnectionController.h"

#import "Messengers.h"

#import "FadeViewController.h"

@interface ViewController ()
@end



@implementation ViewController

#define CONNECTIONTYPE_BONJOUR      (0)
#define CONNECTIONTYPE_BLUETOOTHLE  (1)
int connectionType = CONNECTIONTYPE_BONJOUR;
BonjourConnectionController *bonConnectCont;

KeyboardButtonManager *buttonManager;


typedef NS_ENUM(int, INPUT_EVENT) {
    MOUSE_EVENT_BEGAN,
    MOUSE_EVENT_MOVED,
    MOUSE_EVENT_END,
    BUTTON_EVENT_UPDATED
};


- (void)viewDidLoad {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/12 14:26:57" withLimitSec:100000 withComment:@"倍率入れたい。ピクセルマッチさせない的な。"];
    [super viewDidLoad];
    
    messenger = [[KSMessenger alloc]initWithBodyID:self withSelector:@selector(receiver:) withName:MESSENGER_MAINVIEWCONTROLLER];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/12 14:27:00" withLimitSec:11000000 withComment:@"設定ファイルの事を考える、userPrefでいいはず"];
    /**
     設定ファイルを読み込む
     存在しなければデフォルトを読む
     */
    NSDictionary *defRightMouseButtonDict = @{
                                              @"identity":@"R",
                                              @"inputType":[NSNumber numberWithInt:INPUT_TYPE_MOUSEBUTTON],
                                              @"x":@300.0f,
                                              @"y":@600.0f,
                                              @"title":@"R"
                                              };
    
    NSDictionary *defLeftMouseButtonDict = @{
                                             @"identity":@"L",
                                             @"inputType":[NSNumber numberWithInt:INPUT_TYPE_MOUSEBUTTON],
                                             @"x":@200.0f,
                                             @"y":@600.0f,
                                             @"title":@"L"
                                             };

    
    NSDictionary *defCenterMouseButtonDict = @{
                                               @"identity":@"C",
                                               @"inputType":[NSNumber numberWithInt:INPUT_TYPE_MOUSEBUTTON],
                                               @"x":@400.0f,
                                               @"y":@600.0f,
                                               @"title":@"C"
                                               };

    NSDictionary *defKeyButtonDict = @{
                                       @"identity":@"K",
                                       @"inputType":[NSNumber numberWithInt:INPUT_TYPE_KEY],
                                       @"x":@100.0f,
                                       @"y":@600.0f,
                                       @"title":@"K"
                                       };
    
    NSArray *settings = @[defRightMouseButtonDict, defLeftMouseButtonDict, defCenterMouseButtonDict, defKeyButtonDict];
    
    buttonManager = [[KeyboardButtonManager alloc]initWithBaseView:self.view andSetting:settings];
    
    
    switch (connectionType) {
        case CONNECTIONTYPE_BONJOUR:{
            bonConnectCont = [[BonjourConnectionController alloc] init];
            break;
        }
        case CONNECTIONTYPE_BLUETOOTHLE:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:25:42" withLimitSec:0 withComment:@"いつかなんとかしたい。"];
            break;
        }
            
        default:
            break;
    }
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/22 21:43:11" withLimitSec:100000 withComment:@"後回しのフェードビュー、最終的には操作可能になったら出す"];
//    FadeViewController *fadeViewCont = [[FadeViewController alloc] initFadeViewWithBarseView:self.view.frame];
//    [self.view addSubview:fadeViewCont.view];
}

- (IBAction)reconnect:(id)sender {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/09 10:16:30" withLimitSec:1000000 withComment:@"接続に対して、チェックを行う。"];
}

/**
 いろんな箇所からのコントロールの受け取り
 */
- (void) receiver:(NSNotification *)notif {
    NSDictionary *paramsDict = [messenger tagValueDictionaryFromNotification:notif];
    
    /*
     bonjourからの通知
     */
    switch ([messenger execFrom:MESSENGER_BONJOURCONTROLLER viaNotification:notif]) {
        case BONJOUR_MESSAGE_SEARCHING:{
            [_indicatorButton setTitle:@"mousepad server connection searching..." forState:UIControlStateNormal];
            [_indicatorCircle setHidden:NO];
            
            [messenger call:MESSENGER_FADEVIEWCONTROLLER withExec:FADEOUT_MESSAGE_FADEIN, nil];
            [_infoMessage setText:@""];
            break;
        }
            
        case BONJOUR_MESSAGE_SEARCHED:{
            NSString *connectedServerName = paramsDict[@"connectedServerName"];
            [_indicatorButton setTitle:connectedServerName forState:UIControlStateNormal];
            [_indicatorCircle setHidden:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"bonjour connected."
                                                            message:@"ok"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [messenger call:MESSENGER_FADEVIEWCONTROLLER withExec:FADEOUT_MESSAGE_FADEOUT, nil];
            
            break;
        }
            
        case BONJOUR_MESSAGE_MISC:{
            NSString *informationMessage = paramsDict[@"info"];
            [_infoMessage setText:informationMessage];
            break;
        }
            
        default:
            break;
    }
    
    /*
     bluetoothのコントローラからの通知
     */
    
    
    /*
     FadeViewからの通知
     */
    
    
    
    /*
     ボタンコントローラからの通知
     */
    switch ([messenger execFrom:MESSENGER_KEYBOARDMANAGER viaNotification:notif]) {
        case BUTTON_MESSAGE_UPDATED:
            [self setMovePoint:currentViewMousePoint withMouseEventType:BUTTON_EVENT_UPDATED];
            break;
            
        default:
            break;
    }
}


CGPoint currentViewMousePoint;

/**
 マウス挙動
 1つ目のもののみを取り出す
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        currentViewMousePoint = [touch locationInView:self.view];
        [self setMovePoint:currentViewMousePoint withMouseEventType:MOUSE_EVENT_BEGAN];
        break;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        currentViewMousePoint = [touch locationInView:self.view];
        
        [self setMovePoint:currentViewMousePoint withMouseEventType:MOUSE_EVENT_MOVED];
        break;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        currentViewMousePoint = [touch locationInView:self.view];
        
        [self setMovePoint:currentViewMousePoint withMouseEventType:MOUSE_EVENT_END];
        break;
    }
}



/**
 キーの押下状態と、カーソルの移動状態を通知する。
 */
- (void) setMovePoint:(CGPoint)point withMouseEventType:(int)type {
    KeysData keysData = [buttonManager keysData];

    switch (connectionType) {
        case CONNECTIONTYPE_BONJOUR:{
            [bonConnectCont sendPoint:point withType:type andKeysData:keysData];
            break;
        }
        case CONNECTIONTYPE_BLUETOOTHLE:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 21:40:52" withLimitSec:0 withComment:@"bt未対応、対応したい。"];
            break;
        }
            
        default:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 21:40:27" withLimitSec:0 withComment:@"unknown connection type"];
            break;
        }
    }
}

/**
 ボタンのマネージャからキー情報を取得する
 */
- (KeysData) readKeysData {
    return [buttonManager keysData];
}


@end
