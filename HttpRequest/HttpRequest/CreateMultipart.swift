//
//  CreateMultipart.swift
//  RNTApps
//
//  Created by shichimi on 2017/05/04.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import Foundation

class Multipart {
    
    
    
    public var bundary: String!
    public var uuid: String!
    
    init(uuid: String){
        self.bundary = "multipart/form-data; boundary=" + uuid
        self.uuid = uuid
    }
    
    func imgMultiPart( mineType: String, ImageParam: Dictionary<String, Data>) -> Data{
        
        var post: Data = Data()
        var count: Int = 0
        for(key, value) in ImageParam {
            
            let userId = "shichimi"
            
            let imgName = "\(userId)_\(count).jpg"
            count = count + 1
            post.append(multipart(boundary: self.uuid, key: key, fileName: imgName as String, mineType: mineType, postData: value as Data))
            
        }
        return post
    }

    func createMultiPart(mineType: String, ImageParam: Dictionary<String, String>) -> Data{
        
        var post: Data = Data()
        
        for(key, value) in ImageParam {
            
            let imgName: NSString = (value as NSString)
            let imagePath = Bundle.main.path(forResource: imgName.deletingPathExtension, ofType: imgName.pathExtension)
            
            let imageData: NSData = try! NSData(contentsOfFile: imagePath!)
            
            post.append(multipart(boundary: self.uuid, key: key, fileName: imgName as String, mineType: mineType, postData: imageData as Data))
            
        }
        return post
    }
    
    func textMultiPart(uuid: String, param: Dictionary<String, String>) -> Data{
        var multiPart: Data = Data()
        
        for(key, value) in param{
            
            multiPart.append("--\(uuid)\r\n".data(using: .utf8)!)
            
            multiPart.append("Content-Disposition: form-data;".data(using: .utf8)!)
            
            multiPart.append("name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            
            multiPart.append("\(value)\r\n".data(using: .utf8)!)
            
        }
        return multiPart
    }
    
    func multipart(boundary: String, key: String, fileName: String, mineType: String, postData: Data) -> Data{
        
        var multiPart: Data = Data()
        
        multiPart.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        multiPart.append("Content-Disposition: form-data;".data(using: .utf8)!)
        
        multiPart.append("name=\"\(key)\";".data(using: .utf8)!)
        
        multiPart.append("filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        
        multiPart.append("Content-Type: \(mineType)\r\n\r\n".data(using: .utf8)!)
        
        multiPart.append(postData)
        
        multiPart.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return multiPart as Data
    }
    
    static func mulipartContent(with boundary: String, data: Data, fileName: String?, parameterName: String,  mimeType mimeTypeOrNil: String?) -> Data {
        let mimeType = mimeTypeOrNil ?? "application/octet-stream"
        let fileNameContentDisposition = fileName != nil ? "filename=\"\(fileName!)\"" : ""
        let contentDisposition = "Content-Disposition: form-data; name=\"\(parameterName)\"; \(fileNameContentDisposition)\r\n"
        
        var tempData = Data()
        tempData.append("--\(boundary)\r\n".data(using: .utf8)!)
        tempData.append(contentDisposition.data(using: .utf8)!)
        tempData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        tempData.append(data)
        return tempData
    }
}
