//
//  AppDelegate.m
//  ServerPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "AppDelegate.h"
#include <netinet/in.h>
#include <Carbon/Carbon.h>
#import "TimeMine.h"

@interface AppDelegate ()
@end



/*
 不特定のportを使ってBonjour経由でiOS側と接続する。
 */
@implementation AppDelegate

#define BONJOUR_DOMAIN  (@"")
#define BONJOUR_TYPE    (@"_mousepad._tcp")// _始まりで、protocolを書く。
#define BONJOUR_NAME    (@"hello!")


typedef NS_ENUM(Byte, INPUT_EVENT) {
    MOUSE_EVENT_BEGAN,
    MOUSE_EVENT_MOVED,
    MOUSE_EVENT_END,
    BUTTON_EVENT_UPDATED
};

// 2014/10/16 0:18:30
typedef NS_ENUM(Byte, MOUSE_INPUT_EVENT) {
    MOUSE_BUTTON_NONE,
    MOUSE_BUTTON_DOWN,
    MOUSE_BUTTON_DRAG,
    MOUSE_BUTTON_UP,
    MOUSE_DOUBLE_CLICK,
    MOUSE_WHEEL_UP,
    MOUSE_WHEEL_DOWN
};

typedef NS_ENUM(int, MESSAGE) {
    MESSAGE_HEARTBEAT
};

NSSocketPort *bonjourSocket;
NSNetService *bonjourService;
NSFileHandle *bonjourSocketHandle;
NSFileHandle *bonjourAcceptedHandle;

NSUserNotificationCenter *notifier;

int state;


CGFloat SCREEN_WIDTH;
CGFloat SCREEN_HEIGHT;

NSMutableDictionary *screenInfo;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"boot!");
    
    messenger = [[KSMessenger alloc]initWithBodyID:self withSelector:@selector(receiver:) withName:@"MASTER"];
    [messenger callMyself:MESSAGE_HEARTBEAT, nil];
    
    /*
     画面サイズの取得
     */
    NSScreen *screen = [NSScreen mainScreen];
    screenInfo = [[NSMutableDictionary alloc]init];
    SCREEN_WIDTH = screen.frame.size.width;
    SCREEN_HEIGHT = screen.frame.size.height;
    
    notifier = [NSUserNotificationCenter defaultUserNotificationCenter];
    notifier.delegate = self;
    
    
    [self publishBonjourService];
}

- (void) receiver:(NSNotification *)notif {
    NSLog(@"start!");
    switch ([messenger execFrom:[messenger myName] viaNotification:notif]) {
        case MESSAGE_HEARTBEAT:
            
            switch (state) {
                case BONJOUR_RECEIVER_CLOSING:{
                    [self setState:BONJOUR_RECEIVER_CLOSED];
                    [self resetBonjourService];
                    break;
                }
                    
                default:
                    break;
            }
            
            [messenger callMyself:MESSAGE_HEARTBEAT, [messenger withDelay:1.0f], nil];
            break;
    }
}




