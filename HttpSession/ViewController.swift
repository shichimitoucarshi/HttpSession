//
//  ViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var apis = ["HTTP Get connection",
                "HTTP POST connection",
                "HTTP POST Authentication",
                "HTTP GET SignIned Connection",
                "HTTP POST Upload image png",
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
            Http(url: "http://153.126.160.55/getApi.json", method: .get)
                .session(completion: { (data, responce, error) in
                self.detail(data: data!)
            })
            break
        case 1:
            
            let param = ["http_post":"Http Request POST 😄"]
            
            Http(url: "http://153.126.160.55/postApi.json",method: .post)
                .session(param: param,
                          completion: { (data, responce, error) in
                self.detail(data: data!, param: param.hashString())
            })
            break
        case 2:
            
            let param = ["http_sign_in":"Http Request SignIn",
                         "userId":"keisukeYamagishi",
                         "password": "password_jisjdhsnjfbns"]
            
            Http(url: "http://153.126.160.55/signIn.json",method: .post, cookie: true)
                .session(param: param,
                          completion: { (data, responce, error) in
                            self.detail(data: data!,param: param.hashString())
                })
            break
        case 3:
            
            Http(url: "http://153.126.160.55/signIned.json", method: .get, cookie: true )
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
            
            Http(url:"http://153.126.160.55/imageUp.json",method: .post)
                .upload(param: ["img":dto], completionHandler: { (data, responce, error) in
                self.detail(data: data!)
            })
            
            break
        case 5:
            Twitter().oAuth(urlType: "httpRequest://success", completion: { (data, response, error) in
                let responseData = String(data:data!, encoding:String.Encoding.utf8)
                var attributes = responseData?.queryStringParameters
                
                if let attrbute = attributes?["oauth_token"] {
                    let url: String = "https://api.twitter.com/oauth/authorize?oauth_token=" + attrbute
                    let queryURL = URL(string: url)!
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(queryURL, options: [:])
                    } else {
                        UIApplication.shared.openURL(queryURL)
                    }
                    self.apis.append("Tweet")
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
            break
        case 6:
            Http().postTweet(tweet: "HttpSession https://cocoapods.org/pods/HttpSession", img: UIImage(named: "Re120.jpg")!, success: { (data, responce, error) in
                self.detail(data: data!)
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

