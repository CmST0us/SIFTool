//
//  CardTableCellView.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/23.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class CardTableCellView: NSTableCellView {

    @IBOutlet weak var selectButton: NSButton!
    
    @IBOutlet weak var cardNameLabel: NSTextField!
    @IBOutlet weak var cardImageView: NSImageView!
    var cardDataModel: CardDataModel!
    
    func setupCell(withDataModel model: CardDataModel) {
        self.cardDataModel = model
        self.cardNameLabel.stringValue = "id: \(String(cardDataModel.id)) name: \(cardDataModel.idol.name!)"
    }
    
}
