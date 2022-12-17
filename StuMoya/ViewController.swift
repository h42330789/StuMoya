//
//  ViewController.swift
//  StuMoya
//
//  Created by abc on 12/16/22.
//

import UIKit
import Moya
import RxSwift



class ViewController: UIViewController {
    
    var dict: [Endpoint: String] = [:]
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func requstClick(_ sender: UIButton) {
        guard let strategy = MyStratery(rawValue: sender.tag) else { return }
        switch strategy {
        case .onlyCache:
            break
        case .onlyRequest:
            break
        case .cacheOrRequest:
            break
        case .cacheAndRequest:
            break
        }
    }
    
    
    @IBAction func trackInflight(_ sender: Any) {
//        simpleRequest()
        rxRequest()
    }
    
    func rxRequest() {
        let request = LoginApi.Login(username: "1", password: "2", extraTag: "a")
        let session = APIService.shared.customSession(request: request)
        let provider = MoyaProvider<MultiTarget>(session: session, plugins: [],  trackInflights: true)

        
        let target = MultiTarget.init(request)
        // flatMap { .just(try $0.xxx()) }
        // xxx-->xxx传递的数据
        provider.rx.request(target)
            .abc(req: request)
            .xyz()
            .filterSuccessfulStatusCodes()
            .map(type(of:request).ResponseDataType.self)
            .subscribe(onSuccess: { res in
                print(res)
            }).disposed(by: disposeBag)
    }
    
    func simpleRequest() {
        let request = LoginApi.Login(username: "1", password: "2", extraTag: "a")
        let session = APIService.shared.customSession(request: request)
        let provider = MoyaProvider<MultiTarget>(session: session, plugins: [],  trackInflights: true)

        
        let target = MultiTarget.init(request)
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    // response == response1 == response2 -->data
                    let response1 = try response.abc(req: request)
                    let response2 = try response1.filterSuccessfulStatusCodes()
//                    let dataStr = String(data: response.data, encoding: .utf8)
                    let obj = try? JSONDecoder().decode(LoginApi.Login.ResponseDataType.self, from: response2.data)
                    print(obj ?? "")
                    
                } catch {
                    print(error)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func testEqual() {

    }
    
}


