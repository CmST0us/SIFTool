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
    private var _cards: [Int: CardDataModel] = [:]
    private var _roundCardImagePattern: CVMat!
    private var _configuration: SIFRoundIconDetectorConfiguration
    
    init(withCards cards: [Int: CardDataModel], configuration: SIFRoundIconDetectorConfiguration, roundCardImagePattern: CVMat? = nil) {
        _cards = cards
        _configuration = configuration
        
        let cardCount = _cards.keys.max { (a, b) -> Bool in
            return a < b
        }
        
        var patternSize = _configuration.patternRealSize
        patternSize.height = patternSize.height * CGFloat(cardCount! + 1)
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
            u.append((card.id.intValue, roundCardImageUrl, roundCardIdolizedImageUrl))
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
    

    func search(screenshot: CVMat) -> (CGRect, [CGRect]) {
        let grayMat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: screenshot, targetColor: CVBridgeColorCovertType.bgr2Gray)
        let binrayMat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: grayMat, thresh: 220.0, maxValue: 255, type: CVBridgeThresholdType.binary_Inv)
        var outputArray: [CGRect] = []
        var screenshotRoiRect: CGRect!
        func findContours(mat: CVMat, step: Int) -> CVMat {
            let cloneMat = mat.clone()
            let output = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: mat, mode: CVBridgeRetrievalMode.external, method: CVBridgeApproximationMode.none, offsetPoint: CGPoint.zero) as! [[NSValue]]
            
            var minX = CGFloat.greatestFiniteMagnitude
            var maxX = CGFloat.leastNormalMagnitude
            var maxXPlusWeight = CGFloat.leastNormalMagnitude
            var minY = CGFloat.greatestFiniteMagnitude
            var maxY = CGFloat.leastNormalMagnitude
            var maxYPlusHeight = CGFloat.leastNormalMagnitude
            var maxWidth = CGFloat.leastNormalMagnitude
            var maxHeight = CGFloat.leastNormalMagnitude
            for contours in output {
                let rect = contours.contoursRect()
                let area = rect.size.width * rect.size.height
                if area < 80 * 80 {
                    continue
                }
                let aspectRadio = Double(rect.size.width / rect.size.height)
                let aspectRadioThresh = 0.2
                if abs(aspectRadio - 1) > aspectRadioThresh {
                    continue
                }
                
                minX = Swift.min(minX, rect.origin.x)
                maxX = Swift.max(maxX, rect.origin.x)
                minY = Swift.min(minY, rect.origin.y)
                maxY = Swift.max(maxY, rect.origin.y)
                maxWidth = Swift.max(maxWidth, rect.size.width)
                maxHeight = Swift.max(maxHeight, rect.size.height)
                
                maxXPlusWeight = Swift.max(maxXPlusWeight, maxWidth + maxX)
                maxYPlusHeight = Swift.max(maxYPlusHeight, maxHeight + maxY)
                if step == 1{
                    outputArray.append(rect)
                }
            }
            if step == 0 {
                var w = maxXPlusWeight
                var h = maxYPlusHeight
                if w > cloneMat.size().width {
                    w = cloneMat.size().width - minX - 1
                } else {
                    w = maxXPlusWeight - minX
                }
                
                if h > cloneMat.size().height {
                    h = cloneMat.size().height - minY - 1
                } else {
                    h = maxYPlusHeight - minY
                }
                // user 8 pix offset to avoid button layout in 1080p screenshot
                screenshotRoiRect = CGRect.init(x: minX, y: minY + 8, width: w, height: h - 8)
                let roiMat = cloneMat.roi(at: screenshotRoiRect)
                let centerY = roiMat.size().height / 2 - 1
                let centerBrokeArrowRect = CGRect.init(x: 0, y: centerY, width: roiMat.size().width, height: 2)
                OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: roiMat, rect: centerBrokeArrowRect, r: 0, g: 0, b: 0)
                return roiMat
                
            }
            return cloneMat
        }
        let _ = findContours(mat: findContours(mat: binrayMat, step: 0), step: 1)
        return (screenshotRoiRect, outputArray)
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
