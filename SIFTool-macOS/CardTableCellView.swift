//
//  CardTableCellView.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/23.
//  Copyright © 2018年 eki. All rights reserved.
//

class CardTableCellView: NSTableCellView {
    
//    struct NotificationName {
//        static let selectIdolizedButton = "selectIdolizedButton"
//        static let selectImportButton = "selectImportButton"
//    }
    
    @IBOutlet weak var cardNameLabel: NSTextField!
    @IBOutlet weak var cardImageView: NSImageView!
    @IBOutlet weak var rarityLabel: NSTextField!
    
//    var isImport: Bool {
//        return importButton.state == NSControl.StateValue.on
//    }
//
//    var isIdolized: Bool {
//        return idolizedButton.state == NSControl.StateValue.on
//    }
    
    func setupCell(withDataModel model: UserCardDataModel) {
        let cardCache = SIFCacheHelper.shared.cards[model.cardId]!
        self.cardNameLabel.stringValue = cardCache.idol.japaneseName ?? cardCache.idol.name
        self.rarityLabel.stringValue = cardCache.rarity
    }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onSelectImportButtonNotification), name: NSNotification.Name(rawValue: NotificationName.selectImportButton), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onSelectIdolizedButtonNotification), name: NSNotification.Name(rawValue: NotificationName.selectIdolizedButton), object: nil)
//    }
    
//    @objc
//    func onSelectImportButtonNotification(_ notification: NSNotification?) {
//        if let v = notification?.userInfo?["state"] as? Bool {
//            if v {
//                self.importButton.state = NSControl.StateValue.on
//            } else {
//                self.importButton.state = NSControl.StateValue.off
//            }
//        }
//    }
//
//    @objc
//    func onSelectIdolizedButtonNotification(_ notification: NSNotification?) {
//        if let v = notification?.userInfo?["state"] as? Bool {
//            if v {
//                self.idolizedButton.state = NSControl.StateValue.on
//            } else {
//                self.idolizedButton.state = NSControl.StateValue.off
//            }
//        }
//    }
}
