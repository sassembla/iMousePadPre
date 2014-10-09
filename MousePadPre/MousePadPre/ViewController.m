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


#define MOUSEVENT_BEGAN (0)
#define MOUSEVENT_MOVED (1)
#define MOUSEVENT_END   (2)


- (void)viewDidLoad {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/08 22:28:47" withLimitSec:100000 withComment:@"倍率入れたい。ピクセルマッチさせない的な。"];
    [super viewDidLoad];
    
    messenger = [[KSMessenger alloc]initWithBodyID:self withSelector:@selector(receiver:) withName:MESSENGER_MAINVIEWCONTROLLER];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/08 22:28:51" withLimitSec:11000000 withComment:@"設定ファイルの事を考える、userPrefでいいはず"];
    /**
     設定ファイルを読み込む
     存在しなければデフォルトを読む
     */
    NSDictionary *defRightMouseButtonDict = @{
                                              @"identity":@"R",
                                              @"inputType":[NSNumber numberWithInt:INPUT_TYPE_MOUSEBUTTON],
                                              @"x":@200.0f,
                                              @"y":@100.0f,
                                              @"title":@"R"
                                              };
    
    NSDictionary *defLeftMouseButtonDict = @{
                                             @"identity":@"L",
                                             @"inputType":[NSNumber numberWithInt:INPUT_TYPE_MOUSEBUTTON],
                                             @"x":@300.0f,
                                             @"y":@100.0f,
                                             @"title":@"L"
                                             };

    
    NSDictionary *defCenterMouseButtonDict = @{
                                               @"identity":@"C",
                                               @"inputType":[NSNumber numberWithInt:INPUT_TYPE_MOUSEBUTTON],
                                               @"x":@400.0f,
                                               @"y":@100.0f,
                                               @"title":@"C"
                                               };

    NSDictionary *defKeyButtonDict = @{
                                       @"identity":@"K",
                                       @"inputType":[NSNumber numberWithInt:INPUT_TYPE_KEY],
                                       @"x":@100.0f,
                                       @"y":@100.0f,
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
    
    
//    FadeViewController *fadeViewCont = [[FadeViewController alloc] initFadeViewWithBarseView:self.view.frame];
//    [self.view addSubview:fadeViewCont.view];
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
     bluetootuからの通知
     */
    
    
    /*
     FadeViewからの通知
     */
}


/**
 マウス挙動
 1つ目のもののみを取り出す
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInView:self.view];
        [self setMovePoint:p withMouseEventType:MOUSEVENT_BEGAN];
        break;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInView:self.view];
        
        [self setMovePoint:p withMouseEventType:MOUSEVENT_MOVED];
        break;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInView:self.view];
        
        [self setMovePoint:p withMouseEventType:MOUSEVENT_END];
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
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 21:40:52" withLimitSec:0 withComment:@"bt未対応"];
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


- (void) intervalKeyUpdate {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/04 22:42:29" withLimitSec:100000 withComment:@"setMovePointを定期的に実行して、キーの状態変化を通知する、、、とかかな、、まあ変化するまでは変化してない、って感じで良いんだと思うから出番が無いかな、、、"];
}

@end
