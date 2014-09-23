//
//  BonjourConnectionController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "BonjourConnectionController.h"
#import "TimeMine.h"

@implementation BonjourConnectionController

- (id) init {
    if (self = [super init]) {
        [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:23:05" withLimitSec:10000 withComment:@"接続の状態をどこかに表示せんとなー感がある。切断とか"];
        
        [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:44:12" withLimitSec:10000 withComment:@"接続の状態変化を通知する機構が必要。こいつは今後の奴でも必要なので、"];
        
        [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:23:51" withLimitSec:10000 withComment:@"接続リトライ系の機構が必要。"];
        
        
        [self searchBonjourNetwork];
    }
    return self;
}

#define BONJOUR_DOMAIN  (@"")
#define BONJOUR_TYPE    (@"_mousepad._tcp")//_test._tcp
//#define BONJOUR_NAME    (@"hello!")
#define BONJOUR_TIMEOUT (5.0f)


NSNetServiceBrowser *bonjourBrowser;
NSNetService *bonjourService;
NSOutputStream *bonjourOutputStream;


- (void) searchBonjourNetwork {
    NSLog(@"start searching..");
    bonjourBrowser = [[NSNetServiceBrowser alloc] init];
    bonjourBrowser.delegate = self;
    [bonjourBrowser searchForServicesOfType:BONJOUR_TYPE inDomain:BONJOUR_DOMAIN];
}




/**
 NSNetServiceBrowserのdelegate
 */
/* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
 */
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"netServiceBrowserWillSearch");
}

/* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
 */
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"netServiceBrowserDidStopSearch");
}

/* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    NSLog(@"didNotSearch");
}

/* Sent to the NSNetServiceBrowser instance's delegate for each domain discovered. If there are more domains, moreComing will be YES. If for some reason handling discovered domains requires significant processing, accumulating domains until moreComing is NO and then doing the processing in bulk fashion may be desirable.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"didFindDomain");
}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered domain is no longer available.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveDomain");
}

/* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService");
    /**
     サーバ側が停止したり、圏外に出ることで発行される。
     */
}

/* Sent to the NSNetServiceBrowser instance's delegate for each service discovered. If there are more services, moreComing will be YES. If for some reason handling discovered services requires significant processing, accumulating services until moreComing is NO and then doing the processing in bulk fashion may be desirable.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    /**
     クライアントだけをカットすると、
     n回目以降でサーバ側がなんもできなくなるので、
     根本からの接続ポイント作り直しをオートマチックに行う仕掛けが必要そう。
     
     nは通信方式の数に依存。勝手にlocalとか着いてるからな。。
     */
    NSLog(@"connected");
    bonjourService = [[NSNetService alloc] initWithDomain:[aNetService domain] type:[aNetService type] name:[aNetService name]];
    
    /**
     if exist, connected.
     not, connection was failed.
     */
    if (bonjourService) {
        bonjourService.delegate = self;
        [bonjourService resolveWithTimeout:BONJOUR_TIMEOUT];
    } else {
        NSLog(@"connection failed");
    }
}



/**
 NSNetServiceDelegateのdelegate
 */
/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"netServiceWillPublish");
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"netServiceDidPublish");
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"didNotPublish");
}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"netServiceWillResolve");
}

/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
/**
 接続完了からの動作を行う
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"netServiceDidResolveAddress");
    NSInputStream *inputStream;
    
    bool result = [sender getInputStream:&inputStream outputStream:&bonjourOutputStream];
    
    if (result) {
        bonjourOutputStream.delegate = self;
        
        [bonjourOutputStream open];
        [bonjourOutputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        NSLog(@"netServiceDidResolveAddress over");
    } else {
        NSLog(@"failed to ready stream toward connection");
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
    NSLog(@"netServiceDidStop");
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
        NSLog(@"NSStreamEventOpenCompleted");
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"network connection found"
        //                                                        message:@"hyahha-!"
        //                                                       delegate:nil
        //                                              cancelButtonTitle:@"OK"
        //                                              otherButtonTitles:nil];
        //        [alert show];
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

- (bool) isConnected {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:55:23" withLimitSec:10000 withComment:@"接続チェック、状態持たないといけない。"];
    return bonjourOutputStream;
}


- (void) sendData:(NSData *)data {
    [TimeMine setTimeMineLocalizedFormat:@"2014/09/23 18:41:13" withLimitSec:10000 withComment:@"データを送付する。"];
    if (![self isConnected]) return;
    
    [bonjourOutputStream write:[data bytes] maxLength:[data length]];
}


@end
