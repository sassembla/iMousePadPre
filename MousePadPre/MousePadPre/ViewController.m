//
//  ViewController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "ViewController.h"
#import "TimeMine.h"

#import "MouseIndicatorViewController.h"

#import "KeyboardButtonManager.h"
#import "BonjourConnectionController.h"

#import "Messengers.h"


@interface ViewController ()
@end



@implementation ViewController

#define CONNECTIONTYPE_BONJOUR      (0)
#define CONNECTIONTYPE_BLUETOOTHLE  (1)
int connectionType = CONNECTIONTYPE_BONJOUR;
BonjourConnectionController *bonConnectCont;

MouseIndicatorViewController *mouseIndicateViewCont;

KeyboardButtonManager *buttonManager;


#define DISTANCE_IS_OVER_WHEEL_EVENT    (1.0f)
#define DISTANCE_IS_OVER_CENTER_MOUSE_DRAGGED   (0.5f)


typedef NS_ENUM(Byte, INPUT_EVENT) {
    MOUSE_EVENT_BEGAN,
    MOUSE_EVENT_MOVED,
    MOUSE_EVENT_END,
    BUTTON_EVENT_UPDATED
};

// 2014/10/26 10:04:42
typedef NS_ENUM(Byte, MOUSE_INPUT_EVENT) {
    MOUSE_BUTTON_NONE,
    MOUSE_BUTTON_DOWN,
    MOUSE_BUTTON_DRAG,
    MOUSE_BUTTON_UP,
    MOUSE_DOUBLE_CLICK,
    MOUSE_WHEEL_INCREASE,
    MOUSE_WHEEL_DECREASE
};

typedef NS_ENUM(int, VIEW_MESSAGE) {
    VIEW_MESSAGE_HEARTBEAT
};

struct MouseButtonsData {
    Byte left;
    Byte right;
    Byte centerCommand;
    float centerWheelMoveAmount;
};

typedef struct MouseButtonsData MouseButtonsData;

bool firstConnectTime;

#define INTERVAL_HEARTBEAT  (1.0f)




- (void)viewDidLoad {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/25 21:25:14" withLimitSec:100000 withComment:@"アイコンが上に消えちゃうのをなんとかする"];
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/26 2:37:14" withLimitSec:100000 withComment:@"centerの縦をとってホイル扱いする"];
    
    mouseIndicateViewCont = [[MouseIndicatorViewController alloc] initWithBaseview:self.view];
    [super viewDidLoad];
    
    messenger = [[KSMessenger alloc]initWithBodyID:self withSelector:@selector(receiver:) withName:MESSENGER_MAINVIEWCONTROLLER];
    
    /**
     設定ファイルを読み込む
     存在しなければデフォルトを読む
     */
//    NSDictionary *defKeyButtonDict = @{
//                                       @"identity":@"K",
//                                       @"inputType":[NSNumber numberWithInt:INPUT_TYPE_KEY],
//                                       @"x":@100.0f,
//                                       @"y":@600.0f,
//                                       @"title":@"K"
//                                       };
    
    NSArray *settings = @[];
    
    buttonManager = [[KeyboardButtonManager alloc]initWithBaseView:self.view andSetting:settings];
    
    
    
    /*
     show alert when connected to server first time.
     */
    firstConnectTime = true;
    
    
    switch (connectionType) {
        case CONNECTIONTYPE_BONJOUR:{
            bonConnectCont = [[BonjourConnectionController alloc] init];
            break;
        }
        case CONNECTIONTYPE_BLUETOOTHLE:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:25:42" withLimitSec:0 withComment:@"いつかなんとかしたい。CONNECTIONTYPE_BLUETOOTHLEでのマウスとしての接続。"];
            break;
        }
            
        default:
            break;
    }
    
    [messenger callMyself:VIEW_MESSAGE_HEARTBEAT, nil];
}

/**
 再接続処理を開始する
 */
