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
    //NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = [[self class] getDataOfQueryString:[url query]];
    if (params) {
        [dataDictionary setObject:params forKey:@"params"];
    }
    
    NSDictionary* json = nil;
    if (data != nil) {
        json = [NSJSONSerialization JSONObjectWithData:bodyData options:0 error:nil];
    }
    
    [dataDictionary setObject:method forKey:@"method"];
    [dataDictionary setObject:path forKey:@"path"];
    [dataDictionary setObject:body forKey:@"body"];
    if (json) {
            [dataDictionary setObject:json forKey:@"json"];
    } else {
        NSDictionary *post = [[self class] getDataOfQueryString:body];
        if (post) {
            [dataDictionary setObject:post forKey:@"post"];
        }
    }
    return [dataDictionary copy];
}

+(NSDictionary *)getDataOfQueryString:(NSString *)url{
    
    NSArray *strURLParse = [url componentsSeparatedByString:@"?"];
    NSArray *arrQueryString = nil;
    if ([strURLParse count] == 2) {
        arrQueryString = [[strURLParse objectAtIndex:1] componentsSeparatedByString:@"&"];
    } else if([strURLParse count] == 1){
           arrQueryString = [[strURLParse objectAtIndex:0] componentsSeparatedByString:@"&"];
    } else {
        return nil;
    }
    NSMutableDictionary *queryData = [[NSMutableDictionary alloc] init];
    for (int i=0; i < [arrQueryString count]; i++) {
        //NSMutableDictionary *dicQueryStringElement = [[NSMutableDictionary alloc]init];
        NSArray *arrElement = [[arrQueryString objectAtIndex:i] componentsSeparatedByString:@"="];
       if ([arrElement count] == 2) {
           [queryData setObject:[arrElement objectAtIndex:1] forKey:[arrElement objectAtIndex:0]];
       }
    }
    return [queryData copy];
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





