//
//  ViewModel.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/09/28.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import HttpSession

protocol ViewModelInput: AnyObject {
    func callApi(_ indexPath: IndexPath)
}

protocol ViewModelOutput: AnyObject {
    var detail: (Data?, String, HTTPURLResponse?, Error?) -> Void { get set }
    var pushDetailViewController: () -> Void { get set }
}

protocol ViewModelType: AnyObject {
    var input: ViewModelInput { get set }
    var output: ViewModelOutput { get set }
}

final class ViewModel: ViewModelType {
    var input: ViewModelInput { get { return self } set {} }
    var output: ViewModelOutput { get { return self } set {} }

    private let provider = ApiProvider<DemoApi>()
    private var detailClosure: ((Data?, String, HTTPURLResponse?, Error?) -> Void)!
    private var pushDetailClosure: (() -> Void)!
}

extension ViewModel: ViewModelInput {
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
            provider.upload(api: .upload) { [unowned self] data, responce, error in
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

extension ViewModel: ViewModelOutput {
    var detail: (Data?, String, HTTPURLResponse?, Error?) -> Void {
        get {
            return detailClosure
        }
        set {
            detailClosure = newValue
        }
    }

    var pushDetailViewController: () -> Void {
        get {
            return pushDetailClosure
        }
        set {
            pushDetailClosure = newValue
        }
    }
}
