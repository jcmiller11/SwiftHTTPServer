//
//  SwiftHTTPServer.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class SwiftHTTPServer: NSObject {

    class var server: SwiftHTTPServer {
        struct Singleton {
            static let instance = SwiftHTTPServer()
        }
        return Singleton.instance
    }
    
    
    func start(port:Int, callback: (NSError?, SwiftHTTPServer) -> Void) -> Void {
        callback(nil, self);
    }
}
