//
//  SwiftHTTPObjcUtils.m
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "SwiftHTTPObjcUtils.h"

@implementation SwiftHTTPObjcUtils

+ (CFSocketRef)CFSocketCreate{
    return CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM,
                          IPPROTO_TCP, 0, NULL, NULL);
}

+ (void)socket:(CFSocketRef)socket connectToPort:(NSInteger)port{
    if (!socket)
    {
//        [self errorWithName:@"Unable to create socket."];
        return;
    }
    
    int reuse = true;
    int fileDescriptor = CFSocketGetNative(socket);
    if (setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR,
                   (void *)&reuse, sizeof(int)) != 0)
    {
//        [self errorWithName:@"Unable to set socket options."];
        return;
    }
    
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    address.sin_port = htons(port);
    CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
//    [(id)addressData autorelease];
    
    if (CFSocketSetAddress(socket, addressData) != kCFSocketSuccess) {
//        [self errorWithName:@"Unable to bind socket to address."];

    }
    CFRelease(addressData);
}

@end
