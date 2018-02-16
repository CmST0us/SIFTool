//
//  SkillUpTinyCardDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
class SkillUpTinyCardDataModel {
    struct CodingKey {
        static let id = "id"
        static let roundCardImage = "round_card_image"
    }
    
    var id: Int? = nil
    var roundCardImage: String? = nil
    
    required init(withDictionary dictionary: Dictionary<String, Any>) {
        id = dictionary[CodingKey.id] as? Int
        if let rc = dictionary[CodingKey.roundCardImage] as? String {
            roundCardImage = rc.addHttpSchemaString()
        }
    }
}
