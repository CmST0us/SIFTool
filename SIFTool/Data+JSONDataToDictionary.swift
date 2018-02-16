//
//  Data+JSONDataToDictionary.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension Data {
    func jsonDictionary() throws -> Dictionary<String, Any>? {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: self, options: [JSONSerialization.ReadingOptions.mutableContainers])
            return jsonObj as? Dictionary<String, Any>
        } catch {
            throw error
        }
    }
}
