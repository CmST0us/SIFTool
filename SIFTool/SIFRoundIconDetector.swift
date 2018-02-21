//
//  SIFRoundIconDetector.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/20.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
#if TARGET_OS_IPHONE
import UIKit
#endif

class SIFRoundIconDetector {
    private var _cards: [CardDataModel] = []
    private var _roundCardImagePattern: CVMat!
    private var _configuration: SIFRoundIconDetectorConfiguration
    
    init(withCards cardsArray: [CardDataModel], configuration: SIFRoundIconDetectorConfiguration) {
        _cards = cardsArray
        _configuration = configuration
        
        let cardCount = CGFloat(cardsArray.count)
        var patternSize = _configuration.patternRealSize
        patternSize.height = patternSize.height * cardCount
        patternSize.width = patternSize.width * 2
        
        _roundCardImagePattern = OpenCVBridgeSwiftHelper.sharedInstance().emptyImage(with: patternSize, channel: 4)
        
    }
    
    lazy var roundCardUrls: [(Int, URL?, URL?)] = {
        var u: [(Int, URL?, URL?)] = []
        for card in _cards {
            var roundCardImageUrl: URL? = nil
            var roundCardIdolizedImageUrl: URL? = nil
            if let urlPath = card.roundCardImage {
                roundCardImageUrl = URL(string: urlPath)
            }
            if let urlPath = card.roundCardIdolizedImage {
                roundCardIdolizedImageUrl = URL(string: urlPath)
            }
            u.append((card.id, roundCardImageUrl, roundCardIdolizedImageUrl))
        }
        return u
    }()
    
    private func patternCoordinates(index: Int, idolize: Bool) -> (Double, Double) {
        let x = idolize ? _configuration.patternRealWidth : Double(0)
        let y = Double(index) * _configuration.patternRealHeight
        return (x, y)
    }
    
    func makeRoundCardImagePattern(cardId: Int, images: (CVMat?, CVMat?)) {
        if let roundCardImage = images.0 {
            let coordinates = patternCoordinates(index: cardId, idolize: false)
            let pattern = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(roundCardImage, to: CGSize.init(width: _configuration.patternWidth, height: _configuration.patternHeight)).roi(at: _configuration.patternRealRect)
            
            let roi = _roundCardImagePattern.roi(at: CGRect.init(origin: CGPoint.init(x: coordinates.0, y: coordinates.1), size: _configuration.patternRealSize))
            roi.fill(by: pattern)
        }
        if let idolizedRoundCardImage = images.1 {
            let coordinates = patternCoordinates(index: cardId, idolize: true)
            let pattern = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(idolizedRoundCardImage, to: CGSize.init(width: _configuration.patternWidth, height: _configuration.patternHeight)).roi(at: _configuration.patternRealRect)
            
            let roi = _roundCardImagePattern.roi(at: CGRect.init(origin: CGPoint.init(x: coordinates.0, y: coordinates.1), size: _configuration.patternRealSize))
            roi.fill(by: pattern)
        }
    }
    
}
