//
//  SwiftHTTPServer.swift
//  SwiftHTTPServer
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import Cocoa
import ObjectiveC

var fullData = "fullData"

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
    
    init(data:NSDictionary){
        if let method = data["method"] as? String{
            self.method = method
        } else {
            self.method = "GET"
        }
        if let path = data["path"] as? String{
            self.path = path
        } else {
            path = ""
        }
        if let body = data["body"] as? String {
            self.body = body
        }
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

class SwiftHTTPServer{
    var routes = Dictionary<String, Array<(SwiftHTTPReq, SwiftHTTPRes)-> Bool >>()
    var socket = SwiftHTTPObjcUtils.CFSocketCreate().takeRetainedValue()
    var listeningHandle:NSFileHandle?
    var flush = {(res: SwiftHTTPRes)in NSLog(res.body) }
    
    init () {
    }
    
    func getRoute(route:String) ->String {
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

        listeningHandle = NSFileHandle(fileDescriptor: CFSocketGetNative(socket), closeOnDealloc: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveIncomingConnectionNotification:"), name: NSFileHandleConnectionAcceptedNotification, object: nil)
        listeningHandle!.acceptConnectionInBackgroundAndNotify()
        callback(nil, self)
        return self
    }

    func handleRequest(request: SwiftHTTPReq) -> SwiftHTTPRes
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
        //flush(res)
        return res
    }
    
    func notFound(req : SwiftHTTPReq,  res: SwiftHTTPRes) -> Bool{
        res.code = 404
        res.send("Not found " + req.path)
        return false
    }
    
    @objc func receiveIncomingConnectionNotification(notification:NSNotification) -> Void {
        var userInfo = notification.userInfo
        var incomingFileHandle:NSFileHandle? = userInfo[NSFileHandleNotificationFileHandleItem] as? NSFileHandle
        if incomingFileHandle != nil{
            objc_setAssociatedObject(incomingFileHandle, &fullData, NSMutableData(), UInt(OBJC_ASSOCIATION_RETAIN))
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveIncomingDataNotification:", name:
                NSFileHandleDataAvailableNotification
                , object: incomingFileHandle)
            incomingFileHandle!.waitForDataInBackgroundAndNotify()
        }
        listeningHandle!.acceptConnectionInBackgroundAndNotify()
    }
    
    @objc func receiveIncomingDataNotification(notifiction:NSNotification) -> Void {
        var incomingFileHandle:NSFileHandle = notifiction.object as NSFileHandle
        var messageData = objc_getAssociatedObject(incomingFileHandle, &fullData) as? NSMutableData
        var data = incomingFileHandle.availableData
        
        if (data.length == 0){
            stopReceivingForFileHandle(incomingFileHandle, close: false)
            return
        }
        if !messageData {
            stopReceivingForFileHandle(incomingFileHandle, close: true)
            return
        }
        messageData!.appendData(data)
        var logMessage = NSString(data: messageData, encoding: NSUTF8StringEncoding)
        
        if (SwiftHTTPObjcUtils.messageHeaderIsComplete(messageData)){
            let requestData = SwiftHTTPObjcUtils.dateForHttpRequest(messageData)
            var request = SwiftHTTPReq(data: requestData)
            var response = handleRequest(request)
            NSLog(response.body)
            var responseMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, response.code, nil, kCFHTTPVersion1_0).takeRetainedValue()
            CFHTTPMessageSetHeaderFieldValue(responseMessage, "Content-Type" as CFString, "text/html" as CFString)
            CFHTTPMessageSetHeaderFieldValue(responseMessage, "Connection" as CFString, "close" as CFString);
            CFHTTPMessageSetBody( responseMessage, (response.body as NSString).dataUsingEncoding(NSUTF8StringEncoding));
            var headerData = CFHTTPMessageCopySerializedMessage(responseMessage).takeRetainedValue() as CFData
            incomingFileHandle.writeData(headerData)
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











