//
//  ApiTest.swift
//  ApiTest
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import XCTest

class ApiHelperTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
        ApiHelper.shared.taskWaitTime = 15
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCardPage() {
        var page = 1
        var haveNext = true
        let results: NSMutableArray = NSMutableArray()
        do {
            while haveNext {
                let p = CardDataModel.requestPage(page, pageSize: 100)
                let data = try ApiHelper.shared.request(param: p)
                if DataModelHelper.shared.next(withJsonData: data) == nil {
                    haveNext = false
                }
                if let dicts = DataModelHelper.shared.resultsDictionaries(withJsonData: data) {
                    results.addObjects(from: dicts)
                    for dict in dicts {
                        let card = CardDataModel(withDictionary: dict)
                        Logger.shared.console(card.idol.japaneseName ?? card.idol.name)
                    }
                }
                Logger.shared.console("request page \(page)")
                page += 1
            }
            
            let d = try JSONSerialization.data(withJSONObject: results, options: [.prettyPrinted])
            try d.write(to: URL.init(fileURLWithPath: "/Users/cmst0us/Downloads/f.json"))
            Logger.shared.console("write file ok")
        } catch let e as ApiRequestError {
            Logger.shared.console(e.message, .error)
            XCTFail()
        } catch {
            Logger.shared.console(error.localizedDescription, .error)
            XCTFail()
        }
    }
    
//    func testDetectorMakeRoundCardPattern() {
//        if let data = NSData(contentsOfFile: "/Users/cmst0us/Downloads/f.json") as Data? {
//            if let results = DataModelHelper.shared.array(withJsonData: data) as? [Dictionary<String, Any>] {
//
//                let cards = results.map({ (dict) -> [Int: CardDataModel] in
//                    let card = CardDataModel(withDictionary: dict)
//                    return
//                })
//
//                let c = SIFRoundIconDetectorConfiguration.defaultRoundIconConfiguration
//                let detector = SIFRoundIconDetector(withCards: cards, configuration: c)
//                for u in detector.roundCardUrls {
//                    var image0: NSImage? = nil
//                    var image1: NSImage? = nil
//                    if let u0 = u.1 {
//                        image0 = NSImage.init(contentsOf: u0)
//                    }
//                    if let u1 = u.2 {
//                        image1 = NSImage.init(contentsOf: u1)
//                    }
//                    detector.makeRoundCardImagePattern(cardId: u.0, images: (image0?.mat, image1?.mat))
//                    let card = detector.card(atPatternPoint: CGPoint.init(x: 0, y: c.patternRealHeight))
//                    Logger.shared.console("\(card.0!.idol.name)")
//                }
//                Logger.shared.console("make Pattern finish")
//                return
//            }
//        }
//        XCTFail()
//    }
//
    
//    func testDetectorSearch() {
//        if let data = NSData(contentsOfFile: "/Users/cmst0us/Downloads/f.json") as Data? {
//            if let result = DataModelHelper.shared.array(withJsonData: data) as? [Dictionary<String, Any>] {
//                let cards = result.map({ (dict) -> CardDataModel in
//                    let card = CardDataModel(withDictionary: dict)
//                    return card
//                })
//                let config = SIFRoundIconDetectorConfiguration.defaultRoundIconConfiguration
//                let detector = SIFRoundIconDetector(withCards: cards, configuration: config)
//                for u in detector.roundCardUrls {
//                    var image0: NSImage? = nil
//                    var image1: NSImage? = nil
//                    if let u0 = u.1 {
//                        image0 = NSImage.init(contentsOf: u0)
//                    }
//                    if let u1 = u.2 {
//                        image1 = NSImage.init(contentsOf: u1)
//                    }
//                    detector.makeRoundCardImagePattern(cardId: u.0, images: (image0?.mat, image1?.mat))
//                    let screenShoot = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "/Users/cmst0us/Downloads/test.png")
//                    let cardRects = detector.search(screenShoot: screenShoot)
//                    for rect in cardRects {
//                        var roundCardImage = screenShoot.roi(at: rect)
//                        roundCardImage = detector.makeTemplateImagePattern(image: roundCardImage)
//                        let result = detector.match(image: roundCardImage)
//                        Logger.shared.console("\(result)")
//                    }
//                }
//            }
//        }
//    }

    func testImageRead() {
        let image = NSImage.init(contentsOfFile: "/Users/cmst0us/Downloads/round.png")
//        let mat = OpenCVBridgeSwiftHelper.sharedInstance().readImage(withNamePath: "/Users/cmst0us/Downloads/round.png")
        OpenCVBridgeSwiftHelper.sharedInstance().saveImage(image!.mat, fileName: "/Users/cmst0us/Downloads/roundMatDump.png")
    }
    func testIdolPage() {
        var page = 1
        var haveNext = true
        let p = IdolDataModel.requestPage(1, pageSize: 10)
        do {
            let data = try ApiHelper.shared.request(param: p)
            if let dicts = DataModelHelper.shared.resultsDictionaries(withJsonData: data) {
                for dict in dicts {
                    let idol = IdolDataModel(withDictionary: dict)
                    Logger.shared.console(idol.name, .info)
                }
                return
            }
        } catch let e as ApiRequestError{
            Logger.shared.console(e.message, .error)
        } catch {
            Logger.shared.console(error.localizedDescription, .error)
        }
        XCTFail()
    }
    
    func testIdolNamePage() {
        let p = IdolDataModel.requestIdol(withEnglishName: "Kunikida Hanamaru")
        do {
            let data = try ApiHelper.shared.request(param: p)
            if let dict = DataModelHelper.shared.dictionary(withJsonData: data) {
                let idol = IdolDataModel(withDictionary: dict)
                Logger.shared.console(idol.summary ?? "no summary")
            }
            return
        } catch {
            Logger.shared.console(error.localizedDescription, .error)
        }
        XCTFail()
    }
    
    func testCardids() {
        let p = CardDataModel.requestIds()
        do {
            let data = try ApiHelper.shared.request(param: p)
            if let r = DataModelHelper.shared.array(withJsonData: data) as? [Int] {
                let a = NSArray(array: r)
                Logger.shared.console(a.componentsJoined(by: ", "))
            }
            return
        } catch {
            Logger.shared.console(error.localizedDescription)
        }
        XCTFail()
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
