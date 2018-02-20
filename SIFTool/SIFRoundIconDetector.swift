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
        if cardId == 5 {
            OpenCVBridgeSwiftHelper.sharedInstance().saveImage(_roundCardImagePattern, fileName: "/Users/cmst0us/Downloads/dumps/patterns.png")
            
        } else if cardId > 5 {
            exit(0)
        }
        if let image1 = images.0 {
            let coordinates = patternCoordinates(index: cardId, idolize: false)
            let roi = _roundCardImagePattern.roi(at: CGRect.init(origin: CGPoint.init(x: coordinates.0, y: coordinates.1), size: _configuration.patternRealSize))
            roi.fill(by: image1)
        }
        if let image2 = images.1 {
            let coordinates = patternCoordinates(index: cardId, idolize: true)
            let roi = _roundCardImagePattern.roi(at: CGRect.init(origin: CGPoint.init(x: coordinates.0, y: coordinates.1), size: _configuration.patternRealSize))
            roi.fill(by: image2)
        }
        Logger.shared.console("card \(String(cardId)) make pattern ok")
        
        
    }
    
}
