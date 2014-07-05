//
//  AppDelegate.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

let mkPublic:String = "/Users/marekkotewicz/test/SwiftHTTPServer/Public/"

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow
    var server = SwiftHTTPServer()
    var public = SwiftHTTPStatic()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {

        //public.servePublicFiles(mkPublic, server:server);

        server.get("/", callback: {req, res in
            res.redirect("/index.html")
            return true
        })
        
        server.get("/hello", callback: [{req, res in
                res.send("<h1>działa</h1>")
                return true
            }, { req, res in
                res.send("test\n");
                
                return true
            }, { req, res in
                res.send("test 2 \n")
                return true
            }]
            )
        server.get("/hello", callback:
            {
                req, res in
                res.send("anather hello")
                return false
            }
        )
        
        server.start(3000, callback: {err, server in
//            NSLog("%@", server)
        })
        //let req: SwiftHTTPReq = SwiftHTTPReq(path: "/index.html")
        //server.handleRequest(req)
        
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    
}

