//
//  ViewModel.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/09/28.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import HttpSession

protocol ViewModelReceive: AnyObject {
    func callApi(_ indexPath: IndexPath)
}

protocol ViewModelRoute: AnyObject {
    func detail(_ result: @escaping (Data?, String, HTTPURLResponse?, Error?) -> Void)
    func transition(_ callBack: @escaping () -> Void)
}

protocol ViewModelUI: AnyObject {
    func progress(_ handler: @escaping ((Float) -> Void))
}

protocol ViewModelType: AnyObject {
    var receive: ViewModelReceive { get }
    var ui: ViewModelUI { get }
    var route: ViewModelRoute { get }
}

final class ViewModel: ViewModelType {
    var receive: ViewModelReceive { self }
    var ui: ViewModelUI { self }
    var route: ViewModelRoute { self }

    private let provider = ApiProvider<DemoApi>()
    private var detailClosure: ((Data?, String, HTTPURLResponse?, Error?) -> Void)!
    private var uploadProgress: ((Float) -> Void)?
    private var pushDetailClosure: (() -> Void)!
}

extension ViewModel: ViewModelReceive {
    func callApi(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            provider.send(api: .zen) { [unowned self] data, responce, error in
                detailClosure(data, "", responce, error)
            }
        case 1:
            let val = Tapul(value: ("http_post", value: "Http Request POST 😄"))
            provider.send(api: .post(param: val)) { [unowned self] data, responce, error in
                detailClosure(data, "", responce, error)
            }
        case 2:

            let param = ["http_sign_in": "Http Request SignIn",
                         "userId": "keisukeYamagishi",
                         "password": "password_jisjdhsnjfbns"]
            let url = "https://sevens-api.herokuapp.com/signIn.json"

            Http.request(url: url, method: .post, params: param)
                .session(completion: { [unowned self] data, responce, error in
                    detailClosure(data, "", responce, error)
                })
        case 3:

            Http.request(url: "https://sevens-api.herokuapp.com/signIned.json", method: .get, cookie: true)
                .session(completion: { [unowned self] data, responce, error in
                    detailClosure(data, "", responce, error)
                })
        case 4:

            provider.upload(api: .upload) { _, sent, totalByte in
                let percentage = Float(sent) / Float(totalByte)
                self.uploadProgress?(percentage)
            } completion: { [self] data, responce, error in
                detailClosure(data, "", responce, error)
            }
        case 5:
            let basicAuth: [String: String] = [Auth.user: "httpSession",
                                               Auth.password: "githubHttpsession"]
            Http.request(url: "https://sevens-api.herokuapp.com/basicauth.json",
                         method: .get,
                         basic: basicAuth).session(completion: { [unowned self] data, responce, error in
                detailClosure(data, "", responce, error)
            })
        case 6:
            pushDetailClosure?()
        default:
            print("Default")
        }
    }
}

extension ViewModel: ViewModelRoute {
    func transition(_ callBack: @escaping () -> Void) {
        pushDetailClosure = callBack
    }

    func detail(_ result: @escaping (Data?, String, HTTPURLResponse?, Error?) -> Void) {
        detailClosure = result
    }
}

extension ViewModel: ViewModelUI {
    func progress(_ handler: @escaping ((Float) -> Void)) {
        uploadProgress = handler
    }
}
