//
//  CreateMultipart.swift
//  RNTApps
//
//  Created by shichimi on 2017/05/04.
//  Copyright © 2017年 shichimitoucarashi. All rights reserved.
//

import UIKit

let carriageReturnString: String = "\r\n"

public struct Multipartible {
    public let key: String
    public let fileName: String
    public let mimeType: String
    public let data: Data

    public init(key: String,
                fileName: String,
                mineType: String,
                data: Data)
    {
        self.key = key
        self.fileName = fileName
        mimeType = mineType
        self.data = data
    }
}

public class Multipart {
    public let multipart: Multipartible
    public let boundary: Data

    public init(_ multipart: Multipartible, boundary: Data) {
        self.multipart = multipart
        self.boundary = boundary
    }

    func create() -> Data? {
        create(multipart)
    }

    func create(_ multipart: Multipartible) -> Data? {
        var body = Data()
        guard let unwrapContentDispostion = contentDisposition(multipart.key, multipart.fileName) else { return nil }
        guard let unwrapContentType = contentType(multipart.mimeType) else { return nil }
        guard let unwrapCarriageReturn = carriageReturn else { return nil }
        body.append(boundary)
        body.append(unwrapContentDispostion)
        body.append(unwrapContentType)
        body.append(multipart.data)
        body.append(unwrapCarriageReturn)
        body.append(boundary)
        return body
    }

    public func contentDisposition(_ key: String, _ fileName: String) -> Data? {
        configureUtf8Data("Content-Disposition", "form-data; name=\"\(key)\"; filename=\"\(fileName)\"\(carriageReturnString)")
    }

    public func contentType(_ mineType: String) -> Data? {
        configureUtf8Data("Content-Type", "\(mineType)\(carriageReturnString)\(carriageReturnString)")
    }

    public var carriageReturn: Data? {
        carriageReturnString.data(using: .utf8)
    }

    public func configureParameter(_ key: String, _ value: String) -> String {
        "\(key): \(value)"
    }

    public func configureUtf8Data(_ key: String, _ value: String, encoding: String.Encoding = .utf8) -> Data? {
        configureParameter(key, value).data(using: encoding)
    }
}

public class MultipartCreator {
    public let uuid: String
    public let boundaryString: String

    init() {
        uuid = UUID().uuidString
        boundaryString = String(format: "----\(uuid)")
    }

    class func multiparts(_ multipart: [Multipartible]) -> (data: Data?, boundary: String) {
        MultipartCreator().multiparts(multipart)
    }

    func multiparts(_ params: [Multipartible]) -> (Data?, String) {
        var post = Data()
        guard let unwrapBoundary = boundary else { return (nil, boundaryString) }
        params.forEach {
            let multipartData = Multipartible(key: $0.key,
                                              fileName: $0.fileName,
                                              mineType: $0.mimeType,
                                              data: $0.data)
            let multipart = Multipart(multipartData,
                                      boundary: unwrapBoundary)
            guard let unwrapMultipart = multipart.create() else { return }
            post.append(unwrapMultipart)
        }
        return (post, boundaryString)
    }

    public var boundary: Data? {
        ("--\(boundaryString)--\(carriageReturnString)").data(using: .utf8)
    }
}
