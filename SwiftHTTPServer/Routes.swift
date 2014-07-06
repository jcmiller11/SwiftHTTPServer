//
//  Routes.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 06.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class Routes: NSObject {

    func authenticate()->((SwiftHTTPReq, SwiftHTTPRes) -> Bool){
        return {req, res in
            return true
        }
    }
    
    func redirectToIndex()->((SwiftHTTPReq, SwiftHTTPRes) -> Bool){
        return {req, res in
            res.redirect("/index.html")
            return true
        }
    }
    
    func hello()->((SwiftHTTPReq, SwiftHTTPRes) -> Bool){
        return {req, res in
            res.send("<h1>Hello!</h1>")
            return true
        }
    }
    
    func world()->((SwiftHTTPReq, SwiftHTTPRes) -> Bool){
        return {req, res in
            res.send("<h1>world!</h1>")
            return true
        }
    }
    
    func test()->((SwiftHTTPReq, SwiftHTTPRes) -> Bool){
        return {
            req, res in
            res.send("<pre>")
            if var body = req.body {
                res.send("body: " + body + "\n")
            }
            if let json = req.json {
                let jsonString:String = NSString(format: "%@", json)
                res.send("json: " + jsonString + "\n")
                NSLog("%@", json)
            }
            if let post = req.post{
                let postString:String = NSString(format: "%@", post)
                res.send("post: " + postString + "\n")
                NSLog("%@", post)
            }
    
            if let params = req.params{
                let paramsString:String = NSString(format: "%@", params)
                res.send("GET params: " + paramsString + "\n")
                NSLog("%@", params)
            }
            return true
        }
    }
}
