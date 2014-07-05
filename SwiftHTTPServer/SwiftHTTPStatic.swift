//
//  SwiftHTTPStatic.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa

class SwiftHTTPStatic: NSObject {

    
    func servePublicFiles(path:String, server:SwiftHTTPServer)->Void{
        var arr = NSFileManager.defaultManager().directoryContentsAtPath(path);
        for i : AnyObject in arr {
            var file = i as String
            server.get("/" + file, callback: {req, res in
                var body = NSString.stringWithContentsOfFile(path + file, encoding: NSUTF8StringEncoding, error: nil)
                res.send(body)
                return false
            })
        }
    }
}