- (void) resetBonjourService {
    bonjourSocket = nil;
    
    bonjourService.delegate = nil;
    [bonjourService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [bonjourService stop];
    
    bonjourService = nil;
    
    [self publishBonjourService];
}


- (void) publishBonjourService {
    /*
     bonjourSocketを初期化する。
     自動的にportが割り当てられる。
     */
    bonjourSocket = [[NSSocketPort alloc] init];
    
    if (!bonjourSocket) {
        [self notifyToUserWithStatus:BONJOUR_RECEIVER_FAILED_OPEN_PORT withTitle:@"server failed" message:@"failed to locate bonjour network. reboot?"];
        return;
    }
    
    /*
     現在bonjourSocketで使用しているport番号を取得
     */
    struct sockaddr_in addr = *((struct sockaddr_in *)[[bonjourSocket address] bytes]);
    socklen_t len = sizeof(addr);
    
    getsockname([bonjourSocket socket], (struct sockaddr *)&addr, &len);
    
    int portNumber = ntohs(addr.sin_port);
    NSLog(@"port:%d", portNumber);
    
    /*
     bonjourで使用するサービスを展開
     */
    bonjourService = [[NSNetService alloc]initWithDomain:BONJOUR_DOMAIN type:BONJOUR_TYPE name:BONJOUR_NAME port:portNumber];
    if (bonjourService) {
        bonjourService.delegate = self;
        [bonjourService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [bonjourService publish];
    } else {
        [self notifyToUserWithStatus:BONJOUR_RECEIVER_FAILED_OPEN_BONJOUR withTitle:@"server failed" message:@"failed to locate bonjour network. reboot?"];
    }
}

- (void) setState:(int)nextState {
    state = nextState;
}



/**
 通知
 */
- (void) notifyToUserWithStatus:(int)status withTitle:(NSString *)title message:(NSString *)message {
    NSUserNotification * newUserNotification = [NSUserNotification new];
    newUserNotification.actionButtonTitle = [[NSString alloc]initWithFormat:@"%d", status];
    newUserNotification.title = @"mouseServer";
    newUserNotification.subtitle = title;
    newUserNotification.informativeText = message;
    
    [notifier deliverNotification:newUserNotification];
}

/*
 Macの通知センターのデリゲート
 */
// Sent to the delegate when a notification delivery date has arrived. At this time, the notification has either been presented to the user or the notification center has decided not to present it because your application was already frontmost.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    // notificationが表示されたらここにくる
}


// Sent to the delegate when a user clicks on a notification in the notification center. This would be a good time to take action in response to user interacting with a specific notification.
// Important: If want to take an action when your application is launched as a result of a user clicking on a notification, be sure to implement the applicationDidFinishLaunching: method on your NSApplicationDelegate. The notification parameter to that method has a userInfo dictionary, and that dictionary has the NSApplicationLaunchUserNotificationKey key. The value of that key is the NSUserNotification that caused the application to launch. The NSUserNotification is delivered to the NSApplication delegate because that message will be sent before your application has a chance to set a delegate for the NSUserNotificationCenter.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    int status = [notification.actionButtonTitle intValue];
    switch (status) {
        
        case BONJOUR_RECEIVER_FAILED_OPEN_PORT:
        case BONJOUR_RECEIVER_FAILED_OPEN_BONJOUR:
        case BONJOUR_RECEIVER_FAILED_PUBLISH_BONJOUR:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/28 20:53:22" withLimitSec:10000 withComment:@"ネットワークの再建"];
            break;
        }
            
        case BONJOUR_RECEIVER_ACCEPTED_IOS:
//            ignore
            break;
            
        default:
            NSLog(@"status %d", status);
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/28 20:53:26" withLimitSec:0 withComment:@"未知のコード"];
            break;
    }
}

// Sent to the delegate when the Notification Center has decided not to present your notification, for example when your application is front most. If you want the notification to be displayed anyway, return YES.
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
//    [TimeMine setTimeMineLocalizedFormat:@"2014/10/16 23:33:39" withLimitSec:0 withComment:@"shouldPresentNotification 通知系なのでいらないっぽい。"];
    return true;
}





/*
 NSNetServiceDelegateのデリゲート
 */
/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"netServiceWillPublish! なんだけど、これの2度目ができないような気がする。同じport指してるからかな。 %@", sender);
}


