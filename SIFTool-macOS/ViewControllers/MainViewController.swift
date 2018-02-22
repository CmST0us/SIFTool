//
//  MainViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/22.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa
import SDWebImage
import PromiseKit

class MainViewController: NSViewController {

    @IBOutlet weak var cardTableView: NSTableView!
    
    @IBOutlet weak var logTextView: NSTextView!
    
    @IBOutlet weak var requestActivitor: NSProgressIndicator!
    
    @IBOutlet weak var apiUrlTextField: NSTextField!

    @IBOutlet weak var selectScreenShootPopUpButton: NSPopUpButton!
    
    var cardsJsonData: Data!
    
    var detector: SIFRoundIconDetector!
    
    var screenShoots: [NSImage] = []
    
    var cards: [CardDataModel] = []
    
    lazy var config: SIFRoundIconDetectorConfiguration = {
        return SIFRoundIconDetectorConfiguration.defaultRoundIconConfiguration(radio: 0.3)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.string = ""
        Logger.shared.delegate = self
        ApiHelper.shared.taskWaitTime = 15
        
    }
    
    func openSelectFilePlane(completion: @escaping ([URL]?) -> Void) {
        let p = NSOpenPanel.init()
        p.canChooseFiles = true
        p.canChooseDirectories = false
        p.allowsMultipleSelection = true
        p.allowedFileTypes = ["png", "jpg", "PNG", "jpeg", "JPEG", "JPG"]
        p.beginSheetModal(for: NSApplication.shared.windows.first!) { (result) in
            if result == NSApplication.ModalResponse.OK {
                completion(p.urls)
            } else {
                completion(nil)
            }
        }
    }
    @IBAction func selectScreenShootAction(_ sender: NSPopUpButton) {
        switch sender.indexOfSelectedItem {
        case 0:
            openSelectFilePlane { (urls) in
                guard urls != nil else {
                    return
                }
                for url in urls! {
                    Logger.shared.output("选择文件\(url.absoluteString)")
                    
                    let image = NSImage.init(contentsOf: url)
                    self.screenShoots.append(image!)
                }
            }
        default:
            break
        }
    }
    
    @IBAction func process(_ sender: Any) {
        self.cards.removeAll()
        requestActivitor.startAnimation(nil)
        DispatchQueue.global().async {
            for screenShoot in self.screenShoots {
                let mat = screenShoot.mat
                let results = self.detector.search(screenShoot: mat)
                for result in results {
                    let template = self.detector.makeTemplateImagePattern(image: mat.roi(at: result))
                    if let point = self.detector.match(image: template) {
                        let cards = self.detector.card(atPatternPoint: point)
                        if let c = cards.0 {
                            self.cards.append(c)
                            Logger.shared.output("find card\(String(c.id))")
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.requestActivitor.stopAnimation(nil)
            }
        }
    }
    
    @IBAction func requstApi(_ sender: Any) {
        requestActivitor.startAnimation(nil)
        DispatchQueue.global().async {
            let tempDirectoryPath = NSTemporaryDirectory() as NSString
            let cardsJsonDataPath = tempDirectoryPath.appendingPathComponent("cards.json") as String
            if let data = NSData(contentsOfFile: cardsJsonDataPath) {
                self.cardsJsonData = data as Data
                Logger.shared.output("read cache ok")
            } else {
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
                        }
                        Logger.shared.output("page \(page) download ok")
                        page += 1
                        
                    }
                    Logger.shared.output("all page download ok")
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: results, options: [.prettyPrinted])
                    try jsonData.write(to: URL.init(fileURLWithPath: cardsJsonDataPath))
                } catch let e as ApiRequestError {
                    Logger.shared.output(e.message, .error)
                    return
                } catch {
                    Logger.shared.output(error.localizedDescription, .error)
                    return
                }
            }
            
            Logger.shared.output("load cards ok")
            //get card round image
            //check cache
            Logger.shared.output("load round image")
            if let result = DataModelHelper.shared.array(withJsonData: self.cardsJsonData) as? [Dictionary<String, Any>]{
                let cards = result.map({ (card) -> CardDataModel in
                    let c = CardDataModel(withDictionary: card)
                    return c
                })
                if let im = NSImage.init(contentsOfFile: NSTemporaryDirectory() + "/pattern.png") {
                    self.detector = SIFRoundIconDetector(withCards: cards, configuration: self.config, roundCardImagePattern: im.mat)
                    Logger.shared.output("use pattern cache")
                    DispatchQueue.main.async {
                        self.requestActivitor.stopAnimation(nil)
                    }
                    return
                } else {
                    self.detector = SIFRoundIconDetector(withCards: cards, configuration: self.config)
                }
                
                for roundCardUrl in self.detector.roundCardUrls {
                    var image1: NSImage? = nil
                    var image2: NSImage? = nil
                    
                    if let u1 = roundCardUrl.1 {
                        let fileName = u1.lastPathComponent
                        let tempDir = NSTemporaryDirectory() as NSString
                        let filePath = tempDir.appendingPathComponent(fileName)
                        if let cacheData = NSData.init(contentsOfFile: filePath) {
                            image1 = NSImage(data: cacheData as Data)
                        } else {
                            if let data = NSData.init(contentsOf: u1) {
                                try! data.write(toFile: filePath, options: NSData.WritingOptions.atomicWrite)
                                image1 = NSImage.init(data: data as Data)
                                Logger.shared.output("\(fileName) has cached")
                            }
                        }
                    }
                    
                    if let u2 = roundCardUrl.2 {
                        let fileName = u2.lastPathComponent
                        let tempDir = NSTemporaryDirectory() as NSString
                        let filePath = tempDir.appendingPathComponent(fileName)
                        if let cacheData = NSData.init(contentsOfFile: filePath) {
                            image2 = NSImage(data: cacheData as Data)
                        } else {
                            if let data = NSData.init(contentsOf: u2) {
                                try! data.write(toFile: filePath, options: NSData.WritingOptions.atomicWrite)
                                image2 = NSImage.init(data: data as Data)
                                Logger.shared.output("\(fileName) has cached")
                            }
                        }
                    }
                    self.detector.makeRoundCardImagePattern(cardId: roundCardUrl.0, images: (image1?.mat, image2?.mat))
                }
                self.detector.saveRoundCardImagePattern(toPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("pattern.png"))
                Logger.shared.output("make all round card pattern ok")
                DispatchQueue.main.async {
                    self.requestActivitor.stopAnimation(nil)
                }
            }
        }
        
    }
}

extension MainViewController: LoggerProtocol {
    func log(msg: String) {
        DispatchQueue.main.async {
            self.logTextView.string = msg + self.logTextView.string
        }
    }
}

extension MainViewController: NSTableViewDataSource, NSTableViewDelegate {
    
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//
//    }
//
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return 0
//    }
}

