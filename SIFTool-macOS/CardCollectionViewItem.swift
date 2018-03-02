//
//  CardCollectionViewItem.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/24.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class CardCollectionViewItem: NSCollectionViewItem {

    
    @IBOutlet weak var coolScoreLabel: NSTextField!
    
    
    @IBOutlet weak var smileScoreLabel: NSTextField!
    @IBOutlet weak var pureScoreLabel: NSTextField!
    @IBOutlet weak var cardImageView: NSImageView!
    @IBOutlet weak var rarityLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var idolizedLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    func setupView(withModel model: CardDataModel, idolized: Bool) {
        cardImageView.image = SIFCacheHelper.shared.image(withUrl: URL(string: (idolized ? model.roundCardIdolizedImage : model.roundCardImage) ?? ""))
        rarityLabel.stringValue = model.rarity
        nameLabel.stringValue = (model.idol.japaneseName ?? model.idol.name) + "(\(String(model.id.intValue)))"
        idolizedLabel.stringValue = idolized ? "已觉醒" : "未觉醒"
        coolScoreLabel.stringValue = "Cool:\(String(model.statisticsCool(idolized: idolized)?.intValue ?? -1))"
        pureScoreLabel.stringValue = "Pure:\(String(model.statisticsPure(idolized: idolized)?.intValue ?? -1))"
        smileScoreLabel.stringValue = "Smile:\(String(model.statisticsSmile(idolized: idolized)?.intValue ?? -1))"
    }
    
    static var storyboardResources: CardCollectionViewItem {
        return NSStoryboard.init(name: NSStoryboard.Name.init("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("CardCollectionViewItem")) as! CardCollectionViewItem
    }
}
