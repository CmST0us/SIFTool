//
//  MiniIdolDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

@objcMembers
class MiniIdolDataModel: NSObject {
    struct CodingKey {
        static let name = "name"
        static let school = "school"
        static let year = "year"
        static let mainUnit = "main_unit"
        static let japaneseName = "japanese_name"
        static let subUnit = "sub_unit"
    }
    
    var name: String {
        if japaneseName != nil {
            return japaneseName!
        }
        return englishName
    }
    var school: String? = nil
    var year: String? = nil
    var mainUnit: String? = nil
    var englishName: String
    var japaneseName: String? = nil
    var subUnit: String? = nil
    
    required init(withDictionary dictionary: Dictionary<String, Any>) {
        englishName = dictionary[CodingKey.name] as! String
        school = dictionary[CodingKey.school] as? String
        year = dictionary[CodingKey.year] as? String
        mainUnit = dictionary[CodingKey.mainUnit] as? String
        japaneseName = dictionary[CodingKey.japaneseName] as? String
        subUnit = dictionary[CodingKey.subUnit] as? String
        super.init()
    }
}
