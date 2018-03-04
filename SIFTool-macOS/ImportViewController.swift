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
    
    var screenshots: [NSImage] = []
    
    var cards: [(UserCardDataModel, NSImage)] = []
    
    struct NotificationName {
        static let importOk = "ImportCardViewController.NotificationName.importOk"
    }
    
    
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
        p.beginSheetModal(for: NSApplication.shared.keyWindow!) { (result) in
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
            self.screenshots.removeAll()
            openSelectFilePlane { (urls) in
                guard urls != nil else {
                    return
                }
                for url in urls! {
                    Logger.shared.output("选择文件\(url.absoluteString)")
                    let image = NSImage.init(contentsOf: url)
                    self.screenshots.append(image!)
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
            for screenshot in self.screenshots {
                let mat = screenshot.mat
                let results = self.detector.search(screenshot: mat)
                for result in results.1 {
                    let roi = mat.roi(at: results.0).roi(at: result)
                    let roiClone = roi.clone()
                    let template = self.detector.makeTemplateImagePattern(image: roi)
                    if let point = self.detector.match(image: template) {
                        let card = self.detector.card(atPatternPoint: point)
                        if card == nil {
                            continue
                        }
                        
                        let userCard = UserCardDataModel.init()
                        userCard.cardId = card!.0.id.intValue
                        userCard.idolized = card!.1
                        userCard.isImport = true
                        userCard.isKizunaMax = true
                        userCard.user = UserDefaults.init().value(forKey: "user") as? String ?? "default"
                        self.cards.append((userCard, NSImage.init(cvMat: roiClone)))
                            Logger.shared.output("find card, id: \(String(card!.0.id.intValue))")
                    }
                }
            }
            DispatchQueue.main.async {
                self.requestActivitor.stopAnimation(nil)
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
                if let im = NSImage.init(contentsOfFile: SIFCacheHelper.shared.cacheDirectory.appendingPathComponent("pattern.png")) {
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
            
                self.detector.saveRoundCardImagePattern(toPath: SIFCacheHelper.shared.cacheDirectory.appendingPathComponent("pattern.png"))
                Logger.shared.output("make all round card pattern ok")
                DispatchQueue.main.async {
                    self.requestActivitor.stopAnimation(nil)
                }
            } catch {
                Logger.shared.output(error.localizedDescription)
            }
        }
        
    }
    @IBAction func refreshCardsData(_ sender: Any) {
        do {
            self.cards.removeAll()
            try SIFCacheHelper.shared.deleteCardsCache()
            DispatchQueue.global().async {
                do {
                    try SIFCacheHelper.shared.cacheCards(process: nil)
                } catch {
                    Logger.shared.output(error.localizedDescription)
                }
            }
        } catch {
            Logger.shared.output(error.localizedDescription)
        }
        
    }
    
    @IBAction func deletePatternCache(_ sender: Any) {
        do {
            self.cards.removeAll()
            try SIFCacheHelper.shared.deleteMatchPattern()
        } catch {
            Logger.shared.output(error.localizedDescription)
        }
    }
    @IBAction func importSelectedCard(_ sender: Any) {
        for card in cards {
            UserCardStorageHelper.shared.addUserCard(card: card.0)
        }
        Logger.shared.output("import OK")
        NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.importOk), object: nil)
    }
    @IBAction func allCardWithIdolized(_ sender: Any) {
        for i in cards {
            i.0.idolized = true
        }
        self.cardTableView.reloadData()
    }
    @IBAction func allCardWithoutIdolized(_ sender: Any) {
        for i in cards {
            i.0.idolized = false
        }
        self.cardTableView.reloadData()
    }

    @IBAction func allCardWillImport(_ sender: Any) {
        for i in cards {
            i.0.isImport = true
        }
        self.cardTableView.reloadData()
    }
    @IBAction func allCardWillNotImport(_ sender: Any) {
        for i in cards {
            i.0.isImport = false
        }
        self.cardTableView.reloadData()
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
        switch tableColumn!.identifier.rawValue {
        case "import":
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("importCell"), owner: self) as! CheckBoxTableCellView
            let model = cards[row]
            cell.on = model.0.isImport
            return cell
            
        case "card":
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("cardCell"), owner: self) as! CardTableCellView
            let model = cards[row]
            cell.setupCell(withDataModel: model.0)
            cell.cardImageView.image = model.1
            return cell
            
        case "idolized":
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("idolizedCell"), owner: self) as! CheckBoxTableCellView
            let model = cards[row]
            cell.on = model.0.idolized
            return cell
        case "kizuna":
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("kizunaCell"), owner: self) as! CheckBoxTableCellView
            let model = cards[row]
            cell.on = model.0.isKizunaMax
            return cell
        default:
            break
        }
        
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cards.count
    }
}

