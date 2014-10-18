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

#import "Messengers.h"

@implementation BonjourConnectionController

- (id) init {
    if (self = [super init]) {
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/22 14:27:22" withLimitSec:100000 withComment:@"サーバ側が落ちて切断されたときの受け取りが無い、気がする。"];
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/22 14:27:25" withLimitSec:100000 withComment:@"接続リトライ系の機構が必要。"];
        
        messenger = [[KSMessenger alloc] initWithBodyID:self withSelector:@selector(receiver:) withName:MESSENGER_BONJOURCONTROLLER];
        [messenger connectParent:MESSENGER_MAINVIEWCONTROLLER];
        
        [self searchBonjourNetwork];
    }
    return self;
}

- (void) receiver:(NSNotification *)notif {
    
}




#define BONJOUR_DOMAIN  (@"")
#define BONJOUR_TYPE    (@"_mousepad._tcp")//_test._tcp
//#define BONJOUR_NAME    (@"hello!")
#define BONJOUR_TIMEOUT (5.0f)

int bonjourState;

typedef NS_ENUM(int, BONJOUR_STATE) {
    STATE_BONJOUR_SEARCHING,
    STATE_BONJOUR_CONNECTING,
    STATE_BONJOUR_CONNECTED,
    STATE_BONJOUR_DISCONNECTED
};




NSNetServiceBrowser *bonjourBrowser;
NSNetService *bonjourService;
NSOutputStream *bonjourOutputStream;

- (void) searchBonjourNetwork {
    bonjourState = STATE_BONJOUR_SEARCHING;
    
    
    [messenger callParent:BONJOUR_MESSAGE_SEARCHING, nil];
    
    
    bonjourBrowser = [[NSNetServiceBrowser alloc] init];
    bonjourBrowser.delegate = self;
    [bonjourBrowser searchForServicesOfType:BONJOUR_TYPE inDomain:BONJOUR_DOMAIN];
}

- (void) resetSearchBonjourNetwork {
    bonjourState = STATE_BONJOUR_SEARCHING;
    
    [bonjourService stop];
    
    [messenger callParent:BONJOUR_MESSAGE_SEARCHING, nil];

    [bonjourBrowser stop];
    [bonjourBrowser searchForServicesOfType:BONJOUR_TYPE inDomain:BONJOUR_DOMAIN];
}


/**
 NSNetServiceBrowserのdelegate
 */
/* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
 */
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netService BrowserWillSearch"], nil];
}


/* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
 */
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netServiceBrowser DidStopSearch"], nil];
}


/* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    [messenger callParent:BONJOUR_MESSAGE_FAILED_TO_SEARCH,
     [messenger tag:@"info" val:@"netServiceBrowser didNotSearch"],
     [messenger tag:@"error" val:errorDict],
     nil];
}


/* Sent to the NSNetServiceBrowser instance's delegate for each domain discovered. If there are more domains, moreComing will be YES. If for some reason handling discovered domains requires significant processing, accumulating domains until moreComing is NO and then doing the processing in bulk fashion may be desirable.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netServiceBrowser didFindDomain"], nil];
}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered domain is no longer available.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netServiceBrowser didRemoveDomain"], nil];
}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    bonjourState = STATE_BONJOUR_DISCONNECTED;
    
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netServiceBrowser didRemoveService"], nil];
}

/* Sent to the NSNetServiceBrowser instance's delegate for each service discovered. If there are more services, moreComing will be YES. If for some reason handling discovered services requires significant processing, accumulating services until moreComing is NO and then doing the processing in bulk fashion may be desirable.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSString *connectedServerName = @"適当な名前";
    [messenger callParent:BONJOUR_MESSAGE_SEARCHED,
     [messenger tag:@"connectedServerName" val:connectedServerName],
     nil];
    
    bonjourState = STATE_BONJOUR_CONNECTING;
    
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
    NSLog(@"???");
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
//- (void)netServiceDidPublish:(NSNetService *)sender {}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netService didNotPublish"], nil];
}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
//- (void)netServiceWillResolve:(NSNetService *)sender {}


/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"sender port:%ld", (long)sender.port);
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/17 14:55:02" withLimitSec:100000 withComment:@"ポート番号で違いが出てる。なるほどなーーこれらをコレクションしてどれでつなぐか、っていうのを見る必要は確かに無いわけだ。"];
    [TimeMine setTimeMineLocalizedFormat:@"2014/10/17 14:55:05" withLimitSec:10000 withComment:@"ここで止まる。"];
    
    [messenger callParent:BONJOUR_MESSAGE_CONNECTING, nil];
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
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netService didNotResolve"], nil];
}

/* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
 */
