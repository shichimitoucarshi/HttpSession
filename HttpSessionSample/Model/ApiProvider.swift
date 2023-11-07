//
//  ApiProvider.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2023/11/07.
//

import HttpSession

extension Http {
    public class func request(api: ApiProtocol) -> Http {
        Http.request(url: api.domain + "/" + api.endPoint,
                                       method: api.method,
                                       encode: api.encode,
                                       isNeedDefaultHeader: api.isNeedDefaultHeader,
                                       header: api.header,
                                       params: api.params,
                                       multipart: api.multipart,
                                       cookie: api.isCookie,
                                       basic: api.basicAuth)
        }

}

protocol HttpApi: AnyObject {
    associatedtype ApiType: ApiProtocol

    func send(api: ApiType, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func download(api: ApiType,
                  data: Data?,
                  progress: @escaping (_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void,
                  download: @escaping (_ path: URL?) -> Void,
                  completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func upload(api: ApiType,
                progress: ((_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void)?,
                completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func cancel(byResumeData: @escaping (Data?) -> Void)

    func cancelTask()
}

public class ApiProvider<Type: ApiProtocol>: HttpApi {
    public typealias ApiType = Type

    public init() {}

    public func send(api: Type,
                     completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).session(completion: completion)
    }

    public func upload(api: Type,
                       progress: ((_ written: Int64, _ total: Int64, _ expectedToWrite: Int64) -> Void)? = nil,
                       completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).upload(progress: progress, completion: completion)
    }

    public func download(api: Type,
                         data: Data? = nil,
                         progress: @escaping (Int64, Int64, Int64) -> Void,
                         download: @escaping (URL?) -> Void,
                         completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    {
        Http.request(api: api).download(resumeData: data,
                                        progress: progress,
                                        download: download,
                                        completionHandler: completionHandler)
    }

    public func cancel(byResumeData: @escaping (Data?) -> Void) {
        Http.shared.cancel { data in
            byResumeData(data)
        }
    }

    public func cancelTask() {
        Http.shared.cancel()
    }
}

