//
//  SIFRoundIconDetector.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/20.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

#if iOS
    import UIKit
#elseif macOS
    import Cocoa
#endif

class SIFRoundIconDetector {
    #if macOS
        typealias UIImage = NSImage
    #endif
    
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
            
            guard pattern != nil && roi != nil else {
                return
            }
            
            roi!.fill(by: pattern!)
        }
        if let idolizedRoundCardImage = images.1 {
            let coordinates = patternCoordinates(index: cardId, idolize: true)
            let pattern = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(idolizedRoundCardImage, to: CGSize.init(width: _configuration.patternWidth, height: _configuration.patternHeight)).roi(at: _configuration.patternRealRect)
            
            let roi = _roundCardImagePattern.roi(at: CGRect.init(origin: CGPoint.init(x: coordinates.0, y: coordinates.1), size: _configuration.patternRealSize))
            guard pattern != nil && roi != nil else {
                return
            }
            roi!.fill(by: pattern!)
        }
    }
    
    func saveRoundCardImagePattern(toPath path: String) {
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(_roundCardImagePattern, fileName: path)
    }
    
    func makeTemplateImagePattern(image: CVMat) -> CVMat {
        let resizeImage = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(image, to: _configuration.patternSize)
        let roi = resizeImage.roi(at: _configuration.templateRealRect)
        guard roi != nil else {
            return resizeImage
        }
        return roi!
    }
    

    func search(screenshot: CVMat) -> (CGRect, [CGRect]) {
        
        let gaussianMat = OpenCVBridgeSwiftHelper.sharedInstance().gaussianBlur(withImage: screenshot, kernelSize: CGSize.init(width: 3, height: 1), sigmaX: 3, sigmaY: 3, borderType: CVBridgeBorderType.default)
        
        let grayMat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: gaussianMat, targetColor: CVBridgeColorCovertType.bgr2Gray)
        
        let binaryMat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: grayMat, thresh: 240, maxValue: 255, type: CVBridgeThresholdType.binary_Inv)
        let cloneMat = binaryMat.clone()
        let canny = OpenCVBridgeSwiftHelper.sharedInstance().canny(withImage: binaryMat, lowThreshold: 100, highThreshold: 200)
        
        var outputArray: [CGRect] = []
        var screenshotRoiRect: CGRect = CGRect(origin: CGPoint.init(x: 0, y: 0), size: screenshot.size())
        
        func isHorizonLine(line: (CGPoint, CGPoint)) -> Bool {
            if abs(line.0.x - line.1.x) < 0.001 {
                return false
            }
            if abs((line.1.y - line.0.y) / (line.1.x - line.0.x)) < 0.1 {
                return true
            }
            return false
        }
        
        func findContours(mat: CVMat, step: Int) -> CVMat {
            if step == 1 {
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
                    outputArray.append(rect)
                }
            }
            if step == 0 {
                var lines = OpenCVBridgeSwiftHelper.sharedInstance().houghlinesP(withImage: mat, rho: 1, theta: Double.pi / 180, threshold: 500, minLineLength: 200, maxLineGap: 30) as! [[NSValue]]
                
                lines = lines.filter { (value) -> Bool in
                    return isHorizonLine(line: (value[0].pointValue, value[1].pointValue))
                }
                
                lines.sort { (a, b) -> Bool in
                    return a[0].pointValue.y < b[0].pointValue.y
                }
                
                var diffArray: [(y1: Double, y2: Double, diff: Double)] = []
                
                for (index, item) in lines.enumerated() {
                    if index + 1 == lines.count {
                        break
                    }
                    
                    let y1 = item[0].pointValue.y
                    let y2 = lines[index + 1][0].pointValue.y
                    let diff = y2 - y1
                    
                    diffArray.append((y1: Double(y1), y2: Double(y2), diff: Double(diff)))
                }
                
                let maxDistanse = diffArray.max { (a, b) -> Bool in
                    return a.diff < b.diff
                }
                
                guard maxDistanse != nil  else {
                    return cloneMat
                }
                guard maxDistanse!.diff > 0.001 else {
                    return cloneMat
                }
                
                //use 11 pix y offset to cover some mess
                //use 4 pix x offset to cover some mess
                screenshotRoiRect = CGRect(x: 10, y: maxDistanse!.y1 + 11, width: Double(cloneMat.size().width) - 10, height: maxDistanse!.diff - 11)
                var roiMat =  cloneMat.roi(at: screenshotRoiRect) ?? cloneMat
                let originSize = roiMat.size()
                
                //draw a black rect to cover arrow
                let resizeHeight = (1920 * roiMat.size().height) / roiMat.size().width
                roiMat = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(roiMat, to: CGSize.init(width: 1920, height: resizeHeight))
                let arrowSize = CGSize.init(width: 114, height: 120)
                let arrowX = 1920 - 18 - arrowSize.width
                let arrowY = (resizeHeight - arrowSize.height) / 2
                let arrowRect = CGRect.init(x: arrowX, y: arrowY, width: arrowSize.width, height: arrowSize.height)
                OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: roiMat, rect: arrowRect, r: 0, g: 0, b: 0, thickness: -1)
                roiMat = OpenCVBridgeSwiftHelper.sharedInstance().resizeImage(roiMat, to: originSize)
                
                let centerY = roiMat.size().height / 2 - 1
                let centerBrokeArrowRect = CGRect.init(x: 0, y: centerY, width: roiMat.size().width, height: 2)
                
                //draw rect to fix arrow area
                OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: roiMat, rect: centerBrokeArrowRect, r: 0, g: 0, b: 0)
                
                return roiMat
            }
            return cloneMat
        }
        let _ = findContours(mat: findContours(mat: canny, step: 0), step: 1)
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

