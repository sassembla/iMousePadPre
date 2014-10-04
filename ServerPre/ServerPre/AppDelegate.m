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
@property (weak) IBOutlet NSWindow *window;
@end



/**
 不特定のportを使ってBonjour経由でiOS側と接続する。
 */
@implementation AppDelegate

#define BONJOUR_DOMAIN  (@"")
#define BONJOUR_TYPE    (@"_mousepad._tcp")// _始まりで、protocolを書く。
#define BONJOUR_NAME    (@"hello!")


#define MOUSEVENT_BEGAN (0)
#define MOUSEVENT_MOVED (1)
#define MOUSEVENT_END   (2)


NSSocketPort *bonjourSocket;
NSNetService *bonjourService;
NSFileHandle *bonjourSocketHandle;
NSFileHandle *bonjourDataReadHandle;

NSUserNotificationCenter *notifier;

int state;


CGFloat SCREEN_WIDTH;
CGFloat SCREEN_HEIGHT;
CGFloat moveRatio;

NSMutableDictionary *screenInfo;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"boot!");
    
    /*
     画面サイズの取得
     */
    NSScreen *screen = [_window screen];
    screenInfo = [[NSMutableDictionary alloc]init];
    SCREEN_WIDTH = screen.frame.size.width;
    SCREEN_HEIGHT = screen.frame.size.height;
    
    
    moveRatio = 1.0f;
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/22 3:18:59" withLimitSec:100000 withComment:@"マウスの動作倍率、それなりに利用価値のある値だ。可変にしたいけどいつかだな。ただ、サーバ側で持つのは駄目だな。"];
    
    
    [self publishBonjourNetService];
}

- (void) notifyToUserWithStatus:(int)status withTitle:(NSString *)title message:(NSString *)message {
    NSUserNotification * newUserNotification = [NSUserNotification new];
    newUserNotification.actionButtonTitle = [[NSString alloc]initWithFormat:@"%d", status];
    newUserNotification.title = @"mouseServer";
    newUserNotification.subtitle = title;
    newUserNotification.informativeText = message;
    
    [notifier deliverNotification:newUserNotification];
}

- (void) publishBonjourNetService {
    
    notifier = [NSUserNotificationCenter defaultUserNotificationCenter];
    notifier.delegate = self;
    
    
    /**
     自動的にportを割り当てる
     */
    bonjourSocket = [[NSSocketPort alloc] init];
    bonjourSocket.delegate = self;
    
    if (!bonjourSocket) {
        [self notifyToUserWithStatus:BONJOUR_RECEIVER_FAILED_OPEN_PORT withTitle:@"server failed" message:@"failed to locate bonjour network. reboot?"];
        return;
    }
    
    /**
     使用しているport番号を取得
     */
    struct sockaddr_in addr = *((struct sockaddr_in *)[[bonjourSocket address] bytes]);
    socklen_t len = sizeof(addr);
    
    getsockname([bonjourSocket socket], (struct sockaddr *)&addr, &len);
    
    int portNumber = ntohs(addr.sin_port);
    
    
    /**
     bonjourで使用するサービスに関連づける
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




CGPoint currentInputPoint;

CGPoint currentMousePoint;
CGPoint beforeInputPoint;

- (void) execute:(NSData *)data {
    switch (state) {
        case BONJOUR_RECEIVER_ACCEPTED_IOS:{
            /*
             マウス入力とキー入力の解析と再現を行う。
             */
            struct MousePadData mousePadData;
            [data getBytes:&mousePadData length:sizeof(mousePadData)];

            /*
             キーの入出力
             */
            [self keysStatusUpdate:mousePadData.mousePoint
                              key0:mousePadData.key0
                              key1:mousePadData.key1
                              key0:mousePadData.key2
                              key1:mousePadData.key3
                              key0:mousePadData.key4
                              key1:mousePadData.key5
                              key0:mousePadData.key6
                              key1:mousePadData.key7
             ];
            
            /*
             マウスのボタン入力
             */
            [self mouseButtonStatusUpdate:mousePadData.mousePoint left:mousePadData.left right:mousePadData.right andCenter:mousePadData.center];
            
            /*
             マウスの位置入力
             */
            [self mouseUpdate:mousePadData.mousePoint withType:mousePadData.mouseEventType];
            
            break;
        }
            
        default:
            break;
    }
}

/**
 キーのdownを実行する
 code1, code2にそれぞれ4つのキーを入れている。
 */
- (void) keysStatusUpdate:(CGPoint)inputPoint
                     key0:(Byte)key0
                     key1:(Byte)key1
                     key0:(Byte)key2
                     key1:(Byte)key3
                     key0:(Byte)key4
                     key1:(Byte)key5
                     key0:(Byte)key6
                     key1:(Byte)key7 {
    
}

/**
 マウスのdownを実行する */
- (void) mouseButtonStatusUpdate:(CGPoint)inputPoint left:(bool)left right:(bool)right andCenter:(bool)center {
    /*
     マウスの 左/右/その他のボタン
    */
    
    if (left) {
        CGEventRef downLeft = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, inputPoint, kCGMouseButtonLeft);
        CGEventPost(kCGHIDEventTap, downLeft);
        CFRelease(downLeft);
    }
    
    if (right) {
        CGEventRef downRight = CGEventCreateMouseEvent(NULL, kCGEventRightMouseDown, inputPoint, kCGMouseButtonRight);
        CGEventPost(kCGHIDEventTap, downRight);
        CFRelease(downRight);
    }

    if (center) {
        CGEventRef downCenter = CGEventCreateMouseEvent(NULL, kCGEventRightMouseDown, inputPoint, kCGMouseButtonCenter);
        CGEventPost(kCGHIDEventTap, downCenter);
        CFRelease(downCenter);
    }
    
    
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


    /**
     エンター単体を押すアクション
     キーを離すのに対応してない。一瞬で離している。
     別のを探さないとなー。
     */
