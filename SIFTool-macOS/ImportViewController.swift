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
            do {
                if SIFCacheHelper.shared.cards.count == 0 {
                    try SIFCacheHelper.shared.cacheCards(process: { (current, total) in
                        Logger.shared.output("cache cards (\(String(current))/\(String(total)))")
                    })
                }
                Logger.shared.output("load cards ok")
                //get card round image
                //check cache
                Logger.shared.output("load round image")
                if let im = NSImage.init(contentsOfFile: NSTemporaryDirectory() + "/pattern.png") {
                    self.detector = SIFRoundIconDetector(withCards: SIFCacheHelper.shared.cards, configuration: self.config, roundCardImagePattern: im.mat)
                    Logger.shared.output("use pattern cache")
                    DispatchQueue.main.async {
                        self.requestActivitor.stopAnimation(nil)
                    }
                    return
                } else {
                    self.detector = SIFRoundIconDetector(withCards: SIFCacheHelper.shared.cards, configuration: self.config)
                }

                for roundCardUrl in self.detector.roundCardUrls {
                    var image1: NSImage? = nil
                    var image2: NSImage? = nil
                    
                    if let u1 = roundCardUrl.1 {
                        image1 = SIFCacheHelper.shared.image(withUrl: u1)
                    }
                    
                    if let u2 = roundCardUrl.2 {
                        image2 = SIFCacheHelper.shared.image(withUrl: u2)
                    }
                    self.detector.makeRoundCardImagePattern(cardId: roundCardUrl.0, images: (image1?.mat, image2?.mat))
                }
            
                self.detector.saveRoundCardImagePattern(toPath: NSTemporaryDirectory().appendingPathComponent("pattern.png"))
                Logger.shared.output("make all round card pattern ok")
                DispatchQueue.main.async {
                    self.requestActivitor.stopAnimation(nil)
                }
            } catch {
                Logger.shared.output(error.localizedDescription)
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

