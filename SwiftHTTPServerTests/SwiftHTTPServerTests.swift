//
//  SwiftHTTPServerTests.swift
//  SwiftHTTPServerTests
//
//  Created by Marek Kotewicz on 05.07.2014.
//  Copyright (c) 2014 Marek Kotewicz. All rights reserved.
//

import XCTest
import SwiftHTTPServer

class SwiftHTTPServerTests: XCTestCase {
    var server:SwiftHTTPServer = SwiftHTTPServer()
    override func setUp() {
        super.setUp()
        server = SwiftHTTPServer()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOneGet() {
        server.get("/", callback: {req, res in
            res.send("test")
            return true })
        
        let res:SwiftHTTPRes = server.handleRequest(SwiftHTTPReq(path: "/"))
        XCTAssertEqual(res.body, "test" , "body should be test" )
    }
    
    func testGetTwoCallbacks(){
        server.get("/", callback: [
            {
                req, res in
                res.send("test1\n")
                return true
            }, {
                req, res in
                res.send("test2")
                return true
            }
        ])
        let res:SwiftHTTPRes = server.handleRequest(SwiftHTTPReq(path: "/"))
        XCTAssertEqual(res.body, "test1\ntest2" , "body should be test" )
    }
    
    func testGetTwoChainFunctions(){
        server.get("/", callback:
            {
                req, res in
                res.send("test1\n")
                return true
            }).get("/", callback: {
                req, res in
                res.send("test2")
                return true
                })
        let res:SwiftHTTPRes = server.handleRequest(SwiftHTTPReq(path: "/"))
        XCTAssertEqual(res.body, "test1\ntest2" , "body should be test" )
    }
    
    func testGetTwoCallbacksWithFalseAfterFirst(){
        server.get("/", callback:
            {
                req, res in
                res.send("test1\n")
                return false
            }).get("/", callback: {
                req, res in
                res.send("test2")
                return true
                })
        let res:SwiftHTTPRes = server.handleRequest(SwiftHTTPReq(path: "/"))
        XCTAssertEqual(res.body, "test1\n" , "body should be test" )
    }
    
    func testGetTwoChainFunctionsWithFalseAfterFirst(){
        server.get("/", callback:
            {
                req, res in
                res.send("test1\n")
                return false
            }).get("/", callback: {
                req, res in
                res.send("test2")
                return true
                })
        let res:SwiftHTTPRes = server.handleRequest(SwiftHTTPReq(path: "/"))
        XCTAssertEqual(res.body, "test1\n" , "body should be test" )
    }
    
    func testPOST(){
        server.post("/", callback:{
            req, res in
            res.send("post")
            return true
        })
        let res:SwiftHTTPRes = server.handleRequest(SwiftHTTPReq(path: "/", method: "post"))
        XCTAssertEqual(res.body, "post" , "body should be test" )
        
    }
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            var a: Double = 1;
            for i in 1 ... 1000000{
                var j:Double = Double(i)
                a = (a+j)/a
            }
            // Put the code you want to measure the time of here.
        }
    }
    */
}
