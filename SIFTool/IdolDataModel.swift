//
//  IdolDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/16.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
class IdolDataModel {
    struct CodingKey {
        static let name = "name"
        static let japaneseName = "japaneseName"
        static let main = "main"
        static let age = "age"
        static let school = "school"
        static let birthday = "birthday"
        static let astrologicalSign = "astrological_sign"
        static let blood = "blood"
        static let height = "height"
        static let measurements = "measurements"
        static let favoriteFood = "favorite_food"
        static let leastFavoriteFood = "least_favorite_food"
        static let hobbies = "hobbies"
        static let attribute = "attribute"
        static let year = "year"
        static let mainUnit = "main_unit"
        static let subUnit = "sub_unit"
        static let cv = "cv"
        static let summary = "summary"
        static let websiteUrl = "website_url"
        static let wikiUrl = "wiki_url"
        static let wikiaUrl = "wikia_url"
        static let officialUrl = "official_url"
        static let chibi = "chibi"
        static let chibiSmall = "chibi_small"
    }
    
    var name: String!
    var japaneseName: String? = nil
    var main: Bool? = nil
    var age: Int? = nil
    var school: String? = nil
    var birthday: Date? = nil
    var astrologicalSign: String? = nil
    var blood: String? = nil
    var height: Int? = nil
    var measurements: String? = nil
    var favoriteFood: String? = nil
    var leastFavoriteFood: String? = nil
    var hobbies: String? = nil
    var attribute: String? = nil
    var year: String? = nil
    var mainUnit: String? = nil
    var subUnit: String? = nil
    var cv: CVDataModel? = nil
    var summary: String? = nil
    var websiteUrl: String!
    var wikiUrl: String? = nil
    var wikiaUrl: String? = nil
    var officialUrl: String? = nil
    var chibi: String? = nil
    var chibiSmall: String? = nil
    
    required init(withDictionary dictionary: Dictionary<String, Any>) {
        name = dictionary[CodingKey.name] as! String
        japaneseName = dictionary[CodingKey.japaneseName] as? String
        main = dictionary[CodingKey.main] as? Bool
        age = dictionary[CodingKey.age] as? Int
        school = dictionary[CodingKey.school] as? String
        if let birthdayString = dictionary[CodingKey.birthday] as? String {
            birthday = birthdayString.dateObj(withFormat: "MM-dd")
        }
        astrologicalSign = dictionary[CodingKey.astrologicalSign] as? String
        blood = dictionary[CodingKey.blood] as? String
        height = dictionary[CodingKey.height] as? Int
        measurements = dictionary[CodingKey.measurements] as? String
        favoriteFood = dictionary[CodingKey.favoriteFood] as? String
        leastFavoriteFood = dictionary[CodingKey.leastFavoriteFood] as? String
        hobbies = dictionary[CodingKey.hobbies] as? String
        attribute = dictionary[CodingKey.attribute] as? String
        year = dictionary[CodingKey.year] as? String
        mainUnit = dictionary[CodingKey.mainUnit] as? String
        subUnit = dictionary[CodingKey.subUnit] as? String
        if let c = dictionary[CodingKey.cv] as? Dictionary<String, Any> {
            cv = CVDataModel(withDictionary: c)
        }
        summary = dictionary[CodingKey.summary] as? String
        
        websiteUrl = (dictionary[CodingKey.websiteUrl] as! String).addHttpSchemaString()
        if let u = dictionary[CodingKey.wikiUrl] as? String {
            wikiUrl = u.addHttpSchemaString()
        }
        if let u = dictionary[CodingKey.wikiaUrl] as? String {
            wikiaUrl = u.addHttpSchemaString()
        }
        if let u = dictionary[CodingKey.officialUrl] as? String {
            officialUrl = u.addHttpSchemaString()
        }
        if let u = dictionary[CodingKey.chibi] as? String {
            chibi = u.addHttpSchemaString()
        }
        if let u = dictionary[CodingKey.chibiSmall] as? String {
            chibiSmall = u.addHttpSchemaString()
        }
    }
}

// MARK: - ApiRequest协议方法
extension IdolDataModel: IdolApiRequestParamProtocol {
    static func requestPage(_ page: Int, pageSize: Int) -> ApiRequestParam {
        let p = ApiRequestParam()
        p.method = ApiRequestParam.Method.GET
        p.path = "/idols"
        p.query = [
            "page": String(page),
            "page_size": String(pageSize)
        ]
        return p
    }
    
    static func requestIdol(withEnglishName englishName: String) -> ApiRequestParam {
        let p = ApiRequestParam()
        p.method = ApiRequestParam.Method.GET
        p.path = "/idols/\(englishName)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return p
    }
    
    
}
