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

unsigned long sizeOfMousePadData;


typedef NS_ENUM(int, BONJOUR_RECEIVER_STATE) {
    BONJOUR_RECEIVER_LAUNCHED,
    BONJOUR_RECEIVER_FAILED_OPEN_PORT,
    BONJOUR_RECEIVER_FAILED_OPEN_BONJOUR,
    BONJOUR_RECEIVER_FAILED_PUBLISH_BONJOUR,
    BONJOUR_RECEIVER_PUBLISHING,
    BONJOUR_RECEIVER_PUBLISHED,
    BONJOUR_RECEIVER_ACCEPTED,
    BONJOUR_RECEIVER_CLOSING,
    BONJOUR_RECEIVER_CLOSED,
    
    BONJOUR_RECEIVER_CONTROL
};


typedef NS_ENUM(int, NOTIFY_STATE) {
    NOTIFY_LAUNCHED,
    
    NOTIFY_FAILED_OPEN_PORT,
    NOTIFY_FAILED_OPEN_BONJOUR,
    NOTIFY_FAILED_PUBLISH_BONJOUR,
    
    NOTIFY_PUBLISHING,
    NOTIFY_PUBLISHED,
    
    NOTIFY_ACCEPTED,
    NOTIFY_DISCONNECTED,
    
    NOTIFY_CONTROL
};

typedef NS_ENUM(int, MESSAGE) {
    MESSAGE_HEARTBEAT,
    MESSAGE_REPUBLISH
};

NSSocketPort *bonjourSocket;
NSNetService *bonjourService;
NSFileHandle *bonjourAcceptedHandle;

NSUserNotificationCenter *notifier;

int bonjourState;
int currentPortNumber;

CGFloat SCREEN_WIDTH;
CGFloat SCREEN_HEIGHT;

NSMutableDictionary *screenInfo;

#define HEARTBEAT_TIMEOUT   (7.0)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setState:BONJOUR_RECEIVER_LAUNCHED];
    
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

    switch ([messenger execFrom:[messenger myName] viaNotification:notif]) {
        case MESSAGE_HEARTBEAT:{
            
            [self heartBeat:bonjourState];
            
            [messenger callMyself:MESSAGE_HEARTBEAT, [messenger withDelay:1.0f], nil];
            break;
        }
            
        case MESSAGE_REPUBLISH:
            switch (bonjourState) {
                case BONJOUR_RECEIVER_CLOSED:{
                    [self publishBonjourService];
                    break;
                }
                default:
                    break;
            }
            
            break;
    }
}


- (void) heartBeat:(int)currentBonjourState {
//    NSLog(@"heartBeating,,, %d", currentBonjourState);
    switch (currentBonjourState) {
        case BONJOUR_RECEIVER_PUBLISHING:
            break;
        case BONJOUR_RECEIVER_PUBLISHED:
            break;
        
            
        case BONJOUR_RECEIVER_ACCEPTED:{
            if (lastHeartBeatDate) {
                if (HEARTBEAT_TIMEOUT < [[NSDate date] timeIntervalSinceDate:lastHeartBeatDate]) {
                    [self disconnectBonjourService];
                    [self publishBonjourService];
                }
            }
            break;
        }
            
        case BONJOUR_RECEIVER_CLOSING:{
            [self setState:BONJOUR_RECEIVER_CLOSED];
            
            /*
             republishの予約を行う
             */
            [messenger callMyself:MESSAGE_REPUBLISH,
             [messenger withDelay:3.0f],
             nil];
            
            // notify to user.
            [self notifyToUserWithStatus:NOTIFY_DISCONNECTED withTitle:@"device disconnected." message:@"" isReceiveInput: NO];
            break;
        }
        
            
        default:
            break;
    }
}


/**
 Bonjourの切断を行う
 */
