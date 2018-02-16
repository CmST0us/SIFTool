//
//  Dictionary+URLParam.swift
//  LLInfo
//
//  Created by CmST0us on 2018/1/31.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension Dictionary where Key == String, Value == String {
    func urlQueryString() -> String {
        if self.count == 0{
            return ""
        }
        var paramStringArray = [String]()
        for (k, v) in self {
            if let queryString = (k + "=" + v).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                paramStringArray.append(queryString)
            } else {
                return ""
            }
        }
        return paramStringArray.joined(separator: "&")
    }
}
