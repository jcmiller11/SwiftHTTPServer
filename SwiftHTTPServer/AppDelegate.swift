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
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        var server = SwiftHTTPServer()
        
        server.get("/hello", callback: {req, res in
            NSLog("działa")
            return true;
            }
        )
        
        server.start(3000, callback: {err, server in
//            NSLog("%@", server)
            })
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    
}