- (void) disconnectBonjourService {
    bonjourService.delegate = nil;
    [bonjourService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [bonjourService stop];
    
    bonjourService = nil;
    
    bonjourSocket = nil;
}

/**
 Bonjourの発効を行う
 */
- (void) publishBonjourService {
    /*
     bonjourSocketを初期化する。
     自動的にportが割り当てられる。
     */
    bonjourSocket = [[NSSocketPort alloc] init];
    
    if (!bonjourSocket) {
        [self notifyToUserWithStatus:NOTIFY_FAILED_OPEN_PORT withTitle:@"server failed" message:@"failed to locate bonjour network." isReceiveInput:NO];
        return;
    }
    
    /*
     現在bonjourSocketで使用しているport番号を取得
     */
    struct sockaddr_in addr = *((struct sockaddr_in *)[[bonjourSocket address] bytes]);
    socklen_t len = sizeof(addr);
    
    getsockname([bonjourSocket socket], (struct sockaddr *)&addr, &len);
    currentPortNumber = ntohs(addr.sin_port);
    
    /*
     bonjourで使用するサービスを展開
     */
    bonjourService = [[NSNetService alloc]initWithDomain:BONJOUR_DOMAIN type:BONJOUR_TYPE name:BONJOUR_NAME port:currentPortNumber];
    if (bonjourService) {
        bonjourService.delegate = self;
        [bonjourService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [bonjourService publish];
        [self setState:BONJOUR_RECEIVER_PUBLISHING];
    } else {
        [self notifyToUserWithStatus:NOTIFY_FAILED_OPEN_BONJOUR withTitle:@"server failed" message:@"failed to locate bonjour network." isReceiveInput:NO];
    }
}

- (void) setState:(int)nextState {
    bonjourState = nextState;
}



/**
 通知
 */
- (void) notifyToUserWithStatus:(int)status withTitle:(NSString *)title message:(NSString *)message isReceiveInput:(BOOL)receive {
    NSUserNotification * newUserNotification = [NSUserNotification new];
    newUserNotification.title = @"mousePadServer";
    newUserNotification.subtitle = title;
    newUserNotification.informativeText = message;
    
    NSDate *nowDate = [NSDate date];//現在のシステム時間
    NSString *nowDateStr = [[NSString alloc]initWithFormat:@"time:%@", nowDate];
    
    // set identity.
    newUserNotification.identifier = nowDateStr;
    
    newUserNotification.actionButtonTitle = [NSString stringWithFormat:@"%d", status];
    
    NSString *path = @"keyButtonImage.pdf";
    newUserNotification.contentImage = [[NSImage alloc] initWithContentsOfFile:path];
    
    if (receive) {
        newUserNotification.hasReplyButton = YES;
    }
    
    [notifier deliverNotification:newUserNotification];
}

/*
 Macの通知センターのデリゲート
 */
// Sent to the delegate when a notification delivery date has arrived. At this time, the notification has either been presented to the user or the notification center has decided not to present it because your application was already frontmost.
//- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {}


// Sent to the delegate when a user clicks on a notification in the notification center. This would be a good time to take action in response to user interacting with a specific notification.
// Important: If want to take an action when your application is launched as a result of a user clicking on a notification, be sure to implement the applicationDidFinishLaunching: method on your NSApplicationDelegate. The notification parameter to that method has a userInfo dictionary, and that dictionary has the NSApplicationLaunchUserNotificationKey key. The value of that key is the NSUserNotification that caused the application to launch. The NSUserNotification is delivered to the NSApplication delegate because that message will be sent before your application has a chance to set a delegate for the NSUserNotificationCenter.

/**
 notificationがタッチされた場合の挙動
 */
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    int notificationStatus = [notification.actionButtonTitle intValue];
    
    switch (notificationStatus) {
        case NOTIFY_LAUNCHED:
            break;
            
        case NOTIFY_FAILED_OPEN_PORT:
        case NOTIFY_FAILED_OPEN_BONJOUR:
        case NOTIFY_FAILED_PUBLISH_BONJOUR:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/28 20:53:22" withLimitSec:10000 withComment:@"ネットワークの再建"];
            break;
        }
            
        case NOTIFY_PUBLISHING:
            break;
            
        case NOTIFY_PUBLISHED:
            [self notifyToUserWithStatus:NOTIFY_CONTROL withTitle:@"input control" message:@"reboot(r) or quit(q)" isReceiveInput:YES];
            break;
            

        case NOTIFY_ACCEPTED:
            // do nothing
            break;
            
        case NOTIFY_DISCONNECTED:
//            if (notification.response) {
//                NSString *command = [notification.response string];
//                
//                if ([command hasPrefix:@"reboot"] || [command hasPrefix:@"r"]) {
//                    [self disconnectBonjourService];
//                    [self publishBonjourService];
//                }
//                
//                if ([command hasPrefix:@"quit"] || [command hasPrefix:@"q"]) {
//                    [self disconnectBonjourService];
//                    [NSApp terminate:nil];
//                }
//            }
            
            break;
        case NOTIFY_CONTROL:{
            if (notification.response) {
                NSString *command = [notification.response string];
                
                if ([command hasPrefix:@"reboot"] || [command hasPrefix:@"r"]) {
                    [self disconnectBonjourService];
                    [self publishBonjourService];
                }
                
                if ([command hasPrefix:@"quit"] || [command hasPrefix:@"q"]) {
                    [self disconnectBonjourService];
                    [NSApp terminate:nil];
                }
                
            } else {
                // do nothing with no command.
            }

            break;
        }
            
        default:{
            [TimeMine setTimeMineLocalizedFormat:@"2014/09/28 20:53:26" withLimitSec:0 withComment:@"未知のコード"];
            break;
        }
    }
}

