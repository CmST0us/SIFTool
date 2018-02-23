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
//    private var _cards: [CardDataModel] = []
    private var _cards: [Int: CardDataModel] = [:]
    private var _roundCardImagePattern: CVMat!
    private var _configuration: SIFRoundIconDetectorConfiguration
    
    init(withCards cardsArray: [CardDataModel], configuration: SIFRoundIconDetectorConfiguration, roundCardImagePattern: CVMat? = nil) {
        for card in cardsArray {
            _cards[card.id] = card
        }
        _configuration = configuration
        
        let cardCount = cardsArray.max { (a, b) -> Bool in
            return a.id < b.id
        }
        var patternSize = _configuration.patternRealSize
        patternSize.height = patternSize.height * CGFloat(cardCount!.id + 1)
        patternSize.width = patternSize.width * 2
        
        if let p = roundCardImagePattern {
            _roundCardImagePattern = p
        } else {
            _roundCardImagePattern = OpenCVBridgeSwiftHelper.sharedInstance().emptyImage(with: patternSize, channel: 4)
        }
    }
    
    lazy var roundCardUrls: [(Int, URL?, URL?)] = {
        var u: [(Int, URL?, URL?)] = []
        for card in _cards.values {
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
    
    private func patternCoordinates(index: Int, idolize: Bool) -> (Int, Int) {
        let x = idolize ? _configuration.patternRealWidth : 0
        let y = index * _configuration.patternRealHeight
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
    
    func saveRoundCardImagePattern(toPath path: String) {
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(_roundCardImagePattern, fileName: path)
    }
    
    func makeTemplateImagePattern(image: CVMat) -> CVMat {
        let resizeImage = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(image, to: _configuration.patternSize)
        let roi = resizeImage.roi(at: _configuration.patternRealRect)
        return roi
    }
    
    func search(screenShoot: CVMat) -> [CGRect] {
        let grayMat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: screenShoot, targetColor: CVBridgeColorCovertType.bgr2Gray)
        let binrayMat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: grayMat, thresh: 250.0, maxValue: 255, type: CVBridgeThresholdType.binary_Inv)

        let contoursArray = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: binrayMat, mode: CVBridgeRetrievalMode.external, method: CVBridgeApproximationMode.none, offsetPoint: CGPoint.zero) as! [[NSValue]]
        
        var outputArray: [CGRect] = []
        for contours in contoursArray {
            let rect = contours.contoursRect()
            let area = rect.size.width * rect.size.height
            if area < 50 * 50 {
                continue
            }
            let aspectRadio = Double(rect.size.width / rect.size.height)
            let aspectRadioThresh = 0.2
            if abs(aspectRadio - 1) > aspectRadioThresh {
                continue
            }
            outputArray.append(rect)
        }
        return outputArray
    }
    
    
    func match(image: CVMat) -> CGPoint? {
        let resultMat = OpenCVBridgeSwiftHelper.sharedInstance().matchTemplate(withImage: _roundCardImagePattern, template: image, method: CVBridgeTemplateMatchMode.CCOEFF_NORMED)
        var maxValuePoint = (0, 0, Float(0))
        for y in 0 ..< Int(resultMat.size().height) {
            for x in 0 ..< Int(resultMat.size().width) {
                let v = resultMat.floatValue(at: CGPoint.init(x: x, y: y))
                if v > maxValuePoint.2 {
                    maxValuePoint = (x, y, v)
                }
            }
        }
        if maxValuePoint.2 == Float(0) {
            return nil
        }
        return CGPoint(x: maxValuePoint.0, y: maxValuePoint.1)
    }
    
    func card(atPatternPoint point: CGPoint) -> (CardDataModel, Bool)? {
        let idolized = Int(point.x) < Int(_configuration.patternRealWidth) ? false : true
        let yIndex = Int(Double(point.y) / Double(_configuration.patternRealHeight))
        if let card = _cards[yIndex] {
            return (card, idolized)
        }
        return nil
    }
    
}

//MARK: - use for debug
extension SIFRoundIconDetector {
    var patternImage: NSImage {
        return NSImage.init(cvMat: _roundCardImagePattern)
    }
}