- (IBAction)reconnect:(id)sender {

    switch (connectionType) {
        case CONNECTIONTYPE_BONJOUR:{
            [bonConnectCont resetSearchBonjourNetwork];
            break;
        }
        case CONNECTIONTYPE_BLUETOOTHLE:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/10/16 21:32:22" withLimitSec:0 withComment:@"BTの接続し直しを行うコード、未定義"];
            break;
        }
            
            
        default:
            break;
    }
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
            
            [_infoMessage setText:@""];
            break;
        }
            
        case BONJOUR_MESSAGE_SEARCHED:{
            [_infoMessage setText:@"searched service, connecting..."];
            break;
        }
        case BONJOUR_MESSAGE_FAILED_TO_SEARCH:{
            NSString *informationMessage = paramsDict[@"info"];
            [_infoMessage setText:informationMessage];
            NSLog(@"error %@", paramsDict[@"error"]);
            
            break;
        }
            
        case BONJOUR_MESSAGE_CONNECTING:{
            [_indicatorButton setTitle:@"mousepad server connection connecting..." forState:UIControlStateNormal];
            break;
        }
            
        case BONJOUR_MESSAGE_CONNECTED:{
            NSString *connectedServerName = paramsDict[@"connectedServerName"];
            [_indicatorButton setTitle:connectedServerName forState:UIControlStateNormal];
            [_indicatorCircle setHidden:YES];
            
            // erase message.
            [_infoMessage setText:@""];
            
            if (firstConnectTime) {
                NSString *connectedMessage = [NSString stringWithFormat:@"MousePad connected to %@", connectedServerName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:connectedMessage
                                                                message:@"ok"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                firstConnectTime = false;
            }
            
            [self resetInputParameter];
            
            
            break;
        }
        
        case BONJOUR_MESSAGE_CONNECT_FAILED:{
            break;
        }
    
        case BONJOUR_MESSAGE_DISCONNECTED:{
            NSString *disconnectedServerName = paramsDict[@"disconnectedServerName"];
            NSString *disconnectedServerInfo = [NSString stringWithFormat:@"disconnected from %@", disconnectedServerName];
            [_indicatorButton setTitle:disconnectedServerInfo forState:UIControlStateNormal];
            [_indicatorCircle setHidden:YES];
            
            NSString *disconnectedReason = paramsDict[@"reason"];
            [_infoMessage setText:disconnectedReason];
            
            [self reconnect:nil];
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
     ボタンコントローラからの通知
     */
    switch ([messenger execFrom:MESSENGER_KEYBOARDMANAGER viaNotification:notif]) {
        case BUTTON_MESSAGE_UPDATED:
            [self setMovePoint:currentViewMousePoint withMouseEventType:BUTTON_EVENT_UPDATED];
            break;
            
        default:
            break;
    }
    
    /*
     自分からの通知
     */
    switch ([messenger execFrom:[messenger myName] viaNotification:notif]) {
        case VIEW_MESSAGE_HEARTBEAT:{

            [self heartBeat];
            
            [messenger callMyself:VIEW_MESSAGE_HEARTBEAT,
             [messenger withDelay:INTERVAL_HEARTBEAT],
             nil];
            break;
        }
        default:
            break;
    }
}


/**
 time interval event
 */
- (void) heartBeat {
    switch (connectionType) {
        case CONNECTIONTYPE_BONJOUR:{
            [bonConnectCont sendHeartBeat];
            break;
        }
        case CONNECTIONTYPE_BLUETOOTHLE:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/10/16 21:32:22" withLimitSec:0 withComment:@"BTの接続し直しを行うコード、未定義"];
            break;
        }
            
            
        default:
            break;
    }
}


- (void) resetInputParameter {
    mouseButtonsData.left = MOUSE_BUTTON_NONE;
    mouseButtonsData.right = MOUSE_BUTTON_NONE;
    mouseButtonsData.centerCommand = MOUSE_BUTTON_NONE;
    mouseButtonsData.centerWheelMoveAmount = 0.f;
}


CGPoint currentViewMousePoint;

