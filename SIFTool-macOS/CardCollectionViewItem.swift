//
//  CardCollectionViewItem.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/24.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class CardCollectionViewItem: NSCollectionViewItem {

    
    @IBOutlet weak var cardImageView: NSImageView!
    @IBOutlet weak var rarityLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    static var storyboardResources: CardCollectionViewItem {
        return NSStoryboard.init(name: NSStoryboard.Name.init("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("CardCollectionViewItem")) as! CardCollectionViewItem
    }
}
