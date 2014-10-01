//
//  BonjourConnectionController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "BonjourConnectionController.h"
#import "TimeMine.h"
#import <UIKit/UIKit.h>

@implementation BonjourConnectionController

- (id) init {
    if (self = [super init]) {
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 22:01:49" withLimitSec:100000 withComment:@"接続の状態をどこかに表示せんとなー感がある。切断とか"];
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 22:01:54" withLimitSec:100000 withComment:@"サーバ側が落ちて切断されたときの受け取りが無い、気がする。"];
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:19:17" withLimitSec:100000 withComment:@"接続の状態変化を通知する機構が必要。こいつは今後の奴でも必要なので、"];
        
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:19:21" withLimitSec:100000 withComment:@"接続リトライ系の機構が必要。"];
        
        [self searchBonjourNetwork];
    }
    return self;
}

#define BONJOUR_DOMAIN  (@"")
#define BONJOUR_TYPE    (@"_mousepad._tcp")//_test._tcp
//#define BONJOUR_NAME    (@"hello!")
#define BONJOUR_TIMEOUT (5.0f)

int bonjourState;

typedef NS_ENUM(int, BONJOUR_STATE) {
    BONJOUR_SEARCHING,
    BONJOUR_CONNECTING,
    BONJOUR_CONNECTED,
    BONJOUR_DISCONNECTED
};


NSNetServiceBrowser *bonjourBrowser;
NSNetService *bonjourService;
NSOutputStream *bonjourOutputStream;

- (void) searchBonjourNetwork {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:19:38" withLimitSec:100000 withComment:@"サーチ開始から時間制限付きで探してるので、そのへんをビジュアル化しないとなー感ある。"];
    
    bonjourState = BONJOUR_SEARCHING;
    
    bonjourBrowser = [[NSNetServiceBrowser alloc] init];
    bonjourBrowser.delegate = self;
    [bonjourBrowser searchForServicesOfType:BONJOUR_TYPE inDomain:BONJOUR_DOMAIN];
}


/**
 NSNetServiceBrowserのdelegate
 */
/* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
 */
//- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {}


/* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
 */
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:19:48" withLimitSec:10000 withComment:@"探すのやめちゃったのでまたなんかしなきゃ"];
    NSLog(@"netServiceBrowserDidStopSearch");
}


/* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:19:52" withLimitSec:100000 withComment:@"探さなかった。オフライン時とかに発生しそう。"];
}


/* Sent to the NSNetServiceBrowser instance's delegate for each domain discovered. If there are more domains, moreComing will be YES. If for some reason handling discovered domains requires significant processing, accumulating domains until moreComing is NO and then doing the processing in bulk fashion may be desirable.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:19:56" withLimitSec:10000 withComment:@"ネットワーク見つけた感"];
}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered domain is no longer available.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:20:00" withLimitSec:100000 withComment:@"ネットワークから離脱した。故意かどうかはわからない。"];
}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [TimeMine setTimeMineLocalizedFormat:@"2014/11/11 9:20:04" withLimitSec:100000 withComment:@"ネットワークから離脱2、サーバの消滅と、時間で発生する。"];
    bonjourState = BONJOUR_DISCONNECTED;
}

/* Sent to the NSNetServiceBrowser instance's delegate for each service discovered. If there are more services, moreComing will be YES. If for some reason handling discovered services requires significant processing, accumulating services until moreComing is NO and then doing the processing in bulk fashion may be desirable.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    bonjourState = BONJOUR_CONNECTING;
    
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:20:09" withLimitSec:100000 withComment:@"クライアントだけをカットすると、\
     n回目以降でサーバ側がなんもできなくなるので、\
     根本からの接続ポイント作り直しをオートマチックに行う仕掛けが必要そう。 nは通信方式の数に依存。勝手にlocalとか着いてるからな。。"];
    
    bonjourService = [[NSNetService alloc] initWithDomain:[aNetService domain] type:[aNetService type] name:[aNetService name]];
    
    if (bonjourService) {
        bonjourService.delegate = self;
        [bonjourService resolveWithTimeout:BONJOUR_TIMEOUT];
    } else {
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:20:12" withLimitSec:1000 withComment:@"接続失敗、理由は不明"];
    }
}



/**
 NSNetServiceDelegateのdelegate
 */
/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
- (void)netServiceWillPublish:(NSNetService *)sender {
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:20:37" withLimitSec:1000 withComment:@"展開開始、なんかまわすのの+1"];
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:20:40" withLimitSec:0 withComment:@"ネットワーク展開できなかった"];
}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
//- (void)netServiceWillResolve:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
/**
 接続完了からの動作を行う
 複数接続先が現れる可能性がある。んだがこれどうなるんだろう。
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"connected sender is %@", sender);
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:29:16" withLimitSec:100000 withComment:@"接続先の判定を行う感じ。事前になにか要素をセットしておく形にするか。"];
    
    NSInputStream *inputStream;
    
    bool result = [sender getInputStream:&inputStream outputStream:&bonjourOutputStream];
    
    if (result) {
        bonjourOutputStream.delegate = self;
        
        [bonjourOutputStream open];
        [bonjourOutputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:20:52" withLimitSec:0 withComment:@"接続完了からのエラー、発生したら切断状態にしてから接続をやり直す。"];
    }
}

/* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
 */
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve");
}

/* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
 */
- (void)netServiceDidStop:(NSNetService *)sender {
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/02 0:00:44" withLimitSec:100000 withComment:@"自動的に再接続、なんだけど実際どの単位での準備が必要かわかってない。"];
}

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
 NSStreamのdelegate
 */

/**
 NSStreamEventNone = 0,
 NSStreamEventOpenCompleted = 1UL << 0,
 NSStreamEventHasBytesAvailable = 1UL << 1,
 NSStreamEventHasSpaceAvailable = 1UL << 2,
 NSStreamEventErrorOccurred = 1UL << 3,
 NSStreamEventEndEncountered = 1UL << 4
 */
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    if ((eventCode & NSStreamEventOpenCompleted) != 0) {
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/11 9:21:04" withLimitSec:100000 withComment:@"ここまでこないと接続完全完了になってない。接続が完了したので、なんか通知しないとな"];
        
        bonjourState = BONJOUR_CONNECTED;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"bonjour connected."
                                                        message:@"ok"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    if ((eventCode & NSStreamEventHasBytesAvailable) != 0) {
        NSLog(@"NSStreamEventHasBytesAvailable");
    }
    
    if ((eventCode & NSStreamEventHasSpaceAvailable) != 0) {
        //        NSLog(@"NSStreamEventHasSpaceAvailable");
    }
    
    if ((eventCode & NSStreamEventErrorOccurred) != 0) {
        NSLog(@"NSStreamEventErrorOccurred");
    }
    
    if ((eventCode & NSStreamEventEndEncountered) != 0) {
        NSLog(@"NSStreamEventEndEncountered");
    }
    
}


- (bool) isBonjourConnected {
    if (bonjourOutputStream) return true;
    return false;
}



struct MousePadData {
    CGPoint mousePoint;
    int mouseEventType;
    int inputKeys;
};
typedef struct MousePadData MousePadData;

- (void) sendPoint:(CGPoint)point withType:(int)type andKeys:(int)key {
    if (![self isBonjourConnected]) return;
    if (bonjourState != BONJOUR_CONNECTED) return;

    MousePadData mousePadData;
    mousePadData.mousePoint = point;
    mousePadData.mouseEventType = type;
    mousePadData.inputKeys = 0;
    
    NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(MousePadData)];
    [bonjourOutputStream write:[data bytes] maxLength:[data length]];
}


@end
