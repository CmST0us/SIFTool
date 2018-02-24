//
//  ApiHelper.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

struct ApiRequestError: Error {
    enum ErrorCode {
        case badUrl
        case requestTimeout
        case notInitial
        
    }
    
    var code: ErrorCode = .notInitial
    var message = ""
}

class ApiHelper {
    //MARK: - Private Member
    private lazy var _baseUrlPath: String = {
        return baseUrlPath
    }()
    
    //MARK: - Private Method
    private init() {
        
    }
    
    //MARK: - Public Member
    //MARK: Single Instance
    static let shared = ApiHelper()
    //api base url
    var baseUrlPath: String = ""
    
    //last invoke error
    var lastInvokeError: Error? = nil
    
    //request task wait time
    var taskWaitTime: Int = 4

}

extension ApiHelper {
    func request(param: ApiRequestParam) throws -> Data {
        var requestPath = _baseUrlPath + param.path
        if param.query.count > 0 {
            requestPath += ("?" + param.query.urlQueryString())
        }
        do {
            return try request(fullUrl: requestPath, param: param)
        } catch {
            throw error
        }
    }
    
    func request(fullUrl: String, param: ApiRequestParam) throws -> Data {
        var requestPath = fullUrl
        
        if param.query.count > 0 {
            requestPath += ("?" + param.query.urlQueryString())
        }
        
        if let url = URL(string: requestPath) {
            var request = URLRequest(url: url)
            request.httpMethod = param.method
            request.setValue("zh-cn", forHTTPHeaderField: "Accept-Language")
            let connectionSession = URLSession(configuration: .default)
            let sem = DispatchSemaphore(value: 0)
            var retData: Data? = nil
            
            let task = connectionSession.dataTask(with: request, completionHandler: { (data, response, error) in
                retData = data
                sem.signal()
            })
            
            task.resume()
            let waitTime = DispatchTime.now() + DispatchTimeInterval.seconds(taskWaitTime)
            let _ = sem.wait(timeout: waitTime)
            task.suspend()
            
            if retData == nil {
                throw ApiRequestError(code: .requestTimeout, message: "请求超时")
            } else {
                return retData!
            }
            
        } else {
            throw ApiRequestError(code: .badUrl, message: "URL 格式错误")
        }
    }
}
