//
//  SIFUserCardCollectionViewCell.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/6.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFUserCardCollectionViewCell: UICollectionViewCell {
    
    struct Identificer {
        static let userCardCell = "userCardCell"
    }
    
    @IBOutlet weak var cardRoundImageView: UIImageView!
    @IBOutlet weak var rarityNameIdLabel: UILabel!
    @IBOutlet weak var idolizedKizunaLabel: UILabel!
    
    @IBOutlet weak var smileIndicatorView: ScoreIndicatorView!
    @IBOutlet weak var coolScoreIndicatorView: ScoreIndicatorView!
    @IBOutlet weak var pureScoreIndicatorView: ScoreIndicatorView!
    
    func setupView(withCard: CardDataModel, userCard: UserCardDataModel) {
        
        cardRoundImageView.image = SIFCacheHelper.shared.image(withUrl: URL(string: (userCard.idolized ? withCard.roundCardIdolizedImage : withCard.roundCardImage) ?? ""))
        rarityNameIdLabel.text = "\(withCard.rarity) \(withCard.idol.japaneseName ?? withCard.idol.englishName) (\(String(withCard.id.intValue)))"
        let kizunaMaxString = userCard.isKizunaMax ? "绊满" : "绊0"
        let idolizedString = userCard.idolized ? "已觉醒" : "未觉醒"
        
        if idolizedKizunaLabel != nil {
            idolizedKizunaLabel.text = (kizunaMaxString + " " + idolizedString)
        }

        smileIndicatorView.maxScore = withCard.statisticsSmile(idolized: true, isKizunaMax: true).doubleValue
        smileIndicatorView.score = withCard.statisticsSmile(idolized: userCard.idolized, isKizunaMax: userCard.isKizunaMax).doubleValue
        
        coolScoreIndicatorView.maxScore = withCard.statisticsCool(idolized: true, isKizunaMax: true).doubleValue
        coolScoreIndicatorView.score = withCard.statisticsCool(idolized: userCard.idolized, isKizunaMax: userCard.isKizunaMax).doubleValue
        
        pureScoreIndicatorView.maxScore = withCard.statisticsPure(idolized: true, isKizunaMax: true).doubleValue
        pureScoreIndicatorView.score = withCard.statisticsPure(idolized: userCard.idolized, isKizunaMax: userCard.isKizunaMax).doubleValue
        
    }
    
}

