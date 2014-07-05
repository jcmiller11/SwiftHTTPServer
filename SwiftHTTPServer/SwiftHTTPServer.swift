//
//  SwiftHTTPServer.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class SwiftHTTPReq: NSObject {

}

class SwiftHTTPRes: NSObject {
    
}

struct SwiftHTTPServer {
    var routes = Dictionary<String, Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >>()
    var test = Dictionary<String, String>()
    
    mutating func get(route:String, callback: Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >) -> SwiftHTTPServer {
        routes[route] = callback
        return self
    }
    
    mutating func get(route:String, callback:(SwiftHTTPReq, SwiftHTTPRes)-> Bool) -> SwiftHTTPServer {
        routes[route] = [callback]
        return self
    }
    
    func start(port:Int, callback: (NSError?, SwiftHTTPServer) -> Void) -> SwiftHTTPServer {
        callback(nil, self)
        return self
    }
}