/**
 マウス挙動
 
 一点目のタッチはポイント専用、
 その後のタッチはポイントからの位置関係でクリックイベントを発生させる。
 */

// 最初のタッチをマウスポインターとして保持
UITouch *pointerTouch;

UITouch *leftButtonTouch;
UITouch *rightButtonTouch;
UITouch *centerButtonTouch;


MouseButtonsData mouseButtonsData;


/**
 フレーム単位でまとめて一回ずつ、タッチ→マウスイベントへと変換したイベントを発行する
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self detectMousePointerTouch:event withBeganTouches:touches];
    
    for (UITouch *touch in touches) {
        if (touch == pointerTouch) continue;
        
        // firstTouch以外は位置でマウスクリックとして判定
        [self detectMouseTouchBegan:touch];
    }
    
    [self setMovePoint:currentViewMousePoint withMouseEventType:MOUSE_EVENT_BEGAN];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /*
     ポインターになる一点のみをマウスの動きとして送信する。
     */
    for (UITouch *touch in touches) {
        if (touch == pointerTouch) {
            currentViewMousePoint = [touch locationInView:self.view];
        }
    }
    
    /*
     このタイミングでonになっているマウスボタンは、drag状態として扱う。
     */
    [self detectMouseTouchDrag:event];
    
    [self setMovePoint:currentViewMousePoint withMouseEventType:MOUSE_EVENT_MOVED];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch == pointerTouch) {
            currentViewMousePoint = [touch locationInView:self.view];
            [mouseIndicateViewCont turnOff];
            
            pointerTouch = nil;
        } else {
            [self detectMouseTouchEnded:touch];
        }
    }
    
    [self setMovePoint:currentViewMousePoint withMouseEventType:MOUSE_EVENT_END];
    
    /*
     Upされたあとは、自動的に MOUSE_BUTTON_NONE にする
     */
    [self resetMouseTouchUp];
}


/**
 マウスポインタ用のタッチを取得する
 */
- (void) detectMousePointerTouch:(UIEvent *)event withBeganTouches:(NSSet *)touches {
    
    // pointerTouchがまだ存在する場合、何もしない。
    if (pointerTouch) return;
    
    NSSet *currentViewTouches = [event touchesForView:self.view];
    
    // view全体のタッチを取得し、1つしかない場合、マウスポイント用のタッチとして取得する。
    if ([currentViewTouches count] == 1) {
        pointerTouch = [touches allObjects][0];
        currentViewMousePoint = [pointerTouch locationInView:self.view];
        [mouseIndicateViewCont turnOn];
        return;
    }
    
    // また2つ以上であっても、新規のものが既存のボタンに含まれていない場合、マウスポイント用のタッチとして取得する。
    // 同時に２つ以上のタッチが追加された場合、先に発見された方をマウスとする。
    // それ以降のタッチは無視する。
    for (UITouch *touch in currentViewTouches) {
        
        if (touch == leftButtonTouch) continue;
        if (touch == rightButtonTouch) continue;
        if (touch == centerButtonTouch) continue;
        
        pointerTouch = touch;
        currentViewMousePoint = [pointerTouch locationInView:self.view];
        [mouseIndicateViewCont turnOn];
        return;
    }
}

/**
 firstTouchとの位置関係から、マウスのボタンとして動作を行う。
 */
- (void) detectMouseTouchBegan:(UITouch *)touch {
    CGPoint firstTouchPoint = [pointerTouch locationInView:self.view];
    CGPoint currentTouchPoint = [touch locationInView:self.view];
    
    /*
     位置の組み合わせでマウスのボタン挙動を作り出す。
     */
    if (firstTouchPoint.y < currentTouchPoint.y) {
        if (currentTouchPoint.x < firstTouchPoint.x) {
            leftButtonTouch = touch;
            [mouseIndicateViewCont turnLeft:YES];
            
            mouseButtonsData.left = MOUSE_BUTTON_DOWN;
        } else {
            rightButtonTouch = touch;
            [mouseIndicateViewCont turnRight:YES];
            
            mouseButtonsData.right = MOUSE_BUTTON_DOWN;
        }
    } else {
        centerButtonTouch = touch;
        [mouseIndicateViewCont turnCenter:YES];
        
        mouseButtonsData.centerCommand = MOUSE_BUTTON_DOWN;
    }
}

