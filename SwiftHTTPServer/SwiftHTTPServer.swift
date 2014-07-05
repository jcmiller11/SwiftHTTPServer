//
//  SwiftHTTPServer.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class SwiftHTTPReq
{
    let path : String
    let method : String
    let body : String?
    
    init(path: String)
    {
        self.path = path
        method = "GET"
    }

    init(path: String, method: String)
    {
        self.path = path
        self.method = method.uppercaseString
    }
    
    func route()->String
    {
        return method + " " + path
    }
}

class SwiftHTTPRes
{
    var body = ""
    var code = 200
    func send(body: String)
    {
        self.body += body
    }
    
    func flush()
    {
        NSLog(body)
    }
}

class SwiftHTTPServer
{
    var routes = Dictionary<String, Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool> >()
    var socket = SwiftHTTPObjcUtils.CFSocketCreate().takeRetainedValue()
    var flush = {(res: SwiftHTTPRes)in NSLog(res.body) }

    func getRoute(route: String)->String
    {
        return "GET " + route
    }
    
    func postRoute(route: String)->String
    {
        return "POST " + route
    }
    
    func get(route: String, callback: Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>)->SwiftHTTPServer
    {
        let existingRoutes : Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>? = routes[getRoute(route)]
        if var existingRoutes = existingRoutes
        {
            existingRoutes += callback
            routes[getRoute(route)] = existingRoutes
        }
        else
        {
            routes[getRoute(route)] = callback
        }
        return self
    }

    func get(route: String, callback: (SwiftHTTPReq, SwiftHTTPRes)->Bool)->SwiftHTTPServer
    {
        let existingRoutes : Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>? = routes[getRoute(route)]
        if var existingRoutes = existingRoutes
        {
            existingRoutes += callback
            routes[getRoute(route)] = existingRoutes
        }
        else
        {
            routes[getRoute(route)] = [callback]
        }
        return self
    }

    func post(route: String, callback: Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>)->SwiftHTTPServer
    {
        let existingRoutes : Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>? = routes[postRoute(route)]
        if var existingRoutes = existingRoutes
        {
            existingRoutes += callback
            routes[postRoute(route)] = existingRoutes
        }
        else
        {
            routes[postRoute(route)] = callback
        }
        return self
    }

    func post(route: String, callback: (SwiftHTTPReq, SwiftHTTPRes)->Bool)->SwiftHTTPServer
    {
        let existingRoutes : Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>? = routes[postRoute(route)]
        if var existingRoutes = existingRoutes
        {
            existingRoutes += callback
            routes[postRoute(route)] = existingRoutes
        }
        else
        {
            routes[postRoute(route)] = [callback]
        }
        return self
    }
    
    func start(port:Int, callback: (NSError?, SwiftHTTPServer) -> Void) -> SwiftHTTPServer
    {
        SwiftHTTPObjcUtils.socket(socket, connectToPort: port)
        callback(nil, self)
        return self
    }

    func handleRequest(request: SwiftHTTPReq)
    {
        let callbackArray : Array<(SwiftHTTPReq, SwiftHTTPRes)->Bool>? = routes[request.route()]
        var res = SwiftHTTPRes()
        if let callbackArray = callbackArray
        {
            
            for callback in callbackArray
            {
                if callback(request, res) == false
                {
                        break
                }
            }
            
        } else {
            notFound(request, res: res)
        }
        flush(res)
    }
    
    func notFound(req : SwiftHTTPReq,  res: SwiftHTTPRes) -> Bool{
        res.code = 404
        res.send("Not found " + req.path)
        return false
    }
    
}
