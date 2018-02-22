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
        
        _roundCardImagePattern = OpenCVBridgeSwiftHelper.sharedInstance().emptyImage(with: patternSize, channel: 3)
        
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
    
    func makeTemplateImagePattern(image: CVMat) -> CVMat {
        let resizeImage = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(image, to: _configuration.patternSize)
        let roi = resizeImage.roi(at: _configuration.patternRealRect)
        return roi
    }
    
    func match(image: CVMat) -> CGPoint? {
        let resultMat = OpenCVBridgeSwiftHelper.sharedInstance().matchTemplate(withImage: _roundCardImagePattern, template: image, method: CVBridgeTemplateMatchMode.CCOEFF_NORMED)
        var maxValuePoint = (0, 0, NSNumber(value: 0))
        for y in 0 ..< Int(resultMat.size().height) {
            for x in 0 ..< Int(resultMat.size().width) {
                let v = resultMat.floatValue(at: CGPoint.init(x: x, y: y))
                if v.floatValue > maxValuePoint.2.floatValue {
                    maxValuePoint = (x, y, v)
                }
            }
        }
        if maxValuePoint.2 == 0 {
            return nil
        }
        return CGPoint(x: maxValuePoint.0, y: maxValuePoint.1)
    }
    
    func card(atPatternPoint point: CGPoint) -> (CardDataModel?, Bool) {
        let xIndex = Int(point.x) / Int(_configuration.patternRealWidth)
        let yIndex = Int(point.y) / Int(_configuration.patternRealHeight)
        return (_cards[yIndex], xIndex == 1 ? true : false)
    }
    
}
