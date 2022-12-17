//
//  APIService.swift
//  StuMoya
//
//  Created by abc on 12/16/22.
//

import Moya
import Foundation
import RxSwift

class APIService: NSObject {
    
    static let shared = APIService()
    
    func customSession<T: ApiTargetType>(request: T) -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = request.timeout
        configuration.timeoutIntervalForResource = request.timeout
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
}


enum MyStratery:Int {
    case onlyCache = 0
    case onlyRequest = 1
    case cacheOrRequest = 2
    case cacheAndRequest = 3
}

/// 預先指定response的data type
protocol DecodableResponseTargetType: TargetType {
    associatedtype ResponseDataType: Codable
}

/// API的共用protocol，設定API共用參數，且api的response皆要可以被decode
protocol ApiTargetType: DecodableResponseTargetType {
    var timeout: TimeInterval { get }
    var strategy: MyStratery { get }
}


/// 共用參數
extension ApiTargetType {
    var baseURL: URL { return URL(string: "http://127.0.0.1")! }
    var path: String { fatalError("path for ApiTargetType must be override") }
    var method: Moya.Method { return .get }
    var headers: [String : String]? { return nil }
    var task: Task { return .requestPlain }
    var sampleData: Data { return Data() }
    
    var timeout: TimeInterval { return 30 }
    var strategy: MyStratery { return .onlyRequest }
    var extraTag: String { return "" }
}

struct BaseResponseData<T: Codable>: Codable {
    var refreshTime: Int?
    var isSuccess: Bool
    var errorCode: Int
    var message: String?
    var location: String
    
    /// 是否需要登出，登出错误码 token过期、别处登录
    var isNeedLogout: Bool {
        errorCode == -20002 || errorCode == -20003
    }
    
    let data: T?
    
}

// MARK: filter
extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {
    
    func abc(req: any ApiTargetType) -> Single<Element> {
        return flatMap { .just(try $0.abc(req: req)) }
    }
    
    func xyz() -> Single<Element> {
        return flatMap { .just(try $0.xyz()) }
    }
}

extension Moya.Response {
    /// 替换agent token及token
    func abc(req: any ApiTargetType)throws -> Moya.Response  {
        // xxx 处理逻辑
        return self
    }
    func xyz()throws -> Moya.Response  {
        // xxx 处理逻辑
        return self
    }
}
