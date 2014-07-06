//
//  SwiftHTTPObjcUtils.h
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwiftHTTPObjcUtils : NSObject

+ (CFSocketRef)CFSocketCreate;

+ (void)socket:(CFSocketRef)socket connectToPort:(NSInteger)port;

+ (BOOL)messageHeaderIsComplete:(NSData*)data;
+(NSDictionary *) dateForHttpRequest:(NSData *) data;
+ (NSString*) mimeTypeForFileAtPath: (NSString *) path;
@end
