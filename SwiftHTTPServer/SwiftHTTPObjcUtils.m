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

+ (BOOL)messageHeaderIsComplete:(NSData*)data{
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true);
    CFHTTPMessageAppendBytes(message, data.bytes, data.length);
    return CFHTTPMessageIsHeaderComplete(message);
}

+(NSDictionary *) dateForHttpRequest:(NSData *) data{
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true);
    CFHTTPMessageAppendBytes(message, data.bytes, data.length);
    NSString *method = (__bridge NSString *) CFHTTPMessageCopyRequestMethod(message);
    NSURL *url = (__bridge NSURL *)CFHTTPMessageCopyRequestURL(message);
    NSData *bodyData = (__bridge NSData *)CFHTTPMessageCopyBody(message);
    NSString *body = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    NSString *path = [url path];
    [dataDictionary setObject:method forKey:@"method"];
    [dataDictionary setObject:path forKey:@"path"];
    [dataDictionary setObject:body forKey:@"body"];
    return [dataDictionary copy];
}


+ (NSString*) mimeTypeForFileAtPath: (NSString *) path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)CFBridgingRetain([path pathExtension]), NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)mimeType ;
}

@end





