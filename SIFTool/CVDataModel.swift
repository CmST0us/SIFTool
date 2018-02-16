//
//  CVDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/16.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
class CVDataModel {
    struct CodingKey {
        static let name = "name"
        static let nickname = "nickname"
        static let url = "url"
        static let twitter = "twitter"
        static let instagram = "instagram"
    }
    var name: String? = nil
    var nickname: String? = nil
    var url: String? = nil
    var twitter: String? = nil
    var instagram: String? = nil
    
    required init(withDictionary dictionary: Dictionary<String, Any>) {
        name = dictionary[CodingKey
            .name] as? String
        nickname = dictionary[CodingKey.nickname] as? String
        url = dictionary[CodingKey.url] as? String
        twitter = dictionary[CodingKey.twitter] as? String
        instagram = dictionary[CodingKey.instagram] as? String
    }
}
