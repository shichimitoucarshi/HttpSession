//
//  ViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit
import HttpSession

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var apis = ["HTTP Get connection",
                "HTTP POST connection",
                "HTTP POST Authentication",
                "HTTP GET SignIned Connection",
                "HTTP POST Upload image png",
                "HTTP GET Basic Authenticate",
                "HTTP POST Twitter OAuth"]
    
    var isAuth = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
            Http(url: "https://httpsession.work/getApi.json", method: .get)
                .session(completion: { (data, responce, error) in
                self.detail(data: data!)
            })
            break
        case 1:
            
            let param = ["http_post":"Http Request POST 😄"]
            
            Http(url: "https://httpsession.work/postApi.json",method: .post,params: param)
                .session(completion: { (data, responce, error) in
                self.detail(data: data!, param: param.hashString())
            })
            break
        case 2:
            
            let param = ["http_sign_in":"Http Request SignIn",
                         "userId":"keisukeYamagishi",
                         "password": "password_jisjdhsnjfbns"]
            let url = "https://httpsession.work/signIn.json"
            
            Http(url: url, method: .post, params:param)
                .session(completion: { (data, responce, error) in
                            self.detail(data: data!,param: param.hashString())
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
                print("error: \(error) responce: \(responce)")
            })
            
            break
        case 7:
            
            Twitter.tweet(tweet: "HttpSession https://cocoapods.org/pods/HttpSession", img: UIImage(named: "Re120.jpg")!, success: { (data) in
                self.detail(data: data!)
            }, failuer: { (responce, error) in
                print ("responce: \(responce) error: \(error)")
            })
            
            break
        case 8:
            Twitter.users(success: { (data) in
                self.detail(data: data!)
            }, failuer: { (responce, error) in
                print ("responce: \(responce) error: \(error)")
            })
            
            break
        case 9:
            
            Twitter.follwers(success: { (data) in
                self.detail(data: data!)
            }, failuer: { (responce, error) in
                print ("responce: \(responce) error: \(error)")
            })
            
            break
        default:
            print ("Default")
        }
    }
}

extension Dictionary {
    
    func hashString() -> String {
        
        var hashStr: String = ""
        
        for (key,value) in self {
            
            hashStr += "key: \(key) value: \(value)\n"
            
        }
        return hashStr
    }
    
}

