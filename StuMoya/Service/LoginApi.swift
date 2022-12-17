//
//  LoginApi.swift
//  StuMoya
//
//  Created by abc on 12/16/22.
//

import Foundation
import Moya

enum LoginApi {
    struct Login: ApiTargetType {
        typealias ResponseDataType = BaseResponseData<UserInfo>
        var path: String { return "api/user/login" }
        
        var method: Moya.Method { return .post}
        
        var task: Moya.Task { return .requestParameters(parameters: parameters, encoding: JSONEncoding.default) }
        
        var extraTag: String
        
        var baseURL: URL {return URL(string: "http://localhost:9000")!}
        
        var parameters: [String:Any] = [:]
        init(username: String, password: String, extraTag: String = "") {
            parameters["username"] = username
            parameters["password"] = password
            self.extraTag = extraTag
        }
    }

}


struct UserInfo: Codable {
    let uid: Int
    let token: String
    let name: String
    let sex: String
    let age: Int
}
