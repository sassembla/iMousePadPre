//
//  AppDelegate.m
//  ServerPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "AppDelegate.h"
#include <netinet/in.h>

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end




/**
 こいつを改造していって、接続だけの状態にする。
 また接続の条件を割り出す。
 */
@implementation AppDelegate

#define BONJOUR_PORT    (8823)
#define BONJOUR_DOMAIN  (@"")
#define BONJOUR_TYPE    (@"_mousepad._tcp")// _test._tcp _始まりで、protocolを書く。
#define BONJOUR_NAME    (@"hello!")



NSSocketPort *bonjourSocket;
NSNetService *bonjourService;
NSFileHandle *bonjourSocketHandle;
NSFileHandle *bonjourDataReadHandle;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self publishBonjourNetService];
}

- (void) publishBonjourNetService {
    bonjourSocket = [[NSSocketPort alloc] initWithTCPPort:BONJOUR_PORT];
//    bonjourSocket = [[NSSocketPort alloc]initWithTCPPort:<#(unsigned short)#>];
    bonjourSocket.delegate = self;
    
    if (bonjourSocket) {
        
        UInt8 portNum = 0;
        struct sockaddr_in *addr4;
        NSData *data = [bonjourSocket address];
        if (data) {
            addr4 = (struct sockaddr_in *)[data bytes];
            portNum = ntohs(addr4->sin_port);
        }

        
        bonjourService = [[NSNetService alloc]initWithDomain:BONJOUR_DOMAIN type:BONJOUR_TYPE name:BONJOUR_NAME port:BONJOUR_PORT
                          ];
        if (bonjourService) {
            bonjourService.delegate = self;
            [bonjourService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [bonjourService publish];
        } else {
            NSLog(@"invalid NSNetSevice");
        }
    } else {
        NSLog(@"failed to create NSSocketPort, maybe doesn't close? %@", bonjourSocket);
    }
}

/**
 NSPortのデリゲート
 */
- (void)handlePortMessage:(NSPortMessage *)message {
    NSLog(@"handlePortMessage %@", message);
}


/**
 NSNetServiceDelegateのデリゲート
 */
/* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
 */
- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"netServiceWillPublish");
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"netServiceDidPublish %@", sender);
    
    
    bonjourSocketHandle = [[NSFileHandle alloc] initWithFileDescriptor:[bonjourSocket socket] closeOnDealloc:YES];
    if (bonjourSocketHandle) {
        /**
         通知をセット
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptConnection:) name:NSFileHandleConnectionAcceptedNotification object:bonjourSocketHandle];
        
        [bonjourSocketHandle acceptConnectionInBackgroundAndNotify];
    }
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"didNotPublish %@", sender);
}

/* Sent to the NSNetService instance's delegate prior to resolving a service on the network. If for some reason the resolution cannot occur, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotResolve: method.
 */
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"netServiceWillResolve");
}

/* Sent to the NSNetService instance's delegate when one or more addresses have been resolved for an NSNetService instance. Some NSNetService methods will return different results before and after a successful resolution. An NSNetService instance may get resolved more than once; truly robust clients may wish to resolve again after an error, or to resolve more than once.
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"netServiceDidResolveAddress");
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


- (void) acceptConnection:(NSNotification *)notif {
    NSLog(@"accept!!");
    bonjourDataReadHandle = [[notif userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveData:) name:NSFileHandleDataAvailableNotification object:bonjourDataReadHandle];
    
    [bonjourDataReadHandle waitForDataInBackgroundAndNotify];
}

- (void) receiveData:(NSNotification *)notif {
    NSData *data = [bonjourDataReadHandle availableData];
    
    /**
     マウスの形状ににたデータを受け取りたいところ。
     まあ出す側で調整すればいいしこっちでバカ正直にやりたくないんだが。
     */
//    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", string);
    
    NSLog(@"ovr! %lu", (unsigned long)[data length]);
    
    if ([data length] == 0) {
//        閉じよう。
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:bonjourDataReadHandle];
        [bonjourDataReadHandle closeFile];
        
        
//        [bonjourDataReadHandle ]
        NSLog(@"closed. ready for reconnect %@", bonjourDataReadHandle);
//        [bonjourDataReadHandle ]
//        [bonjourService removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//        [bonjourService stop];
        return;
    }
    
    [bonjourDataReadHandle waitForDataInBackgroundAndNotify];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"close port!!");
//    [bonjourSocket invalidate];関係ない。効果がないのつらいなー。
    

    [bonjourService removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [bonjourService stop];
//    [bonjourDataReadHandle closeFile];
    
    /**
     通知を外す(接続が確立してない場合でも消す)
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
