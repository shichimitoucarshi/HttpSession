//
//  ViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import HttpSession
import UIKit

enum DemoApi {
    case zen
    case post(param: Tapul)
    case download
    case upload
}

extension DemoApi: ApiProtocol {
    var domain: String {
        switch self {
        case .zen, .post, .upload:
            return "https://httpsession.work"
        case .download:
            return "https://shichimitoucarashi.com"
        }
    }

    var endPoint: String {
        switch self {
        case .zen:
            return "getApi.json"
        case .post:
            return "postApi.json"
        case .download:
            return "public/Apple_trim.mp4"
        case .upload:
            return "imageUp.json"
        }
    }

    var method: Http.Method {
        switch self {
        case .zen:
            return .get
        case .post, .upload:
            return .post
        case .download:
            return .get
        }
    }

    var header: [String: String]? {
        return nil
    }

    var params: [String: String]? {
        switch self {
        case .zen:
            return nil
        case let .post(val):
            return [val.value.0: val.value.1]
        case .upload:
            return nil
        case .download:
            return nil
        }
    }

    var multipart: [String: Multipart.data]? {
        switch self {
        case .upload:
            var dto: Multipart.data = Multipart.data()
            let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
            let img: Data
            do {
                img = try Data(contentsOf: URL(fileURLWithPath: image!))
            } catch {
                img = Data()
            }

            dto.fileName = "Hello.txt"
            dto.mimeType = "text/plain"
            dto.data = img
            return ["img": dto]
        case .zen, .post, .download:
            return nil
        }
    }

    var isCookie: Bool {
        return false
    }

    var basicAuth: [String: String]? {
        return nil
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var apis = ["HTTP Get connection",
                "HTTP POST connection",
                "HTTP POST Authentication",
                "HTTP GET SignIned Connection",
                "HTTP POST Upload image png",
                "HTTP GET Basic Authenticate",
                "HTTP Download binary"]

    var isAuth = false

    let provider: ApiProvider = ApiProvider<DemoApi>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func detailViewController(param: String,
                              result: String = "",
                              responce: String = "",
                              error: String = "")
    {
        let detailViewController: DetailViewController = (storyboard?.instantiateViewController(withIdentifier: detailViewControllerId) as? DetailViewController)!
        navigationController?.pushViewController(detailViewController, animated: true)
        detailViewController.text = "param:\n\(param)\nresponce header:\n\(responce)\nresult:\n \n\(result)\n\(error)"
    }

    func detail(data: Data?,
                param: String = "",
                responce: HTTPURLResponse?,
                error: Error?)
    {
        DispatchQueue.main.async {
            if let unwrapData = data,
                let result = String(data: unwrapData, encoding: .utf8),
                let unwrapResponce = responce
            {
                self.detailViewController(param: param,
                                          result: result,
                                          responce: String(describing: unwrapResponce))
            } else if let unwrapResponce = responce {
                self.detailViewController(param: param,
                                          responce: String(describing: unwrapResponce))
            } else if let unwrapError = error {
                self.detailViewController(param: param,
                                          error: String(describing: unwrapError))
            }
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return apis.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = apis[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            provider.send(api: .zen) { [unowned self] data, responce, error in
                self.detail(data: data,
                            responce: responce,
                            error: error)
            }
        case 1:
            let val: Tapul = Tapul(value: ("http_post", value: "Http Request POST 😄"))
            provider.send(api: .post(param: val)) { [unowned self] data, responce, error in
                self.detail(data: data,
                            param: val.tapul,
                            responce: responce,
                            error: error)
            }
        case 2:

            let param = ["http_sign_in": "Http Request SignIn",
                         "userId": "keisukeYamagishi",
                         "password": "password_jisjdhsnjfbns"]
            let url = "https://httpsession.work/signIn.json"

            Http.request(url: url, method: .post, params: param)
                .session(completion: { [unowned self] data, responce, error in
                    self.detail(data: data,
                                param: param.toStr,
                                responce: responce,
                                error: error)
                })
        case 3:

            Http.request(url: "https://httpsession.work/signIned.json", method: .get, cookie: true)
                .session(completion: { [unowned self] data, responce, error in
                    self.detail(data: data,
                                responce: responce,
                                error: error)
                })
        case 4:
            provider.upload(api: .upload) { [unowned self] data, responce, error in
                self.detail(data: data,
                            responce: responce,
                            error: error)
            }
        case 5:
            let basicAuth: [String: String] = [Auth.user: "httpSession",
                                               Auth.password: "githubHttpsession"]
            Http.request(url: "https://httpsession.work/basicauth.json",
                         method: .get,
                         basic: basicAuth).session(completion: { [unowned self] data, responce, error in
                self.detail(data: data,
                            responce: responce,
                            error: error)
            })
        case 6:
            let detailViewController: DetailViewController = (storyboard?.instantiateViewController(withIdentifier: detailViewControllerId) as? DetailViewController)!
            navigationController?.pushViewController(detailViewController, animated: true)
            detailViewController.isDL = true
        default:
            print("Default")
        }
    }
}

struct Tapul {
    var value: (String, String)
}

extension Tapul {
    var tapul: String {
        return "\(value.0)\(value.1)"
    }
}

extension Dictionary {
    var toStr: String {
        var str: String = ""
        for (key, value) in self {
            str += "key: \(key) value: \(value)\n"
        }
        return str
    }
}
