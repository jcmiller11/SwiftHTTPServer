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
}
