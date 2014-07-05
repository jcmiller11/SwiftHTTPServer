//
//  AppDelegate.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow
    var server = SwiftHTTPServer()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {

        
        server.get("/hello", callback: [{req, res in
                res.send("działa")
                res.send("a")
                return true
            }, { req, res in
                res.send("test");
                
                return true
            }, { req, res in
                NSLog("test 2");
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
        let req: SwiftHTTPReq = SwiftHTTPReq(path: "/hello")
        server.handleRequest(req)
        
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    
}