/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"netServiceDidPublish!!!!!!! %@", sender);
    
    bonjourSocketHandle = [[NSFileHandle alloc] initWithFileDescriptor:[bonjourSocket socket] closeOnDealloc:YES];
    if (bonjourSocketHandle) {
        /*
         接続を受け付けた後の通知をセット
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptConnection:) name:NSFileHandleConnectionAcceptedNotification object:bonjourSocketHandle];
        
        [bonjourSocketHandle acceptConnectionInBackgroundAndNotify];
    } else {
        [self notifyToUserWithStatus:BONJOUR_RECEIVER_FAILED_PUBLISH_BONJOUR withTitle:@"server failed" message:@"failed to publish bonjour network. reboot?"];
    }
    
    
//    試しにここでresetしたら、繰り返せた。
//    [self resetBonjourService];
}



/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"didNotPublish! errorDict%@", errorDict);
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/23 14:15:06" withLimitSec:10000 withComment:@"publishに失敗したケース、通知。原因なんだろうな。wifi切れてても行けるはずなんだけど。"];
}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
- (void)netServiceWillResolve:(NSNetService *)sender {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/16 23:33:11" withLimitSec:0 withComment:@"netServiceWillResolve"];
}


/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/16 23:32:59" withLimitSec:0 withComment:@"netServiceDidResolveAddress"];
}


/* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
 */
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/16 23:32:37" withLimitSec:0 withComment:@"didNotResolve"];
}


/* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
 */
//- (void)netServiceDidStop:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
 */
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    NSLog(@"didUpdateTXTRecordData");
}



/* Sent to a published NSNetService instance's delegate when a new connection is
 * received. Before you can communicate with the connecting client, you must -open
 * and schedule the streams. To reject a connection, just -open both streams and
 * then immediately -close them.
 
 
 * To enable TLS on the stream, set the various TLS settings using
 * kCFStreamPropertySSLSettings before calling -open. You must also specify
 * kCFBooleanTrue for kCFStreamSSLIsServer in the settings dictionary along with
 * a valid SecIdentityRef as the first entry of kCFStreamSSLCertificates.
 */
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    NSLog(@"didAcceptConnectionWithInputStream");
}

/**
 クライアントのconnectingを受け取った「後」
 */
