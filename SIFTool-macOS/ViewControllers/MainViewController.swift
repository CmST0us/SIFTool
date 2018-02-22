//
//  MainViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/22.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa
import SDWebImage

class MainViewController: NSViewController {

    @IBOutlet weak var cardTableView: NSTableView!
    
    @IBOutlet weak var logTextView: NSTextView!
    
    @IBOutlet weak var requestActivitor: NSProgressIndicator!
    
    @IBOutlet weak var apiUrlTextField: NSTextField!

    @IBOutlet weak var selectScreenShootPopUpButton: NSPopUpButton!
    
    var cardsJsonData: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.string = ""
        Logger.shared.delegate = self
        ApiHelper.shared.taskWaitTime = 15
    }
    
    @IBAction func process(_ sender: Any) {
        
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
                    
                } catch {
                    Logger.shared.output(error.localizedDescription, .error)
        
                }
            }
            DispatchQueue.main.async {
                self.requestActivitor.stopAnimation(nil)
            }
            Logger.shared.output("load cards ok")
        }
        
        //get card round image
        
    }
}

extension MainViewController: LoggerProtocol {
    func log(msg: String) {
        DispatchQueue.main.async {
            self.logTextView.string += msg
        }
    }
}
