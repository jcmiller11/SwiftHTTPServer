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

class SwiftHTTPServer: NSObject {
    var routes = Dictionary<String, Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >>()
    var test = Dictionary<String, String>()
    
    class var server: SwiftHTTPServer {
        struct Singleton {
            static let instance = SwiftHTTPServer()
        }
        return Singleton.instance
    }
    
    func get(route:String, callback: Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >) -> SwiftHTTPServer {
        var existingRoutes:Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >? = routes[route]
        if let existingRoutes = existingRoutes{
            routes[route] = existingRoutes + callback
        }
        return self
    }
    
    func get(route:String, callback:(SwiftHTTPReq, SwiftHTTPRes)-> Bool) -> SwiftHTTPServer {
        var existingRoutes:Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >? = routes[route]
        if var existingRoutes = existingRoutes{
            existingRoutes.append(callback)
        }
        
        return self
    }
    
    func start(port:Int, callback: (NSError?, SwiftHTTPServer) -> Void) -> SwiftHTTPServer {
        callback(nil, self)
        return self
    }
}
