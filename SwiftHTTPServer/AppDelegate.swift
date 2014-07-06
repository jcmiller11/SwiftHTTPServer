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
    var routes = Routes()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {

        server.get("/", callback: routes.redirectToIndex())
        server.get("/hello", callback: routes.hello())
        server.get("/world", callback: [routes.authenticate(), routes.world()])

        server.get("/inline", callback: {req, res in
            res.send("<h1>Inline!</h1>")
            return true
            })
        
        server.start(3000, callback: {err, server in

        })
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    
}

