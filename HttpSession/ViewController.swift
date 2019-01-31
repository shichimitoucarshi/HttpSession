//
//  ViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit

enum DemoApi {
    case zen
    case post(param:Tapul)
    case download
}

extension DemoApi:ApiProtocol {
    var domain: String{
        switch self {
        case .zen, .post:
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
            return "mp4/Designing_For_iPad_Pro_ad_hd.mp4"
        }
    }
    
    var method: Http.method {
        switch self {
        case .zen:
            return .get
        case .post:
            return .post
        case .download:
            return .get
        }
    }
    
    var header: [String : String]? {
        return [:]
    }
    
    var params: [String : String] {
        switch self {
        case .zen:
            return [:]
        case .post(let val):
            return [val.value.0:val.value.1]
        case .download:
            return [:]
        }
    }
    
    var isCookie: Bool {
        return false
    }
    
    var basicAuth: [String : String]? {
        return nil
    }
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var apis = ["HTTP Get connection",
                "HTTP POST connection",
                "HTTP POST Authentication",
                "HTTP GET SignIned Connection",
                "HTTP POST Upload image png",
                "HTTP GET Basic Authenticate",
                "HTTP Download binary",
                "HTTP POST Twitter OAuth"]
    
    var isAuth = false
    
    let provider:ApiProvider = ApiProvider<DemoApi>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
//        provider.request(api: .post(param: (key:"http_post",value:"Http Request POST 😄"))) { (data, responce, error) in
//            print (String(data: data!, encoding: .utf8))
//        }
        
//        provider.download(api: .download,                          
//                          data:nil,
//                          progress: { (written, total, expectedToWrite) in
//            let progress = Float(total) / Float(expectedToWrite)
//            print ("progress \(progress)")
//        }, download: { (url) in
//            print ("location: \(String(describing: url))")
//        }) { (data, responce, error) in
//            
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detailViewController (param: String, text: String) {
        let detailViewController: DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: detailViewControllerId) as! DetailViewController
        print ("text: \(text)")
        self.navigationController?.pushViewController(detailViewController, animated: true)
        detailViewController.text = "param:\n\(param)\n responce:\n \(text)"
    }
    
    func detail(data: Data, param: String = "") {
        DispatchQueue.main.async {
            let responceStr = String(data: data, encoding: .utf8)
            self.detailViewController(param: param, text: responceStr!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.apis[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            provider.request(api: .zen) { (data, responce, error) in
                self.detail(data: data!)
            }
            break
        case 1:
            let val:Tapul = Tapul(value: ("http_post",value:"Http Request POST 😄"))
            provider.request(api: .post(param: val)) { (data, responce, error) in
                self.detail(data: data!, param: val.tapul)
            }

            break
        case 2:
            
            let param = ["http_sign_in":"Http Request SignIn",
                         "userId":"keisukeYamagishi",
                         "password": "password_jisjdhsnjfbns"]
            let url = "https://httpsession.work/signIn.json"
            
            Http(url: url, method: .post, params:param)
                .session(completion: { (data, responce, error) in
                    self.detail(data: data!,param: param.toStr)
                })
            break
        case 3:
            
            Http(url: "https://httpsession.work/signIned.json", method: .get, cookie: true )
                .session(completion: { (data, responce, error) in
                    self.detail(data: data!)
            })
            
            break
            
        case 4:
            var dto: MultipartDto = MultipartDto()
            let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
            let img: Data = try! Data(contentsOf:  URL(fileURLWithPath:image!))
            
            dto.fileName = "Hello.txt"
            dto.mimeType = "text/plain"
            dto.data = img
            
            Http(url:"https://httpsession.work/imageUp.json",method: .post)
                .upload(param: ["img":dto], completionHandler: { (data, responce, error) in
                self.detail(data: data!)
            })
            
            break
        case 5:
            let basicAuth: [String:String] = [Auth.user: "httpSession",
                                              Auth.password: "githubHttpsession"]
            Http(url: "https://httpsession.work/basicauth.json",
                 method: .get,
                 basic: basicAuth).session(completion: { (data, responce, error) in
                self.detail(data: data!)
            })
            break
        case 6:
            
            let detailViewController: DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: detailViewControllerId) as! DetailViewController
            self.navigationController?.pushViewController(detailViewController, animated: true)
            detailViewController.isDL = true
            
            break
        case 7:
            
            Twitter.oAuth(urlType: "httpRequest-NNKAREvWGCn7Riw02gcOYXSVP://", success: {
                
                let vals: [String] = ["Tweet", "users", "follwers"]
                
                for val in vals {
                    if self.apis.contains(val) == false {
                        self.apis.append(val)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }, failuer: { (error, responce) in
                print("error: \(String(describing: error)) responce: \(String(describing: responce))")
            })
            
            break
        case 8:
            
            Twitter.tweet(tweet: "HttpSession https://cocoapods.org/pods/HttpSession", img: UIImage(named: "Re120.jpg")!, success: { (data) in
                self.detail(data: data!)
            }, failuer: { (responce, error) in
                print ("responce: \(String(describing: responce)) error: \(String(describing: error))")
            })
            
            break
        case 9:
            Twitter.users(success: { (data) in
                self.detail(data: data!)
            }, failuer: { (responce, error) in
                print ("responce: \(String(describing: responce)) error: \(String(describing: error))")
            })
            
            break
        case 10:
            
            Twitter.follwers(success: { (data) in
                self.detail(data: data!)
            }, failuer: { (responce, error) in
                print ("responce: \(String(describing: responce)) error: \(String(describing: error))")
            })
            
            break
        default:
            print ("Default")
        }
    }
}

struct Tapul {
    var value:(String,String)
}

extension Tapul {
    
    var tapul: String {
        return "\(self.value.0)\(self.value.1)"
    }
}

extension Dictionary {
    
    var toStr:String {
        var str: String = ""
        for (key,value) in self {
            str += "key: \(key) value: \(value)\n"
        }
        return str
    }
}
