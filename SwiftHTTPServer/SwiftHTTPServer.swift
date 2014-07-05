//
//  SwiftHTTPServer.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class SwiftHTTPReq: NSObject {
    let path:String
    let method:String
    init(path:String){
        self.path = path
        method = "GET"
    }
    init(path:String, method:String){
        self.path = path
        self.method = method.uppercaseString
    }
    func route()->String {
        return method + " " + path
    }
}

class SwiftHTTPRes: NSObject {
    var body = ""
    func send(body:String) {
        self.body += body
    }
    func flush(){
        NSLog(body)
    }
}

class SwiftHTTPServer {
    var routes = Dictionary<String, Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >>()
    var socket = SwiftHTTPObjcUtils.CFSocketCreate().takeRetainedValue()
    
    func getRoute(route:String) ->String {
        return "GET " + route
    }
    
    func get(route:String, callback: Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >) -> SwiftHTTPServer {
        let existingRoutes:Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >? = routes[getRoute(route)]
        if var existingRoutes = existingRoutes{
            existingRoutes += callback
            routes[getRoute(route)] = existingRoutes
        } else {
            routes[getRoute(route)] = callback
        }
        return self
    }
    
    func get(route:String, callback:(SwiftHTTPReq, SwiftHTTPRes)-> Bool) -> SwiftHTTPServer {
        let existingRoutes:Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >? = routes[getRoute(route)]
        if var existingRoutes = existingRoutes{
            existingRoutes += callback
            routes[getRoute(route)] = existingRoutes
        } else {
            routes[getRoute(route)] = [callback]
        }
        return self
    }
    
    func start(port:Int, callback: (NSError?, SwiftHTTPServer) -> Void) -> SwiftHTTPServer {
        SwiftHTTPObjcUtils.socket(socket, connectToPort: port)
        
        callback(nil, self)
        return self
    }

    func handleRequest(request:SwiftHTTPReq){
        let callbackArray:Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >? = routes[request.route()]
        if let callbackArray = callbackArray {
            var res = SwiftHTTPRes()
            for callback in callbackArray{
                if callback(request, res) == false{
                    break
                }
            }
            res.flush()
        }
    }
}
