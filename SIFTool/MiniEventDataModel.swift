//
//  MiniEventDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
class MiniEventDataModel {
    struct CodingKey {
        static let japaneseName = "japanese_name"
        static let englishName = "english_name"
        static let translatedName = "translated_name"
        static let image = "image"
    }
    
    var japaneseName: String? = nil
    var englishName: String? = nil
    var translatedName: String? = nil
    var image: String? = nil
    
    required init(withDictionary dictionary: Dictionary<String, Any>) {
        japaneseName = dictionary[CodingKey.japaneseName] as? String
        englishName = dictionary[CodingKey.englishName] as? String
        translatedName = dictionary[CodingKey.translatedName] as? String
        image = dictionary[CodingKey.image] as? String
    }
}
