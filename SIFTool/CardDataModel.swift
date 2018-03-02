//
//  CardDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

@objcMembers
class CardDataModel: NSObject {
    
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
    
    var id: NSNumber
    var idol: MiniIdolDataModel
    var rarity: String
    var attribute: String
    var japaneseCollection: String? = nil
    var translatedCollection: String? = nil
    var japaneseAttribute: String? = nil
    var isPromo: NSNumber? = nil
    var promoItem: String? = nil
    var promoLink: String? = nil
    var releaseDate: Date? = nil
    var japanOnly: NSNumber? = nil
    var event: MiniEventDataModel? = nil
    var isSpecial: NSNumber? = nil
    var hp: NSNumber? = nil
    var minimumStatisticsSmile: NSNumber? = nil
    var minimumStatisticsPure: NSNumber? = nil
    var minimumStatisticsCool: NSNumber? = nil
    var minimumStatisticsMax: NSNumber {
        var smile = 0
        var pure = 0
        var cool = 0
        if minimumStatisticsCool != nil {
            cool = minimumStatisticsCool!.intValue
        }
        if minimumStatisticsPure != nil {
            pure = minimumStatisticsPure!.intValue
        }
        if minimumStatisticsSmile != nil {
            smile = minimumStatisticsSmile!.intValue
        }
        let maxValue = [smile, pure, cool].max()!
        return NSNumber(value: maxValue)
    }
    
    var nonIdolizedMaximumStatisticsSmile: NSNumber? = nil
    var nonIdolizedMaximumStatisticsPure: NSNumber? = nil
    var nonIdolizedMaximumStatisticsCool: NSNumber? = nil
    var nonIdolizedMaximumStatisticsMax: NSNumber {
        var smile = 0
        var pure = 0
        var cool = 0
        if nonIdolizedMaximumStatisticsCool != nil {
            cool = nonIdolizedMaximumStatisticsCool!.intValue
        }
        if nonIdolizedMaximumStatisticsPure != nil {
            pure = nonIdolizedMaximumStatisticsPure!.intValue
        }
        if nonIdolizedMaximumStatisticsSmile != nil {
            smile = nonIdolizedMaximumStatisticsSmile!.intValue
        }
        let maxValue = [smile, pure, cool].max()!
        return NSNumber(value: maxValue)
    }
    
    var idolizedMaximumStatisticsSmile: NSNumber? = nil
    var idolizedMaximumStatisticsPure: NSNumber? = nil
    var idolizedMaximumStatisticsCool: NSNumber? = nil
    var idolizedMaximumStatisticsMax: NSNumber {
        var smile = 0
        var pure = 0
        var cool = 0
        if idolizedMaximumStatisticsCool != nil {
            cool = idolizedMaximumStatisticsCool!.intValue
        }
        if idolizedMaximumStatisticsPure != nil {
            pure = idolizedMaximumStatisticsPure!.intValue
        }
        if idolizedMaximumStatisticsSmile != nil {
            smile = idolizedMaximumStatisticsSmile!.intValue
        }
        let maxValue = [smile, pure, cool].max()!
        return NSNumber(value: maxValue)
    }
    
    func statisticsSmile(idolized: Bool) -> NSNumber? {
        if idolized {
            return idolizedMaximumStatisticsSmile
        }
        return nonIdolizedMaximumStatisticsSmile
    }
    
    func statisticsPure(idolized: Bool) -> NSNumber? {
        if idolized {
            return idolizedMaximumStatisticsPure
        }
        return nonIdolizedMaximumStatisticsPure
    }
    
    func statisticsCool(idolized: Bool) -> NSNumber? {
        if idolized {
            return idolizedMaximumStatisticsCool
        }
        return nonIdolizedMaximumStatisticsCool
    }
    
    func statisticsMax(idolized: Bool) -> NSNumber {
        if idolized {
            return idolizedMaximumStatisticsMax
        }
        return nonIdolizedMaximumStatisticsMax
    }
    
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
    var websiteUrl: String
    var nonIdolizedMaxLevel: NSNumber? = nil
    var idolizedMaxLevel: NSNumber? = nil
    var transparentImage: String? = nil
    var transparentIdolizedImage: String? = nil
    var cleanUr: String? = nil
    var cleanUrIdolized: String? = nil
    var skillUpCards: [SkillUpTinyCardDataModel]? = nil
    var urPair: URPairDataModel? = nil
    var totalOwners: NSNumber? = nil
    var totalWishlist: NSNumber? = nil
    var rankingAttribute: NSNumber? = nil
    var rankingRarity: NSNumber? = nil
    var rankingSpecial: NSNumber? = nil
    
