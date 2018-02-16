//
//  CardDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

class CardDataModel {
    
    struct CodingKey {
        static let id = "id"
        static let idol = "idol"
        static let rarity = "rarity"
        static let attribute = "attribute"
        static let japaneseCollection = "japanese_collection"
        static let translatedCollection = "translated_collection"
        static let japaneseAttribute = "japanese_attribute"
        static let isPromo = "is_promo"
        static let promoItem = "promo_item"
        static let promoLink = "promo_link"
        static let releaseDate = "release_date"
        static let japanOnly = "japan_only"
        static let event = "event"
        static let isSpecial = "is_special"
        static let hp = "hp"
        static let minimumStatisticsSmile = "minimum_statistics_smile"
        static let minimumStatisticsPure = "minimum_statistics_pure"
        static let minimumStatisticsCool = "minimum_statistics_cool"
        static let nonIdolizedMaximumStatisticsSmile = "non_idolized_maximum_statistics_smile"
        static let nonIdolizedMaximumStatisticsPure = "non_idolized_maximum_statistics_pure"
        static let nonIdolizedMaximumStatisticsCool = "non_idolized_maximum_statistics_cool"
        static let idolizedMaximumStatisticsSmile = "idolized_maximum_statistics_smile"
        static let idolizedMaximumStatisticsPure = "idolized_maximum_statistics_pure"
        static let idolizedMaximumStatisticsCool = "idolized_maximum_statistics_cool"
        static let skill = "skill"
        static let japaneseSkill = "japanese_skill"
        static let skillDetails = "skill_details"
        static let japaneseSkillDetails = "japanese_skill_details"
        static let centerSkill = "center_skill"
        static let centerSkillDetails = "center_skill_details"
        static let japaneseCenterSkill = "japanese_center_skill"
        static let japaneseCenterSkillDetails = "japanese_center_skill_details"
        static let cardImage = "card_image"
        static let cardIdolizedImage = "card_idolized_image"
        static let roundCardImage = "round_card_image"
        static let roundCardIdolizedImage = "round_card_idolized_image"
        static let videoStory = "video_story"
        static let japaneseVideoStory = "japanese_video_story"
        static let websiteUrl = "website_url"
        static let nonIdolizedMaxLevel = "non_idolized_max_level"
        static let idolizedMaxLevel = "idolized_max_level"
        static let transparentImage = "transparent_image"
        static let transparentIdolizedImage = "transparent_idolized_image"
        static let cleanUr = "clean_ur"
        static let cleanUrIdolized = "clean_ur_idolized"
        static let skillUpCards = "skill_up_cards"
        static let urPair = "ur_pair"
        static let totalOwners = "total_owners"
        static let totalWishlist = "total_wishlist"
        static let rankingAttribute = "ranking_attribute"
        static let rankingRarity = "ranking_rarity"
        static let rankingSpecial = "ranking_special"
    }
    
    struct Rarity {
        static let UR = "UR"
        static let SSR = "SSR"
        static let SR = "SR"
        static let R = "R"
        static let N = "N"
    }
    
    struct Attribute {
        static let smile = "Smile"
        static let pure = "Pure"
        static let cool = "Cool"
        static let all = "All"
    }
    
    var id: Int!
    var idol: MiniIdolDataModel!
    var rarity: String!
    var attribute: String!
    var japaneseCollection: String? = nil
    var translatedCollection: String? = nil
    var japaneseAttribute: String? = nil
    var isPromo: Bool? = nil
    var promoItem: String? = nil
    var promoLink: String? = nil
    var releaseDate: Date? = nil
    var japanOnly: Bool? = nil
    var event: MiniEventDataModel? = nil
    var isSpecial: Bool? = nil
    var hp: Int? = nil
    var minimumStatisticsSmile: Int? = nil
    var minimumStatisticsPure: Int? = nil
    var minimumStatisticsCool: Int? = nil
    var nonIdolizedMaximumStatisticsSmile: Int? = nil
    var nonIdolizedMaximumStatisticsPure: Int? = nil
    var nonIdolizedMaximumStatisticsCool: Int? = nil
    var idolizedMaximumStatisticsSmile: Int? = nil
    var idolizedMaximumStatisticsPure: Int? = nil
    var idolizedMaximumStatisticsCool: Int? = nil
    var skill: String? = nil
    var japaneseSkill: String? = nil
    var skillDetails: String? = nil
    var japaneseSkillDetails: String? = nil
    var centerSkill: String? = nil
    var centerSkillDetails: String? = nil
    var japaneseCenterSkill: String? = nil
    var japaneseCenterSkillDetails: String? = nil
    var cardImage: String? = nil
    var cardIdolizedImage: String? = nil
    var roundCardImage: String? = nil
    var roundCardIdolizedImage: String? = nil
    var videoStory: String? = nil
    var japaneseVideoStory: String? = nil
    var websiteUrl: String!
    var nonIdolizedMaxLevel: Int? = nil
    var idolizedMaxLevel: Int? = nil
    var transparentImage: String? = nil
    var transparentIdolizedImage: String? = nil
    var cleanUr: String? = nil
    var cleanUrIdolized: String? = nil
    var skillUpCards: [SkillUpTinyCardDataModel]? = nil
    var urPair: URPairDataModel? = nil
    var totalOwners: Int? = nil
    var totalWishlist: Int? = nil
    var rankingAttribute: Int? = nil
    var rankingRarity: Int? = nil
    var rankingSpecial: Int? = nil
    
