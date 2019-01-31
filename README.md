# HttpSession

[![](https://img.shields.io/badge/Twitter-O--Liker%20Error-blue.svg)](https://twitter.com/O_Linker_Error)
[![](https://img.shields.io/badge/lang-swift4.0-ff69b4.svg)](https://developer.apple.com/jp/swift/)
[![](https://img.shields.io/badge/licence-MIT-green.svg)](https://github.com/keisukeYamagishi/HttpRequest/blob/master/LICENSE)

### Overview

TCP / IP based HTTP communication can be simplified
and Twitter OAuth

***API Server:*** https://httpsession.work/

### Recommended.

Codable SwiftyJSON and SWXMLHash is recommended.

[Codable](https://developer.apple.com/documentation/swift/codable)

[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

[drmohundro/SWXMLHash](https://github.com/drmohundro/SWXMLHash)

## Twitter API callback fix

https://developer.twitter.com/en/docs/basics/callback_url.html

## Installation

### Cocoapods

[CocoaPods](https://cocoapods.org/pods/HttpSession) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
To integrate GMSDirection into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
vi ./Podfile 
```

If you do not have the google map SDK for iOS

```
target 'Target Name' do
  use_frameworks!
  pod 'HttpSession'
end
```
Then, run the following command:

```bash
$ pod setup
$ pod install
```

## Use it

***Via SSH***: For those who plan on regularly making direct commits, cloning over SSH may provide a better experience (which requires uploading SSH keys to GitHub):

```
$ git clone git@github.com:keisukeYamagishi/HttpSession.git
```
***Via https***: For those checking out sources as read-only, HTTPS works best:

```
$ git clone https://github.com/keisukeYamagishi/HttpSession.git
```

## Sample code

GET http method

```swift
Http(url: "http://153.126.160.55/getApi.json", method: .get)
  .session(completion: { (data, responce, error) in
    self.detail(data: data!)
})
```

POST http method

```swift

let param = ["http_post":"Http Request POST 😄"]
            
Http(url: "http://153.126.160.55/postApi.json",method: .post)
  .session(param: param,
  completion: { (data, responce, error) in {
  self.detail(data: data!, param: param.hashString())
})

```

Download http method

```swift
Http(url: "https://shichimitoucarashi.com/mp4/file1.mp4", method: .get)
                .download(progress: { (written, total, expectedToWrite) in
                    let progress = Float(total) / Float(expectedToWrite)
                    print(String(format: "%.2f", progress * 100) + "%")                    
            }, download: { (location) in
                print ("location: \(String(describing: location))")
            }, completionHandler: { (data, responce, error) in
                self.detail(data: data!)
            })
```

Like Moya


```swift
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
```

```swift
let provider:ApiProvider = ApiProvider<DemoApi>()

provider.request(api: .zen) { (data, responce, error) in
    self.detail(data: data!)
}

provider.request(api: .post(param: (key:"http_post",value:"Http Request POST 😄"))) { (data, responce, error) in
    print (String(data: data!, encoding: .utf8))
}
```