    init(withDictionary dictionary: Dictionary<String, Any>) {
        let idRaw = dictionary[CodingKey.id] as! Int
        id = NSNumber(value: idRaw)
        idol = MiniIdolDataModel(withDictionary: dictionary[CodingKey.idol] as! Dictionary<String, Any>)
        rarity = dictionary[CodingKey.rarity] as! String
        attribute = dictionary[CodingKey.attribute] as! String
        japaneseCollection = dictionary[CodingKey.japaneseCollection] as? String
        translatedCollection = dictionary[CodingKey.translatedCollection] as? String
        japaneseAttribute = dictionary[CodingKey.japaneseAttribute] as? String
        if let isPromoRaw = dictionary[CodingKey.isPromo] as? Bool {
            isPromo = NSNumber(value: isPromoRaw)
        }
        promoItem = dictionary[CodingKey.promoItem] as? String
        promoLink = dictionary[CodingKey.promoLink] as? String
        if let rd = dictionary[CodingKey.releaseDate] as? String {
            releaseDate = rd.dateObj(withFormat: "yyyy-MM-dd")
        }
        if let japanOnlyRaw = dictionary[CodingKey.japanOnly] as? Bool {
            japanOnly = NSNumber(value: japanOnlyRaw)
        }
        if let e = dictionary[CodingKey.event] as? Dictionary<String, Any> {
            event = MiniEventDataModel(withDictionary: e)
        }
        if let isSpecialRaw = dictionary[CodingKey.isSpecial] as? Bool {
            isSpecial = NSNumber(value: isSpecialRaw)
        }
        if let hpRaw = dictionary[CodingKey.hp] as? Int {
            hp = NSNumber(value: hpRaw)
        }
        if let minimumStatisticsSmileRaw = dictionary[CodingKey.minimumStatisticsSmile] as? Int {
            minimumStatisticsSmile = NSNumber(value: minimumStatisticsSmileRaw)
        }
        if let minimumStatisticsPureRaw = dictionary[CodingKey.minimumStatisticsPure] as? Int {
            minimumStatisticsPure = NSNumber(value: minimumStatisticsPureRaw)
        }
        if let minimumStatisticsCoolRaw = dictionary[CodingKey.minimumStatisticsCool] as? Int {
            minimumStatisticsCool = NSNumber(value: minimumStatisticsCoolRaw)
        }
        if let nonIdolizedMaximumStatisticsSmileRaw = dictionary[CodingKey.nonIdolizedMaximumStatisticsSmile] as? Int {
            nonIdolizedMaximumStatisticsSmile = NSNumber(value: nonIdolizedMaximumStatisticsSmileRaw)
        }
        if let nonIdolizedMaximumStatisticsPureRaw = dictionary[CodingKey.nonIdolizedMaximumStatisticsPure] as? Int {
            nonIdolizedMaximumStatisticsPure = NSNumber(value: nonIdolizedMaximumStatisticsPureRaw)
        }
        if let nonIdolizedMaximumStatisticsCoolRaw = dictionary[CodingKey.nonIdolizedMaximumStatisticsCool] as? Int {
            nonIdolizedMaximumStatisticsCool = NSNumber(value: nonIdolizedMaximumStatisticsCoolRaw)
        }
        if let idolizedMaximumStatisticsSmileRaw = dictionary[CodingKey.idolizedMaximumStatisticsSmile] as? Int {
            idolizedMaximumStatisticsSmile = NSNumber(value: idolizedMaximumStatisticsSmileRaw)
        }
        if let idolizedMaximumStatisticsPureRaw = dictionary[CodingKey.idolizedMaximumStatisticsPure] as? Int {
            idolizedMaximumStatisticsPure = NSNumber(value: idolizedMaximumStatisticsPureRaw)
        }
        if let idolizedMaximumStatisticsCoolRaw = dictionary[CodingKey.idolizedMaximumStatisticsCool] as? Int {
            idolizedMaximumStatisticsCool = NSNumber(value: idolizedMaximumStatisticsCoolRaw)
        }
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
        if let nonIdolizedMaxLevelRaw = dictionary[CodingKey.nonIdolizedMaxLevel] as? Int {
            nonIdolizedMaxLevel = NSNumber(value: nonIdolizedMaxLevelRaw)
        }
        if let idolizedMaxLevelRaw = dictionary[CodingKey.idolizedMaxLevel] as? Int {
            idolizedMaxLevel = NSNumber(value: idolizedMaxLevelRaw)
        }
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
        if let totalOwnersRaw = dictionary[CodingKey.totalOwners] as? Int {
            totalOwners = NSNumber(value: totalOwnersRaw)
        }
        if let totalWishlistRaw = dictionary[CodingKey.totalWishlist] as? Int {
            totalWishlist = NSNumber(value: totalWishlistRaw)
        }
        if let rankingAttributeRaw = dictionary[CodingKey.rankingAttribute] as? Int {
            rankingAttribute = NSNumber(value: rankingAttributeRaw)
        }
        if let rankingRarityRaw = dictionary[CodingKey.rankingRarity] as? Int {
            rankingRarity = NSNumber(value: rankingRarityRaw)
        }
        if let rankingSpecialRaw = dictionary[CodingKey.rankingSpecial] as? Int {
            rankingSpecial = NSNumber(value: rankingSpecialRaw)
        }
        super.init()
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
    static func requestIds() -> ApiRequestParam {
        let p = ApiRequestParam()
        p.method = ApiRequestParam.Method.GET
        p.path = "/cardids"
        return p
    }
}

// MARK: - Hashable
extension CardDataModel {
    static func ==(lhs: CardDataModel, rhs: CardDataModel) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        return false
    }
    
    override var hashValue: Int {
        return self.id.intValue
    }
}