- (void) detectMouseTouchDrag:(UIEvent *)event {
    NSSet *currentViewTouches = [event touchesForView:self.view];

    for (UITouch *touch in currentViewTouches) {
        if (touch == leftButtonTouch) mouseButtonsData.left = MOUSE_BUTTON_DRAG;
        if (touch == rightButtonTouch) mouseButtonsData.right = MOUSE_BUTTON_DRAG;
        if (touch == centerButtonTouch) [self updateCenterEvent:touch withBaseTouch:pointerTouch];
    }
}

- (void) detectMouseTouchEnded:(UITouch *)touch {
    
    if (touch == leftButtonTouch) {
        [mouseIndicateViewCont turnLeft:NO];
        leftButtonTouch = nil;
        
        mouseButtonsData.left = MOUSE_BUTTON_UP;
    }
    
    if (touch == rightButtonTouch) {
        [mouseIndicateViewCont turnRight:NO];
        rightButtonTouch = nil;
        
        mouseButtonsData.right = MOUSE_BUTTON_UP;
    }
    
    if (touch == centerButtonTouch) {
        [mouseIndicateViewCont turnCenter:NO];
        centerButtonTouch = nil;
        
        mouseButtonsData.centerCommand = MOUSE_BUTTON_UP;
    }
}

/**
 
 */
- (void) updateCenterEvent:(UITouch *)centerTouch withBaseTouch:(UITouch *)baseTouch {
    mouseButtonsData.centerWheelMoveAmount = 0.f;
    float nowY = [centerTouch locationInView:self.view].y;
    float beforeY = [centerTouch previousLocationInView:self.view].y;
    
    float distance = beforeY - nowY;

    // reset
    mouseButtonsData.centerWheelMoveAmount = 0.f;
    
    if (fabsf(distance) < DISTANCE_IS_OVER_WHEEL_EVENT) {
        if (baseTouch && DISTANCE_IS_OVER_CENTER_MOUSE_DRAGGED < fabsf([baseTouch previousLocationInView:self.view].y - [baseTouch locationInView:self.view].y)) {
            mouseButtonsData.centerCommand = MOUSE_BUTTON_DRAG;
            return;
        }
    }
    
    if (0 < distance) {
        mouseButtonsData.centerCommand = MOUSE_WHEEL_INCREASE;
        mouseButtonsData.centerWheelMoveAmount = distance;
    }
    
    if (distance < 0) {
        mouseButtonsData.centerCommand = MOUSE_WHEEL_DECREASE;
        mouseButtonsData.centerWheelMoveAmount = distance;
    }
    
    
}

- (void) resetMouseTouchUp {
    if (mouseButtonsData.left == MOUSE_BUTTON_UP) mouseButtonsData.left = MOUSE_BUTTON_NONE;
    if (mouseButtonsData.right == MOUSE_BUTTON_UP) mouseButtonsData.right = MOUSE_BUTTON_NONE;
    if (mouseButtonsData.centerCommand == MOUSE_BUTTON_UP) mouseButtonsData.centerCommand = MOUSE_BUTTON_NONE;
}



/**
 キーの押下状態と、マウスポインターの移動状態を通知する。
 */
- (void) setMovePoint:(CGPoint)point withMouseEventType:(Byte)type {
    /*
     カーソル移動
     */
    mouseIndicateViewCont.view.center = point;

    
    KeysData keysData = [buttonManager keysData];
    
    /*
     キーのデータに対して、マウスのデータを更新
     */
    keysData.left = mouseButtonsData.left;
    keysData.right = mouseButtonsData.right;
    keysData.centerCommand = mouseButtonsData.centerCommand;
    keysData.centerWheelMoveAmount = mouseButtonsData.centerWheelMoveAmount;
    
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
