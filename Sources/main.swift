//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PerfectLogger
import PerfectRequestLogger

let server = HTTPServer()
server.documentRoot = "./webroot"
server.serverPort = 8181

var routes = Routes()


//MARK: - Note
//根据用户名查询用户ID
routes.add(method: .post, uri: "/queryUserInfoByUserName") { (request, response) in
    guard let userName: String = request.param(name: "userName") else {
        LogFile.error("userName为nil")
        return
    }
    guard let json = UserOperator().query(username: userName) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//注册
routes.add(method: .post, uri: "/register") { (request, response) in
    guard let userName: String = request.param(name: "userName") else {
        LogFile.error("userName为nil")
        return
    }
    
    guard let password: String = request.param(name: "password") else {
        LogFile.error("password为nil")
        return
    }
    guard let json = UserOperator().insert(username: userName, password: password) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//登录
routes.add(method: .post, uri: "/login") { (request, response) in
    guard let userName: String = request.param(name: "userName") else {
        LogFile.error("userName为nil")
        return
    }
    guard let password: String = request.param(name: "password") else {
        LogFile.error("password为nil")
        return
    }
    guard let json = UserOperator().query(username: userName) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//获取内容列表
routes.add(method: .post, uri: "/contentList") { (request, response) in
    guard let userId: String = request.param(name: "userId") else {
        LogFile.error("userId为nil")
        return
    }
    
    guard let json = ContentOperator().queryContentList(userId: userId) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//获取详情
routes.add(method: .post, uri: "/contentDetail") { (request, response) in
    guard let contentId: String = request.param(name: "contentId") else {
        LogFile.error("contentId为nil")
        return
    }
    guard let json = ContentOperator().queryContentDetail(contentId: contentId) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//添加内容
routes.add(method: .post, uri: "/contentAdd") { (request, response) in
    guard let userId: String = request.param(name: "userId") else {
        LogFile.error("userId为nil")
        return
    }
    
    guard let title: String = request.param(name: "title") else {
        LogFile.error("title为nil")
        return
    }
    
    guard let content: String = request.param(name: "content") else {
        LogFile.error("content为nil")
        return
    }
    
    guard let json = ContentOperator().addContent(userId: userId, title: title, content: content) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//更新内容
routes.add(method: .post, uri: "/contentUpdate") { (request, response) in
    guard let contentId: String = request.param(name: "contentId") else {
        LogFile.error("contentId为nil")
        return
    }
    
    guard let title: String = request.param(name: "title") else {
        LogFile.error("title为nil")
        return
    }
    
    guard let content: String = request.param(name: "content") else {
        LogFile.error("content为nil")
        return
    }
    
    guard let json = ContentOperator().updateContent(contentId: contentId, title: title, content: content) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

//删除内容
routes.add(method: .post, uri: "/contentDelete") { (request, response) in
    guard let contentId: String = request.param(name: "contentId") else {
        LogFile.error("contentId为nil")
        return
    }
    
    guard let json = ContentOperator().deleteContent(contentId: contentId) else {
        LogFile.error("josn为nil")
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}


routes.add(method: .get, uri: "/login") { (request, response) in
    response.setBody(string: "我是/login路径返回的信息")
    response.completed()
}

let valueKey = "key"
routes.add(method: .get, uri: "/path1/{\(valueKey)}/detail") { (request, response) in
    response.appendBody(string: "该 URL 中的路由变量为:\(request.urlVariables[valueKey]!)")
    response.completed()
}

routes.add(method: .post, uri: "/login") { (request, response) in
    guard let userName = request.param(name: "userName") else { return }
    guard let password = request.param(name: "password") else { return }
    
    let responseDic: [String : Any] = ["responseBody" : ["userName" : userName, "password" : password],
    "result" : "Success",
    "resultMessage" : "请求成功"]
    
    do {
        let json = try responseDic.jsonEncodedString()
        response.setBody(string: json)
    } catch {
        response.setBody(string: "json 转换错误")
    }
    response.completed()
}

routes.add(method: .get, uri: "/create") { (request, response) in
    guard let userName = request.param(name: "userName") else {
        LogFile.error("user name is nil")
        response.completed()
        return
    }
    
    guard let password = request.param(name: "password") else {
        LogFile.error("password is nil")
        response.completed()
        return
    }
    
    guard let json = UserOperator().insert(username: userName, password: password) else {
        LogFile.error("json is nil")
        response.completed()
        return
    }
    
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

struct TestHandler: MustachePageHandler {
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        var values = MustacheEvaluationContext.MapType()
        values["title"] = "Swift 用户"
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
}

routes.add(method: .get, uri: "/") { (request, response) in
    let webRoot = request.documentRoot
    mustacheRequest(request: request, response: response, handler: TestHandler(), templatePath: webRoot + "/index.html")
}

let logPath = "./files/log"
let dir = Dir(logPath)
if !dir.exists {
    try Dir(logPath).create()
}

LogFile.location = "\(logPath)/myLog.log"
server.setRequestFilters([(RequestLogger(), .high)])
server.setRequestFilters([(RequestLogger(), .low)])

LogFile.debug("调试")
LogFile.info("消息")
LogFile.warning("警告")
LogFile.error("出错")
LogFile.critical("严重错误")
//LogFile.terminal("服务器终止")

server.addRoutes(routes)

configureServer(server)

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
//configureServer(server)

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
//func handler(data: [String:Any]) throws -> RequestHandler {
//	return {
//		request, response in
//		// Respond with a simple message.
//		response.setHeader(.contentType, value: "text/html")
//		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
//		// Ensure that response.completed() is called when your processing is done.
//		response.completed()
//	}
//}

// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

//let port1 = 8080, port2 = 8181
//
//let confData = [
//	"servers": [
//		// Configuration data for one server which:
//		//	* Serves the hello world message at <host>:<port>/
//		//	* Serves static files out of the "./webroot"
//		//		directory (which must be located in the current working directory).
//		//	* Performs content compression on outgoing data when appropriate.
//		[
//			"name":"localhost",
//			"port":port1,
//			"routes":[
//				["method":"get", "uri":"/", "handler":handler],
//				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
//				 "documentRoot":"./webroot",
//				 "allowResponseFilters":true]
//			],
//			"filters":[
//				[
//				"type":"response",
//				"priority":"high",
//				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
//				]
//			]
//		],
//		// Configuration data for another server which:
//		//	* Redirects all traffic back to the first server.
//		[
//			"name":"localhost",
//			"port":port2,
//			"routes":[
//				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
//				 "base":"http://localhost:\(port1)"]
//			]
//		]
//	]
//]

do {
	// Launch the servers based on the configuration data.
//	try HTTPServer.launch(configurationData: confData)
    try server.start()

} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

