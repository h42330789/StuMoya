//
//  WebServerManager.swift
//  StuMoya
//
//  Created by abc on 12/17/22.
//

import Foundation
import Telegraph

class WebServerManager: NSObject {

    static let shared = WebServerManager()
    var serverHTTPs: Server?
    var server: Server?
    
    func startHttps() {
//        serverHTTPs = Server(identity: identity, caCertificates: [caCertificate])
//        try! serverHTTPs.start(port: 9000)
    }
    
    func startHttp() {
        server = Server()
        server?.httpConfig.requestHandlers.insert(MyDecryptHandler(), at: 0)
        server?.route(.POST, "api/user/login",handleLogin)
        server?.route(.GET, "hello/:name/:age", handleGreeting)
        server?.route(.GET, "secret/*") { .forbidden }
        server?.route(.GET, "status") { (.ok, "Server is running") }

        server?.serveBundle(.main, "/")

        do {
            //        try! serverHTTP?.start(port: 9000)
            
            try server?.start(port: 9000, interface: "localhost")
        } catch {
            print(error)
        }
        
    }
    
    
}
// MARK: - Routes
extension WebServerManager {
    
    func handleLogin(request: HTTPRequest) -> HTTPResponse {
        // params是定义在url上/:xx这种方式
        // ?xx=yy&&aa=bb这种通过request.uri.queryItems获取
        // post发送的data，从body里获取
        let requestDict = try? JSONDecoder().decode([String: String].self, from: request.body)
        let username = requestDict?["username"] ?? "nick"
        let password = requestDict?["password"]
        let info: [String:Any] = [
            "uid":1,
            "token":"werwer",
            "name":username,
            "sex":"female",
            "age":10
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: info, options: JSONSerialization.WritingOptions.init(rawValue: 0)) else {
            return HTTPResponse(.internalServerError)
        }
        let jsonStr = String(data: data, encoding: .utf8) ?? ""
        return HTTPResponse(content: jsonStr)
    }
    
    func handleGreeting(request: HTTPRequest) -> HTTPResponse {
        // params是定义在url上/:xx这种方式
        // ?xx=yy&&aa=bb这种通过request.uri.queryItems获取
      let name = request.params["name"] ?? "stranger"
      return HTTPResponse(content: "Hello \(name.capitalized)")
    }
}

//static func convertDict2Data(_ dict: [String:Any]) throws -> Data? {
//    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0)) else {
//        return nil
//    }
//    let jsonStr = String(data: data, encoding: .utf8) ?? ""
//}

// MARK: - 加解密
public class MyDecryptHandler: HTTPRequestHandler {
    public func respond(to request: HTTPRequest, nextHandler: (HTTPRequest) throws -> HTTPResponse?) throws -> HTTPResponse? {
        // 可以对内容进行统一处理
//        request.uri.queryItems?.forEach { item in
//              request.params[item.name] = item.value
//        }
        if let requestDict = try? JSONDecoder().decode([String: String].self, from: request.body),
            requestDict.count == 1,
           let val = requestDict["v"] {
            // 加密的内容，统一进行解密
            print(val)
        }
        let response = try nextHandler(request)
        if response?.status == .ok, let bodyData = response?.body {
            
            do {
                // 有内容的地方，需要对数据进行统一格式的封装，
                let oldBodyDict = try JSONSerialization.jsonObject(with: bodyData, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject] ?? [:]

                let newBodyDict: [String : Any] = [
                    "refreshTime": Int(Date().timeIntervalSince1970),
                    "isSuccess": true,
                    "errorCode": 10000,
                    "message": "",
                    "location": "",
                    "data": oldBodyDict
                ]
                // 对数据进行统一加密
                let newBodyData = try? JSONSerialization.data(withJSONObject: newBodyDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                response?.body = newBodyData!
            } catch let error as NSError {
                 print(error)
            }
            
            
        }
        response?.headers.accessControlAllowOrigin = "*"
        return response
    }
}