    required init(withDictionary dictionary: Dictionary<String, Any>) {
        id = dictionary[CodingKey.id] as! Int
        idol = MiniIdolDataModel(withDictionary: dictionary[CodingKey.idol] as! Dictionary<String, Any>)
        rarity = dictionary[CodingKey.rarity] as! String
        attribute = dictionary[CodingKey.attribute] as! String
        japaneseCollection = dictionary[CodingKey.japaneseCollection] as? String
        translatedCollection = dictionary[CodingKey.translatedCollection] as? String
        japaneseAttribute = dictionary[CodingKey.japaneseAttribute] as? String
        isPromo = dictionary[CodingKey.isPromo] as? Bool
        promoItem = dictionary[CodingKey.promoItem] as? String
        promoLink = dictionary[CodingKey.promoLink] as? String
        if let rd = dictionary[CodingKey.releaseDate] as? String {
            releaseDate = rd.dateObj()
        }
        japanOnly = dictionary[CodingKey.japanOnly] as? Bool
        if let e = dictionary[CodingKey.event] as? Dictionary<String, Any> {
            event = MiniEventDataModel(withDictionary: e)
        }
        isSpecial = dictionary[CodingKey.isSpecial] as? Bool
        hp = dictionary[CodingKey.hp] as? Int
        minimumStatisticsSmile = dictionary[CodingKey.minimumStatisticsSmile] as? Int
        minimumStatisticsPure = dictionary[CodingKey.minimumStatisticsPure] as? Int
        minimumStatisticsCool = dictionary[CodingKey.minimumStatisticsCool] as? Int
        nonIdolizedMaximumStatisticsSmile = dictionary[CodingKey.nonIdolizedMaximumStatisticsSmile] as? Int
        nonIdolizedMaximumStatisticsPure = dictionary[CodingKey.nonIdolizedMaximumStatisticsPure] as? Int
        nonIdolizedMaximumStatisticsCool = dictionary[CodingKey.nonIdolizedMaximumStatisticsCool] as? Int
        idolizedMaximumStatisticsSmile = dictionary[CodingKey.idolizedMaximumStatisticsSmile] as? Int
        idolizedMaximumStatisticsPure = dictionary[CodingKey.idolizedMaximumStatisticsPure] as? Int
        idolizedMaximumStatisticsCool = dictionary[CodingKey.idolizedMaximumStatisticsCool] as? Int
        skill = dictionary[CodingKey.skill] as? String
        japaneseSkill = dictionary[CodingKey.japaneseSkill] as? String
        skillDetails = dictionary[CodingKey.skillDetails] as? String
        japaneseSkillDetails = dictionary[CodingKey.japaneseSkillDetails] as? String
        centerSkill = dictionary[CodingKey.centerSkill] as? String
        centerSkillDetails = dictionary[CodingKey.centerSkillDetails] as? String
        japaneseCenterSkill = dictionary[CodingKey.japaneseCenterSkill] as? String
        japaneseCenterSkillDetails = dictionary[CodingKey.japaneseCenterSkillDetails] as? String
        if let ci = dictionary[CodingKey.cardImage] as? String {
            cardImage = ci.addHttpSchemaString()
        }
        if let cii = dictionary[CodingKey.cardIdolizedImage] as? String {
            cardIdolizedImage = cii.addHttpSchemaString()
        }
        if let rci = dictionary[CodingKey.roundCardImage] as? String {
            roundCardImage = rci.addHttpSchemaString()
        }
        if let rcii = dictionary[CodingKey.roundCardIdolizedImage] as? String {
            roundCardIdolizedImage = rcii.addHttpSchemaString()
        }
        videoStory = dictionary[CodingKey.videoStory] as? String
        japaneseVideoStory = dictionary[CodingKey.japaneseVideoStory] as? String
        websiteUrl = dictionary[CodingKey.websiteUrl] as! String
        nonIdolizedMaxLevel = dictionary[CodingKey.nonIdolizedMaxLevel] as? Int
        idolizedMaxLevel = dictionary[CodingKey.idolizedMaxLevel] as? Int
        if let ti = dictionary[CodingKey.transparentImage] as? String {
            transparentImage = ti.addHttpSchemaString()
        }
        if let tii = dictionary[CodingKey.transparentIdolizedImage] as? String {
            transparentIdolizedImage = tii.addHttpSchemaString()
        }
        if let cu = dictionary[CodingKey.cleanUr] as? String {
            cleanUr = cu.addHttpSchemaString()
        }
        if let cui = dictionary[CodingKey.cleanUrIdolized] as? String {
            cleanUrIdolized = cui.addHttpSchemaString()
        }
        if let s = dictionary[CodingKey.skillUpCards] as? [Dictionary<String, Any>] {
            if s.count != 0 {
                skillUpCards = []
                for ss in s {
                    skillUpCards?.append(SkillUpTinyCardDataModel(withDictionary: ss))
                }
            }
        }
        if let up = dictionary[CodingKey.urPair] as? Dictionary<String, Any> {
            urPair = URPairDataModel(withDictionary: up)
        }
        totalOwners = dictionary[CodingKey.totalOwners] as? Int
        totalWishlist = dictionary[CodingKey.totalWishlist] as? Int
        rankingAttribute = dictionary[CodingKey.rankingAttribute] as? Int
        rankingRarity = dictionary[CodingKey.rankingRarity] as? Int
        rankingSpecial = dictionary[CodingKey.rankingSpecial] as? Int
    }
}


// MARK: - CardApiRequestParam 协议方法
extension CardDataModel: CardApiRequestParamProtocol {
    static func requestPage(_ page: Int, pageSize: Int) -> ApiRequestParam {
        let p = ApiRequestParam()
        p.method = ApiRequestParam.Method.GET
        p.path = "/cards"
        p.query = [
            "page_size": String(pageSize),
            "page": String(page)
        ]
        return p
    }
}
