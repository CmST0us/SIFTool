
//
//  OpenCVTest.swift
//  ApiTest
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//

import XCTest

class OpenCVTest: XCTestCase {

    let sp = "/Users/cmst0us/Downloads"
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReadImage() {
        let _ = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        Logger.shared.console("read ok")
    }
    
    func testGaussionBlur() {
        let mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        Logger.shared.console("read ok")
        
        let gaussionBlueImage = OpenCVBridgeSwiftHelper.sharedInstance().gaussianBlur(withImage: mat, kernelSize: NSSize.init(width: 5, height: 5), sigmaX: 0, sigmaY: 0, borderType: .default)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(gaussionBlueImage, fileName: "\(sp)/dump.png")
    }
    
    func testCanny() {
        let mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        let cannyImage = OpenCVBridgeSwiftHelper.sharedInstance().canny(withImage: mat, lowThreshold: 1, highThreshold: 2)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(cannyImage, fileName: "\(sp)/dump.png")
    }
    
    func testBin() {
        let mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        var gray = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: mat, targetColor: .bgr2Gray)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(gray, fileName: "\(sp)/dump1.png")
        gray = OpenCVBridgeSwiftHelper.sharedInstance().gaussianBlur(withImage: gray, kernelSize: NSSize.init(width: 5, height: 5), sigmaX: 5, sigmaY: 5, borderType: .default)
        let bin = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: gray, thresh: 230, maxValue: 255, type: .binary)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(bin, fileName: "\(sp)/dump2.png")
        let canny = OpenCVBridgeSwiftHelper.sharedInstance().canny(withImage: bin, lowThreshold: 100, highThreshold: 200)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(canny, fileName: "\(sp)/dump3.png")
    }
    
    func testContours() {
        var mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test1.png")
        mat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: mat, targetColor: .bgr2Gray)
        
        mat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: mat, thresh: 254, maxValue: 255, type: .binary_Inv)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(mat, fileName: "\(sp)/dump1.png")
        let output = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: mat, mode: .external, method: .none, offsetPoint: CGPoint.zero) as! [[NSValue]]
        for ps in output {
            let rect = ps.contoursRect()
            let aspectRadio = Double(rect.size.width / rect.size.height)
            let aspectRadioThresh = 0.2
            if abs(aspectRadio - 1) < aspectRadioThresh {
                OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: mat, rect: rect, r: 255, g: 255, b: 255)
            }
        }
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(mat, fileName: "\(sp)/dump2.png")
    }
    
    func testMorph() {
        var mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        mat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: mat, targetColor: .bgr2Gray)
        mat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: mat, thresh: 250, maxValue: 255, type: .binary_Inv)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(mat, fileName: "\(sp)/dump1.png")
        mat = OpenCVBridgeSwiftHelper.sharedInstance().morphologyEx(withImage: mat, operation: .open, elementSharp: .rect, elementSize: CGSize.init(width: 7, height: 7), elementPoint: CGPoint.init(x: 3, y: 3))
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(mat, fileName: "\(sp)/dump2.png")
    }
    
    //首先二值化，找轮廓，切图
    func testMethod1() {
        var mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        let cloneMat = mat.clone()
        var corpMat = mat.clone()
        
        mat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: mat, targetColor: .bgr2Gray)
        
        mat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: mat, thresh: 254, maxValue: 255, type: .binary_Inv)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(mat, fileName: "\(sp)/dump1.png")
        
        let output = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: mat, mode: .external, method: .none, offsetPoint: CGPoint.zero) as! [[NSValue]]
        
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var maxXPlusWeight = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        var maxYPlusHeight = CGFloat.leastNormalMagnitude
        
        let empty = OpenCVBridgeSwiftHelper.sharedInstance().emptyImage(with: cloneMat.size(), channel: 3)
        var i = 0
        for contours in output {
            // filter
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
            
            minX = Swift.min(minX, rect.origin.x)
            maxX = Swift.max(maxX, rect.origin.x)
            minY = Swift.min(minY, rect.origin.y)
            maxY = Swift.max(maxY, rect.origin.y)
            maxXPlusWeight = Swift.max(maxXPlusWeight, maxX + rect.size.width)
            maxYPlusHeight = Swift.max(maxYPlusHeight, maxY + rect.size.height)
            OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: empty, rect: rect, r: 255, g: 255, b: 255)
            let cutMat = OpenCVBridgeSwiftHelper.sharedInstance().crop(withImage: cloneMat, by: rect)
            OpenCVBridgeSwiftHelper.sharedInstance().saveImage(cutMat, fileName: "\(sp)/dumps/\(i).png")
            i += 1
        }
        
        let groupRect = CGRect(x: minX, y: minY, width: maxXPlusWeight - minX, height: maxYPlusHeight - minY)
        OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: empty, rect: groupRect, r: 255, g: 0, b: 0)
        
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(empty, fileName: "\(sp)/dump2.png")
        
        
    }
    
    func testMatchTemple() {
        do {
            let image = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
            let o = image.clone();
            let template = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/template.png")
            let resultMat = OpenCVBridgeSwiftHelper.sharedInstance().matchTemplate(withImage: image, template: template, method: CVBridgeTemplateMatchMode.CCOEFF_NORMED)
            var maxPoint = (0, 0, NSNumber.init(value: 0))
            for y in 0 ..< Int(resultMat.size().height) {
                for x in 0 ..< Int(resultMat.size().width) {
                    let p = CGPoint.init(x: x, y: y)
                    let v = resultMat.floatValue(at: p)
                    if v.floatValue > maxPoint.2.floatValue {
                        maxPoint = (x, y, v)
                    }
                    if v.floatValue > 1 {
                        Logger.shared.console("bad value (> 0)")
                    }
                }
            }
            OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: o, rect: CGRect.init(x: CGFloat(maxPoint.0), y: CGFloat(maxPoint.1), width: template.size().width, height: template.size().height), r: 0, g: 255, b: 0)
            OpenCVBridgeSwiftHelper.sharedInstance().saveImage(o, fileName: "\(sp)/dump.png")
            
        }
        Logger.shared.console("check memory")
        sleep(5)
        Logger.shared.console("check memory")
    }
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