- (void) acceptConnection:(NSNotification *)notif {
    [self setState:BONJOUR_RECEIVER_ACCEPTED_IOS];
    
    /*
     通知
     */
    NSDate * nowDate = [NSDate date];//現在のシステム時間
    NSString *nowDateStr = [[NSString alloc]initWithFormat:@"time:%@", nowDate];
    [self notifyToUserWithStatus:BONJOUR_RECEIVER_ACCEPTED_IOS withTitle:@"device connected" message:nowDateStr];
    
    NSLog(@"acceptConnection!");
    /*
        定義済みのpointerを使わないと、deallocされてしまう。
     */
    bonjourAcceptedHandle = [[notif userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
    
    bonjourAcceptedHandle.writeabilityHandler = ^(NSFileHandle *fileHandle) {
        NSData *data = [fileHandle availableData];
        
        /*
         detect disconnected
         */
        if ([data length] == 0) {
            
            //このコードで、再接続時の100%を防げる。
            fileHandle.writeabilityHandler = nil;
            fileHandle.readabilityHandler = nil;
            NSLog(@"disconnect");
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:fileHandle];
            
            [self setState:BONJOUR_RECEIVER_CLOSING];
            return;
        }
        
        NSLog(@"doooo");
    };
}

















CGPoint currentInputPoint;

CGPoint currentMousePoint;
CGPoint beforeInputPoint;

- (void) execute:(NSData *)data {
    switch (state) {
        case BONJOUR_RECEIVER_ACCEPTED_IOS:{
            /*
             マウス入力とキー入力の解析と再現を行う。
             */
            MousePadData mousePadData;
            [data getBytes:&mousePadData length:sizeof(MousePadData)];
            
            /*
             マウスの位置入力
             */
            CGPoint emitPoint = [self mouseUpdate:mousePadData.mousePoint withType:mousePadData.mouseEventType];
            
            
            /*
             マウスのボタン入力
             */
            [self mouseButtonStatusUpdate:emitPoint left:mousePadData.left right:mousePadData.right andCenter:mousePadData.center];
            
            
            /*
             キーの入出力
             */
            [self keysStatusUpdate:emitPoint
                          keySlots:mousePadData.keySlots
             ];
            break;
        }
            
        default:
            break;
    }
}

/*
 キーのdown/upを実行する。
 Byteに0が入っていれば、キーの状態を変更する。
 */
- (void) keysStatusUpdate:(CGPoint)inputPoint
                 keySlots:(Byte [])keySlots {
    for (int i = 0; i < 8; i++) {
        Byte a = keySlots[i];
        //        NSLog(@"a %d", a);
    }
    //    NSLog(@"key0 %d", key0);
    //    NSLog(@"key1 %d", key1);
    //    NSLog(@"key2 %d", key2);
    //    NSLog(@"key3 %d", key3);//40,,,? 0x28 16  2 + 8
    //    NSLog(@"key4 %d", key4);
    //    if (key3 != 0) {
    //
    //        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 23:14:46" withLimitSec:100000 withComment:@"0でなければ、そのキーをオンにする。次に0になったら、そのキーをオフにする。"];
    //    }
}

/*
 マウスのdownを実行する
 
 */
- (void) mouseButtonStatusUpdate:(CGPoint)inputPoint left:(Byte)left right:(Byte)right andCenter:(Byte)center {
    /*
     マウスの 左/右/その他のボタン
     */
    switch (left) {
        case MOUSE_BUTTON_DOWN:{
            CGEventRef down = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventLeftMouseDown, inputPoint, kCGMouseButtonLeft);
            CGEventPost(kCGHIDEventTap, down);
            CFRelease(down);
            break;
        }
            
        case MOUSE_BUTTON_DRAG:{
            CGEventRef drag = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventLeftMouseDragged, inputPoint, kCGMouseButtonLeft);
            CGEventPost(kCGHIDEventTap, drag);
            CFRelease(drag);
            break;
        }
            
        case MOUSE_BUTTON_UP:{
            CGEventRef up = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventLeftMouseUp, inputPoint, kCGMouseButtonLeft);
            CGEventPost(kCGHIDEventTap, up);
            CFRelease(up);
            break;
        }
            
        case MOUSE_DOUBLE_CLICK:{
            break;
        }
            
        default:
            break;
    }
    
    switch (right) {
        case MOUSE_BUTTON_DOWN:{
            CGEventRef down = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventRightMouseDown, inputPoint, kCGMouseButtonRight);
            CGEventPost(kCGHIDEventTap, down);
            CFRelease(down);
            break;
        }
            
        case MOUSE_BUTTON_DRAG:{
            CGEventRef drag = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventRightMouseDragged, inputPoint, kCGMouseButtonRight);
            CGEventPost(kCGHIDEventTap, drag);
            CFRelease(drag);
            break;
        }
            
        case MOUSE_BUTTON_UP:{
            CGEventRef up = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventRightMouseUp, inputPoint, kCGMouseButtonRight);
            CGEventPost(kCGHIDEventTap, up);
            CFRelease(up);
            break;
        }
            
        case MOUSE_DOUBLE_CLICK:{
            break;
        }
            
        default:
            break;
    }
    
    /*
     draggable wheel
     up/down 以外に、increase/decreaseがある
     */
    switch (center) {
        case MOUSE_BUTTON_DOWN:{
            CGEventRef down = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventOtherMouseDown, inputPoint, kCGMouseButtonCenter);
            CGEventPost(kCGHIDEventTap, down);
            CFRelease(down);
            break;
        }
            
        case MOUSE_BUTTON_DRAG:{
            CGEventRef drag = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventOtherMouseDragged, inputPoint, kCGMouseButtonCenter);
            CGEventPost(kCGHIDEventTap, drag);
            CFRelease(drag);
            break;
        }
            
        case MOUSE_BUTTON_UP:{
            CGEventRef up = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventOtherMouseUp, inputPoint, kCGMouseButtonCenter);
            CGEventPost(kCGHIDEventTap, up);
            CFRelease(up);
            break;
        }
            
        case MOUSE_DOUBLE_CLICK:{
            break;
        }
            
        case MOUSE_WHEEL_UP:{
            break;
        }
            
        case MOUSE_WHEEL_DOWN:{
            break;
        }
            
        default:
            break;
    }
    
    //    void doubleClick(int clickCount) {
    //    int clickCount = 2;
    //CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, inputPoint, kCGMouseButtonLeft);
    //CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, clickCount);
    //CGEventPost(kCGHIDEventTap, theEvent);
    //
    //CGEventSetType(theEvent, kCGEventLeftMouseUp);
    //CGEventPost(kCGHIDEventTap, theEvent);
    //
    //CGEventSetType(theEvent, kCGEventLeftMouseDown);
    //CGEventPost(kCGHIDEventTap, theEvent);
    //
    //CGEventSetType(theEvent, kCGEventLeftMouseUp);
    //CGEventPost(kCGHIDEventTap, theEvent);
    //
    //CFRelease(theEvent);
    //    }
    
    
    
    //    if (right) {
    //        CGEventRef downRight = CGEventCreateMouseEvent(NULL, kCGEventRightMouseDown, inputPoint, kCGMouseButtonRight);
    //        CGEventPost(kCGHIDEventTap, downRight);
    //        CFRelease(downRight);
    //    }
    
    
    //    // Left button down
    //    CGEventRef leftDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(p.x, p.y), kCGMouseButtonLeft);
    //    CGEventPost(kCGHIDEventTap, leftDown);
    //
    //    // Left button up
    //    CGEventRef leftUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, CGPointMake(p.x, p.y), kCGMouseButtonLeft);
    //    CGEventPost(kCGHIDEventTap, leftUp);
    
    //    if (center) {
    //        CGEventRef downCenter = CGEventCreateMouseEvent(NULL, kCGEvent, inputPoint, kCGMouseButtonCenter);
    //        CGEventPost(kCGHIDEventTap, downCenter);
    //        CFRelease(downCenter);
    //    }
    
    //    CGEventRef keyA = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)52, true);
    //    CGEventPost(kCGEventKeyDown, keyA);
    //    CFRelease(keyA);
    //
    //
    //    CGEventRef keyP = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_P, true);
    //    CGEventPost(kCGSessionEventTap, keyP);
    //    CFRelease(keyP);
    //
    //    CGEventRef keyP = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_P, true);
    //    CGEventPost(kCGSessionEventTap, keyP);
    //    CFRelease(keyP);
    
    
    /*
     エンター単体を押すアクション
     キーを離すのに対応してない。一瞬で離している。
     別のを探さないとなー。
     */
    //    CGEventRef tapEnter = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)52, true);
    //    CGEventPost(kCGSessionEventTap, tapEnter);
    //    CFRelease(tapEnter);
}


