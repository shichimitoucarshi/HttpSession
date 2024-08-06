//
//  ViewModel.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/09/28.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import Foundation
import HttpSession

protocol ViewModelInput: AnyObject {
    func callApi(_ indexPath: IndexPath)
}

protocol ViewModelOutput: AnyObject {
    func detail(_ result: @escaping (String) -> Void)
    func transition(_ callBack: @escaping () -> Void)
    func progress(_ handler: @escaping ((Float) -> Void))
}

protocol ViewModelType: AnyObject {
    var input: ViewModelInput { get }
    var output: ViewModelOutput { get }
}

final class ViewModel: ViewModelType {
    var input: ViewModelInput { self }
    var output: ViewModelOutput { self }

    private let provider = ApiProvider<DemoApi>()
    private var detailClosure: ((String) -> Void)!
    private var uploadProgress: ((Float) -> Void)?
    private var pushDetailClosure: (() -> Void)!
}

extension ViewModel: ViewModelInput {
    func callApi(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            provider.send(api: .zen) { [unowned self] data, responce, error in
                BuildData.build(data: data,
                                parameter: [:],
                                responce: responce,
                                error: error,
                                completion: detailClosure)
            }
        case 1:
            let val = Tapul(value: ("http_post", value: "Http Request POST 😄"))
            provider.send(api: .post(param: val)) { [unowned self] data, responce, error in
                BuildData
                    .build(data: data,
                           parameter: [val.value.0: val.value.1],
                           responce: responce,
                           error: error,
                           completion: detailClosure)
            }
        case 2:

            let param = ["http_sign_in": "Http Request SignIn",
                         "userId": "keisukeYamagishi",
                         "password": "password_jisjdhsnjfbns"]
            let url = "https://sevens-api.herokuapp.com/signIn.json"

            Http.request(url: url, method: .post, params: param)
                .session(completion: { [unowned self] data, responce, error in
                    BuildData.build(data: data,
                                    parameter: param,
                                    responce: responce,
                                    error: error,
                                    completion: detailClosure)
                })
        case 3:

            Http.request(url: "https://sevens-api.herokuapp.com/signIned.json", method: .get, cookie: true)
                .session(completion: { [unowned self] data, responce, error in
                    BuildData.build(data: data,
                                    parameter: [:],
                                    responce: responce,
                                    error: error,
                                    completion: detailClosure)
                })
        case 4:

            provider.upload(api: .upload) { _, sent, totalByte in

                let percentage = Float(sent) / Float(totalByte)
                self.uploadProgress?(percentage)

            } completion: { [self] data, responce, error in
                BuildData.build(data: data,
                                parameter: [:],
                                responce: responce,
                                error: error,
                                completion: detailClosure)
            }
        case 5:
            let basicAuth: [String: String] = [Auth.user: "httpSession",
                                               Auth.password: "githubHttpsession"]
            Http.request(url: "https://sevens-api.herokuapp.com/basicauth.json",
                         method: .get,
                         basic: basicAuth).session(completion: { [unowned self] data, responce, error in

                BuildData.build(data: data,
                                parameter: [:],
                                responce: responce,
                                error: error,
                                completion: detailClosure)
            })
        case 6:
            pushDetailClosure?()
        case 7:
            let parameter = ["Swift-Http-Client-lib": "HttpSession",
                             "Lang": "Swift"]
            provider.send(api: .jsonPost(param: parameter)) { [unowned self] data, responce, error in
                BuildData.build(data: data,
                                parameter: parameter,
                                responce: responce,
                                error: error,
                                completion: detailClosure)
            }
        default:
            print("Default")
        }
    }
}

extension ViewModel: ViewModelOutput {
    func transition(_ callBack: @escaping () -> Void) {
        pushDetailClosure = callBack
    }

    func detail(_ result: @escaping (String) -> Void) {
        detailClosure = result
    }

    func progress(_ handler: @escaping ((Float) -> Void)) {
        uploadProgress = handler
    }
}
