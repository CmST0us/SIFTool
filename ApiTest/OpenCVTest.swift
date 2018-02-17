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
    
    func testSomeThing() {
        let mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test.png")
        var output = OpenCVBridgeSwiftHelper.sharedInstance().gaussianBlur(withImage: mat, kernelSize: NSSize.init(width: 3, height: 3), sigmaX: 0, sigmaY: 0, borderType: .default)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(output, fileName: "\(sp)/dump1.png")
        output = OpenCVBridgeSwiftHelper.sharedInstance().canny(withImage: output, lowThreshold: 200, highThreshold: 300);
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(output, fileName: "\(sp)/dump2.png")
    }
    
    func testContours() {
        var mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "\(sp)/test1.png")
        mat = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: mat, targetColor: .bgr2Gray)
        mat = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: mat, thresh: 230, maxValue: 255, type: .binary)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(mat, fileName: "\(sp)/dump1.png")
        let output = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: mat, mode: .ccomp, method: .none, offsetPoint: CGPoint.zero)
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(output, fileName: "\(sp)/dump2.png")
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
