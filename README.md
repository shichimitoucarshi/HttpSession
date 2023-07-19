# HttpSession

[![](https://img.shields.io/badge/HP-shichimitoucarashi-00acee)]([https://shichimitoucarashi.com/](https://shichimitoucarashi.herokuapp.com/))
[![](https://img.shields.io/badge/Lang-Swift-ff69b4)](https://developer.apple.com/jp/swift/)
[![](https://img.shields.io/badge/LICENCE-MIT-orange)](https://github.com/keisukeYamagishi/HttpRequest/blob/master/LICENSE)

***Build status***

![build](https://github.com/keisukeYamagishi/HttpSession/workflows/build/badge.svg)

### Overview

TCP / IP based HTTP communication can be simplified
and Twitter OAuth

***API Server:*** https://sevens-api.herokuapp.com/

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
Http.request(url: "https://sevens-api.herokuapp.com/getApi.json", method: .get)
  .session(completion: { (data, responce, error) in
    self.detail(data: data!)
})
```

POST http method

```swift

let param = ["http_post":"Http Request POST 😄"]
            
Http.request(url: "https://sevens-api.herokuapp.com/postApi.json",method: .post)
  .session(param: param,
  completion: { (data, responce, error) in {
  self.detail(data: data!, param: param.hashString())
})

```

Download http method

```swift
Http.request(url: "https://shichimitoucarashi.com/mp4/file1.mp4", method: .get)
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
    case post(param: Tapul)
    case jsonPost(param: [String: String])
    case download
    case upload
}

extension DemoApi: ApiProtocol {
    var encode: Http.Encode {
        switch self {
        case .zen, .post, .upload, .download:
            return .url
        case .jsonPost:
            return .json
        }
    }

    var isNeedDefaultHeader: Bool {
        true
    }

    var domain: String {
        switch self {
        case .zen, .post, .upload:
            return "https://sevens-api.herokuapp.com"
        case .download:
            return "https://shichimitoucarashi.com"
        case .jsonPost:
            return "https://decoy-sevens.herokuapp.com"
        }
    }

    var endPoint: String {
        switch self {
        case .zen:
            return "getApi.json"
        case .post:
            return "postApi.json"
        case .download:
            return "apple-movie.mp4"
        case .upload:
            return "imageUp.json"
        case .jsonPost:
            return "json.json"
        }
    }

    var method: Http.Method {
        switch self {
        case .zen:
            return .get
        case .post, .jsonPost, .upload:
            return .post
        case .download:
            return .get
        }
    }

    var header: [String: String]? {
        nil
    }

    var params: [String: String]? {
        switch self {
        case .zen:
            return nil
        case let .post(val):
            return [val.value.0: val.value.1]
        case let .jsonPost(param):
            return param
        case .upload:
            return nil
        case .download:
            return nil
        }
    }

    var multipart: [Multipartible]? {
        switch self {
        case .upload:
            let image: String? = Bundle.main.path(forResource: "re", ofType: "txt")
            let img: Data
            do {
                img = try Data(contentsOf: URL(fileURLWithPath: image!))
            } catch {
                img = Data()
            }

            return [Multipartible(key: "img",
                                  fileName: "Hello.txt",
                                  mineType: "text/plain",
                                  data: img)]
        case .zen, .post, .jsonPost, .download:
            return nil
        }
    }

    var isCookie: Bool {
        false
    }

    var basicAuth: [String: String]? {
        nil
    }
}

```

```swift
let provider:ApiProvider = ApiProvider<DemoApi>()

provider.send(api: .zen) { (data, responce, error) in
    self.detail(data: data!)
}

provider.send(api: .post(param: (key:"http_post",value:"Http Request POST 😄"))) { (data, responce, error) in
    print (String(data: data!, encoding: .utf8))
}
```

