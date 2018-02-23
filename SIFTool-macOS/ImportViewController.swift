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

class ImportCardViewController: NSViewController {

    @IBOutlet weak var cardTableView: NSTableView!
    
    @IBOutlet weak var logTextView: NSTextView!
    
    @IBOutlet weak var requestActivitor: NSProgressIndicator!
    
    @IBOutlet weak var apiUrlTextField: NSTextField!

    @IBOutlet weak var selectScreenShootPopUpButton: NSPopUpButton!
    
    var cardsJsonData: Data!
    
    var detector: SIFRoundIconDetector!
    
    var screenShoots: [NSImage] = []
    
    var cards: [(CardDataModel, CVMat, Bool)] = []
    
    lazy var config: SIFRoundIconDetectorConfiguration = {
        return SIFRoundIconDetectorConfiguration.defaultRoundIconConfiguration(radio: 0.3)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.string = ""
        Logger.shared.delegate = self 
        ApiHelper.shared.taskWaitTime = 15
        self.cardTableView.dataSource = self
        self.cardTableView.delegate = self
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
        self.cards.removeAll(keepingCapacity: true)
        requestActivitor.startAnimation(nil)
        DispatchQueue.global().async {
            for screenShoot in self.screenShoots {
                let mat = screenShoot.mat
                let results = self.detector.search(screenShoot: mat)
                for result in results {
                    let roi = mat.roi(at: result)
                    let roiClone = roi.clone()
                    let template = self.detector.makeTemplateImagePattern(image: roi)
                    if let point = self.detector.match(image: template) {
                        let card = self.detector.card(atPatternPoint: point)
                        if card == nil {
                            continue
                        }
                        self.cards.append((card!.0, roiClone, card!.1))
                        Logger.shared.output("find card \(String(card!.0.id))")
                    }
                }
            }
            DispatchQueue.main.async {
                self.requestActivitor.stopAnimation(nil)
                self.screenShoots.removeAll()
                self.cardTableView.reloadData()
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
                    self.cardsJsonData = jsonData
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
                        image1 = SIFImageCacheHelper.shared.image(withUrl: u1)
                    }
                    
                    if let u2 = roundCardUrl.2 {
                        image2 = SIFImageCacheHelper.shared.image(withUrl: u2)
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

extension ImportCardViewController: LoggerProtocol {
    func log(msg: String) {
        DispatchQueue.main.async {
            self.logTextView.string = msg + self.logTextView.string
        }
    }
}

extension ImportCardViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("cell"), owner: self) as! CardTableCellView
        let model = cards[row]
        cell.setupCell(withDataModel: model.0)
        cell.cardImageView.image = NSImage.init(cvMat: model.1)
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cards.count
    }
}

