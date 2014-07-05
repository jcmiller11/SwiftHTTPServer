//
//  SwiftHTTPServer.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa
import ObjectiveC

var counterKey = "counter"

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
    func send(body:String) {
        NSLog(body)
    }
}

class SwiftHTTPServer{
    var routes = Dictionary<String, Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >>()
    var socket = SwiftHTTPObjcUtils.CFSocketCreate().takeRetainedValue()
    var listeningHandle:NSFileHandle?
    var incomingRequests:NSMutableDictionary = NSMutableDictionary.dictionary()
    var counter:Int = 0
    
    init () {
    }
    
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
        routes[getRoute(route)] = [callback]
        return self
    }
    
    func start(port:Int, callback: (NSError?, SwiftHTTPServer) -> Void) -> SwiftHTTPServer {
        SwiftHTTPObjcUtils.socket(socket, connectToPort: port)
        listeningHandle = NSFileHandle(fileDescriptor: CFSocketGetNative(socket), closeOnDealloc: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveIncomingConnectionNotification:"), name: NSFileHandleConnectionAcceptedNotification, object: nil)
        listeningHandle!.acceptConnectionInBackgroundAndNotify()
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
        }
    }
//    @objc func receiveIncomingConnectionNotification(){
//        
//    }
    
    @objc func receiveIncomingConnectionNotification(notification:NSNotification) -> Void {
        var userInfo = notification.userInfo
        var incomingFileHandle:NSFileHandle? = userInfo[NSFileHandleNotificationFileHandleItem] as? NSFileHandle
        if incomingFileHandle != nil{
            incomingRequests[counter] = NSMutableData()
            objc_setAssociatedObject(incomingFileHandle, &counterKey, counter, UInt(OBJC_ASSOCIATION_RETAIN))
            counter++
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveIncomingDataNotification:", name:
                NSFileHandleDataAvailableNotification
                , object: incomingFileHandle)
            incomingFileHandle!.waitForDataInBackgroundAndNotify()
        }
        listeningHandle!.acceptConnectionInBackgroundAndNotify()
    }
    
    @objc func receiveIncomingDataNotification(notifiction:NSNotification) -> Void {
        var incomingFileHandle:NSFileHandle = notifiction.object as NSFileHandle
        var fileId = objc_getAssociatedObject(incomingFileHandle, &counterKey) as Int
        var data = incomingFileHandle.availableData
        
        if (data.length == 0){
            stopReceivingForFileHandle(incomingFileHandle, close: false)
            return
        }
        var messageData:NSMutableData? = incomingRequests[fileId] as? NSMutableData
        if !messageData {
            stopReceivingForFileHandle(incomingFileHandle, close: true)
            return
        }
        messageData!.appendData(data)
        var logMessage = NSString(data: messageData, encoding: NSUTF8StringEncoding)
        NSLog("%@", logMessage)
        if (SwiftHTTPObjcUtils.messageHeaderIsComplete(messageData)){

        }
        incomingFileHandle.waitForDataInBackgroundAndNotify()
        
    }
    
    func stopReceivingForFileHandle(handle:NSFileHandle, close:Bool)-> Void {
        if close {
            handle.closeFile()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: handle)
    }
    
}











