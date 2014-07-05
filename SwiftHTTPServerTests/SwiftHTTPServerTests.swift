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
        server.flush = { (res:SwiftHTTPRes) in XCTAssertEqual(res.body, "test" , "body should be test" ) }
        server.handleRequest(SwiftHTTPReq(path: "/"))
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
        server.flush = { (res:SwiftHTTPRes) in XCTAssertEqual(res.body, "test1\ntest2" , "body should be test" ) }
        server.handleRequest(SwiftHTTPReq(path: "/"))
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
        server.flush = { (res:SwiftHTTPRes) in XCTAssertEqual(res.body, "test1\ntest2" , "body should be test" ) }
        server.handleRequest(SwiftHTTPReq(path: "/"))
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
        server.flush = { (res:SwiftHTTPRes) in XCTAssertEqual(res.body, "test1\n" , "body should be test" ) }
        server.handleRequest(SwiftHTTPReq(path: "/"))
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
        server.flush = { (res:SwiftHTTPRes) in XCTAssertEqual(res.body, "test1\n" , "body should be test" ) }
        server.handleRequest(SwiftHTTPReq(path: "/"))
    }
    
    func testPOST(){
        server.post("/", callback:{
            req, res in
            res.send("post")
            return true
        })
        server.flush = { (res:SwiftHTTPRes) in XCTAssertEqual(res.body, "post" , "body should be test" ) }
        server.handleRequest(SwiftHTTPReq(path: "/", method: "post"))
    }
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