- (void)netServiceDidStop:(NSNetService *)sender {}

/* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
 */
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"netService didUpdateTXTRecordData"], nil];
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
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/27 14:58:00" withLimitSec:10000 withComment:@"ここまでくれば接続完了、"];
        [TimeMine setTimeMineLocalizedFormat:@"2014/10/17 15:01:58" withLimitSec:1000000 withComment:@"接続完了したので名前を入れる"];
        
        [messenger callParent:BONJOUR_MESSAGE_CONNECTED, [messenger tag:@"connectedServerName" val:@"bonjour server"], nil];
        bonjourState = STATE_BONJOUR_CONNECTED;
    }
    
//    if ((eventCode & NSStreamEventHasBytesAvailable) != 0) {
//        [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"NSStreamEventHasBytesAvailable"], nil];
//    }
    
//    if ((eventCode & NSStreamEventHasSpaceAvailable) != 0) {
//        [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"NSStreamEventHasSpaceAvailable"], nil];
//    }
    
    if ((eventCode & NSStreamEventErrorOccurred) != 0) {
        [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"NSStreamEventErrorOccurred"], nil];
    }
    
    if ((eventCode & NSStreamEventEndEncountered) != 0) {
        [messenger callParent:BONJOUR_MESSAGE_MISC, [messenger tag:@"info" val:@"NSStreamEventEndEncountered"], nil];
    }
    
}


- (bool) isBonjourConnected {
    if (bonjourOutputStream) return true;
    return false;
}


// 2014/10/13 16:54:55
struct MousePadData {
    CGPoint mousePoint;
    Byte mouseEventType;
    
    Byte left;
    Byte right;
    Byte center;
    
    Byte keySlots[8];
};

typedef struct MousePadData MousePadData;

/**
 ポイントの情報を送付する
 */
- (void) sendPoint:(CGPoint)point withType:(Byte)type andKeysData:(KeysData)KeysData {
    if (![self isBonjourConnected]) return;
    if (bonjourState != STATE_BONJOUR_CONNECTED) return;
    
    MousePadData mousePadData;
    mousePadData.mousePoint = point;
    mousePadData.mouseEventType = type;
    
    mousePadData.left = KeysData.left;
    mousePadData.right = KeysData.right;
    mousePadData.center = KeysData.center;
    
    mousePadData.keySlots[0] = KeysData.keySlots[0];
    mousePadData.keySlots[1] = KeysData.keySlots[1];
    mousePadData.keySlots[2] = KeysData.keySlots[2];
    mousePadData.keySlots[3] = KeysData.keySlots[3];
    mousePadData.keySlots[4] = KeysData.keySlots[4];
    mousePadData.keySlots[5] = KeysData.keySlots[5];
    mousePadData.keySlots[6] = KeysData.keySlots[6];
    mousePadData.keySlots[7] = KeysData.keySlots[7];
    
    
    NSData *data = [NSData dataWithBytes:&mousePadData length:sizeof(MousePadData)];
    [bonjourOutputStream write:[data bytes] maxLength:[data length]];
}

- (void) sendHeartBeat {
    MousePadData heartBeat;
    NSData *data = [NSData dataWithBytes:&heartBeat length:sizeof(MousePadData)];
    [bonjourOutputStream write:[data bytes] maxLength:[data length]];
}


@end