// Sent to the delegate when the Notification Center has decided not to present your notification, for example when your application is front most. If you want the notification to be displayed anyway, return YES.
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return true;
}





/*
 NSNetServiceDelegateのデリゲート
 */
/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
//- (void)netServiceWillPublish:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
   
    if (bonjourState == BONJOUR_RECEIVER_PUBLISHED) {
        return;
    }
    
    NSFileHandle *bonjourSocketHandle = [[NSFileHandle alloc] initWithFileDescriptor:[bonjourSocket socket] closeOnDealloc:YES];
    if (bonjourSocketHandle) {
        /*
         bonjourの接続を受け付けた後の通知をセット
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptConnection:) name:NSFileHandleConnectionAcceptedNotification object:bonjourSocketHandle];
        
        [bonjourSocketHandle acceptConnectionInBackgroundAndNotify];
        
        [self setState:BONJOUR_RECEIVER_PUBLISHED];
        
        [self notifyToUserWithStatus:NOTIFY_PUBLISHED withTitle:@"New connection started." message:@"need control? tap this." isReceiveInput:NO];
    } else {
        [self notifyToUserWithStatus:NOTIFY_FAILED_PUBLISH_BONJOUR withTitle:@"server failed" message:@"failed to publish bonjour network." isReceiveInput:NO];
    }
    
}



/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
//- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
//- (void)netServiceWillResolve:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
//- (void)netServiceDidResolveAddress:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
 */
//- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {}


/* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
 */
//- (void)netServiceDidStop:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
 */
//- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {}



/* Sent to a published NSNetService instance's delegate when a new connection is
 * received. Before you can communicate with the connecting client, you must -open
 * and schedule the streams. To reject a connection, just -open both streams and
 * then immediately -close them.
 
 
 * To enable TLS on the stream, set the various TLS settings using
 * kCFStreamPropertySSLSettings before calling -open. You must also specify
 * kCFBooleanTrue for kCFStreamSSLIsServer in the settings dictionary along with
 * a valid SecIdentityRef as the first entry of kCFStreamSSLCertificates.
 */
//- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {}

/**
 クライアントのconnectingを受け取った「後」
 */
- (void) acceptConnection:(NSNotification *)notif {
    NSFileHandle *connectedHandle = [[notif userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
    
    if (connectedHandle) {} else {
        return;
    }
    
    
    [self setState:BONJOUR_RECEIVER_ACCEPTED];
    
    /*
     通知
     */
    [self notifyToUserWithStatus:NOTIFY_ACCEPTED withTitle:@"device connected" message:@"" isReceiveInput:NO];
    
    
    /*
     マウスの位置を画面の中心に
     */
    [self setMousePointToCenter];
    
    /*
     今後やり取りするデータサイズを取得
     */
    sizeOfMousePadData = sizeof(MousePadData);
    
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
            // below code is for avoiding CPU to be 100%.
            fileHandle.writeabilityHandler = nil;
            fileHandle.readabilityHandler = nil;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:fileHandle];
            [self disconnectBonjourService];
            
            [self setState:BONJOUR_RECEIVER_CLOSING];
            return;
        }
        
        [self execute:data];
    };
}

