//    CGEventRef tapEnter = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)52, true);
//    CGEventPost(kCGSessionEventTap, tapEnter);
//    CFRelease(tapEnter);
}



/**
 クリックの状態取得
 */
- (bool) isRightClicking {
    return false;
}

- (bool) isLeftClicking {
    return false;
}

- (bool) isCenterClicking {
    return false;
}


/**
 マウスの移動イベントを実行する
 */
- (void) mouseUpdate:(CGPoint)inputPoint withType:(int)mouseEventType {
    
    switch (mouseEventType) {
        case MOUSEVENT_BEGAN:{
            /*
             タッチが開始された瞬間に、Mac側のマウスの位置を取得し反映させる
             */
            NSPoint mousePoint = [NSEvent mouseLocation];
            
            currentMousePoint.x = mousePoint.x;
            currentMousePoint.y = mousePoint.y;
            break;
        }
        case MOUSEVENT_MOVED:
            /*
             差分の反映
             */
            currentMousePoint.x += (inputPoint.x - beforeInputPoint.x) * moveRatio;
            currentMousePoint.y += (inputPoint.y - beforeInputPoint.y) * moveRatio;
            break;
            
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
}

/**
 Macの通知センターのデリゲート
 */
// Sent to the delegate when a notification delivery date has arrived. At this time, the notification has either been presented to the user or the notification center has decided not to present it because your application was already frontmost.
//- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {}


// Sent to the delegate when a user clicks on a notification in the notification center. This would be a good time to take action in response to user interacting with a specific notification.
// Important: If want to take an action when your application is launched as a result of a user clicking on a notification, be sure to implement the applicationDidFinishLaunching: method on your NSApplicationDelegate. The notification parameter to that method has a userInfo dictionary, and that dictionary has the NSApplicationLaunchUserNotificationKey key. The value of that key is the NSUserNotification that caused the application to launch. The NSUserNotification is delivered to the NSApplication delegate because that message will be sent before your application has a chance to set a delegate for the NSUserNotificationCenter.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSLog(@"notif %@", notification);

    
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
//- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {}



/**
 NSNetServiceDelegateのデリゲート
 */
/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
//- (void)netServiceWillPublish:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    
    bonjourSocketHandle = [[NSFileHandle alloc] initWithFileDescriptor:[bonjourSocket socket] closeOnDealloc:YES];
    if (bonjourSocketHandle) {
        /**
         通知をセット
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptConnection:) name:NSFileHandleConnectionAcceptedNotification object:bonjourSocketHandle];
        
        [bonjourSocketHandle acceptConnectionInBackgroundAndNotify];
    } else {
        [self notifyToUserWithStatus:BONJOUR_RECEIVER_FAILED_PUBLISH_BONJOUR withTitle:@"server failed" message:@"failed to publish bonjour network. reboot?"];
    }
}


/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 19:08:08" withLimitSec:0 withComment:@"publishに失敗したケース、通知。原因なんだろうな。wifi切れてても行けるはずなんだけど。"];
}

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



- (void) acceptConnection:(NSNotification *)notif {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 2:31:37" withLimitSec:100000 withComment:@"通信ができるようになった際のハンドラ。反対側に対してなんか返さんとな。\
     この初期通信化時点でパラメータ返すと差分がでてしまう気がするので、iOS側から接続先の情報が取れる手段を見つけた方が良い。"];
    
    NSString *connectedHandle = [notif userInfo][NSFileHandleNotificationFileHandleItem];
    
    NSString *message = [[NSString alloc]initWithFormat:@"サーバ側、誰と繋がったか表示したいがさて、名前がわからない。socketから引けって感じなのかな。とりあえず後回し。 %@", connectedHandle];
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 2:31:52" withLimitSec:100000 withComment:message];
    
    
    
    [self setState:BONJOUR_RECEIVER_ACCEPTED_IOS];
    
    /**
     通知
     */
    NSDate * nowDate = [NSDate date];//現在のシステム時間
    NSString *nowDateStr = [[NSString alloc]initWithFormat:@"time:%@", nowDate];
    [self notifyToUserWithStatus:BONJOUR_RECEIVER_ACCEPTED_IOS withTitle:@"device connected" message:nowDateStr];
    
    
    bonjourDataReadHandle = [[notif userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
    
    
    /*
     Bonjour越しのデータを受け取るハンドラの設置
     */
    bonjourDataReadHandle.readabilityHandler = ^(NSFileHandle *fileHandle) {
        @try {
            NSData *data = [fileHandle availableData];
            [self execute:data];
        }
        @catch (NSException *exception) {
            NSLog(@"exception %@", exception);
        }
        @finally {
            
        }
        
    };
}




- (void)applicationWillTerminate:(NSNotification *)aNotification {
    /**
     すべての通知を外す(接続が確立してない場合でも消す)
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
