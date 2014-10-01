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
    [super viewDidLoad];
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

    /**
     設定ファイルを読み込む
     存在しなければデフォルトを読む
     */
    NSDictionary *defButtonDict = @{@"type":@"K", @"x":@100, @"y":@100};
    NSDictionary *settingDict = @{@"default":defButtonDict};
    buttonManager = [[KeyboardButtonManager alloc]initWithBaseView:self.view andSetting:settingDict];
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
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:21:55" withLimitSec:100000 withComment:@"キーの押下状態は、イベントのまとめを行ってるところで纏めて行う。ボタンマネージャ作るかな。このへんに一個メソッドを指して、データを一括で編集する。キーの状態は押す・離すだけが入ればいい感じかなあ。状態の辞書をもってくるか。"];

    int key = 0;
    
    

    switch (connectionType) {
        case CONNECTIONTYPE_BONJOUR:{
            [bonConnectCont sendPoint:point withType:type andKeys:key];
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
 
 */
- (IBAction)keyDown:(id)sender {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:22:00" withLimitSec:10000 withComment:@"押しっぱなしのキーイベントには分解能が無いので、キーボードっぽくするならそのへんのイベントをスレッドチックに取得する必要がある。"];
    NSLog(@"keyDown");
}

- (IBAction)keyUp:(id)sender {
    NSLog(@"keyUp");
}


@end