CGPoint currentInputPoint;

CGPoint currentMousePoint;
CGPoint beforeInputPoint;

NSDate *lastHeartBeatDate;

- (void) execute:(NSData *)data {
    unsigned long len =[data length];
    for (int i = 0; i < len/sizeOfMousePadData; i++) {
        unsigned long offset = i * sizeOfMousePadData;
        NSData *partialData = [NSData dataWithBytesNoCopy:(char *)[data bytes] + offset
                                             length:sizeOfMousePadData
                                       freeWhenDone:NO];
        
        
        /*
         マウス入力の解析と再現を行う。
         */
        MousePadData mousePadData;
        [partialData getBytes:&mousePadData length:sizeof(MousePadData)];
        
        if (mousePadData.isHeartBeat) {
            lastHeartBeatDate = [NSDate date];
            continue;
        }
        
        /*
         マウスの位置入力
         */
        CGPoint emitPoint = [self mouseUpdate:mousePadData.mousePoint withType:mousePadData.mouseEventType];
        
        /*
         マウスのボタン入力
         */
        [self mouseButtonStatusUpdate:emitPoint left:mousePadData.left right:mousePadData.right andCenter:mousePadData.centerContainer];
        
//        /*
//         キーの入出力
//         */
//        [self keysStatusUpdate:emitPoint
//                      keySlots:mousePadData.keySlots
//         ];
    }
}

/*
 キーのdown/upを実行する。
 Byteに0が入っていれば、キーの状態を変更する。
 */
- (void) keysStatusUpdate:(CGPoint)inputPoint
                 keySlots:(Byte [])keySlots {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/26 13:24:58" withLimitSec:0 withComment:@"unused."];
//    for (int i = 0; i < 8; i++) {
//        Byte a = keySlots[i];
//        //        NSLog(@"a %d", a);
//    }
//    //    NSLog(@"key0 %d", key0);
//    //    NSLog(@"key1 %d", key1);
//    //    NSLog(@"key2 %d", key2);
//    //    NSLog(@"key3 %d", key3);//40,,,? 0x28 16  2 + 8
//    //    NSLog(@"key4 %d", key4);
//    //    if (key3 != 0) {
//    //
//    //        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 23:14:46" withLimitSec:100000 withComment:@"0でなければ、そのキーをオンにする。次に0になったら、そのキーをオフにする。"];
//    //    }
}

/*
 マウスのボタン処理アップデートを行う
 */
- (void) mouseButtonStatusUpdate:(CGPoint)inputPoint left:(Byte)left right:(Byte)right andCenter:(CenterContainer)centerContainer {
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
            
        default:{
            break;
        }
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
    switch (centerContainer.command) {
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
            
        case MOUSE_WHEEL_INCREASE:{
            CGEventRef increase = CGEventCreateScrollWheelEvent (CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGScrollEventUnitPixel, 1, centerContainer.wheelMoveAmount);
            CGEventPost(kCGHIDEventTap, increase);
            CFRelease(increase);
            break;
        }
            
        case MOUSE_WHEEL_DECREASE:{
            CGEventRef decrease = CGEventCreateScrollWheelEvent (CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGScrollEventUnitPixel, 1, centerContainer.wheelMoveAmount);
            CGEventPost(kCGHIDEventTap, decrease);
            CFRelease(decrease);
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

/**
 スクリーンの中心へとマウスを強制移動、アプリ内基準ポイントも移動する。
 */
- (void) setMousePointToCenter {
    CGPoint screenCenter = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    CGEventRef toCenterSet = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, screenCenter, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, toCenterSet);
    CFRelease(toCenterSet);

    currentMousePoint = screenCenter;
    beforeInputPoint = currentMousePoint;
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    /*
     すべての通知を外す(接続が確立してない場合でも消す)
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