/*
 マウスの移動イベントを実行する
 */
- (CGPoint) mouseUpdate:(CGPoint)inputPoint withType:(int)mouseEventType {
    
    switch (mouseEventType) {
        case MOUSE_EVENT_BEGAN:{
            break;
        }
        case MOUSE_EVENT_MOVED:{
            /*
             差分の反映
             */
            currentMousePoint.x += (inputPoint.x - beforeInputPoint.x);
            currentMousePoint.y += (inputPoint.y - beforeInputPoint.y);
            break;
        }
        default:
            break;
    }
    
    /*
     Mac側の画面サイズによるリミット
     */
    if (currentMousePoint.x < 0) currentMousePoint.x = 0;
    if (SCREEN_WIDTH < currentMousePoint.x) currentMousePoint.x = SCREEN_WIDTH;
    
    if (currentMousePoint.y < 0) currentMousePoint.y = 0;
    if (SCREEN_HEIGHT < currentMousePoint.y) currentMousePoint.y = SCREEN_HEIGHT;
    
    
    /*
     マウス動作
     */
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, currentMousePoint, kCGMouseButtonLeft );
    CGEventPost(kCGHIDEventTap, move);
    CFRelease(move);
    
    
    // 記録ポイントの更新
    beforeInputPoint = inputPoint;
    
    return currentMousePoint;
}




- (void)applicationWillTerminate:(NSNotification *)aNotification {
    /*
     すべての通知を外す(接続が確立してない場合でも消す)
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
