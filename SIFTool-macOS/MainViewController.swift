//
//  MainViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/24.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    lazy var userCards: [(CardDataModel, Bool)] = {
        return SIFCacheHelper.shared.cards.map({ (k, v) -> (CardDataModel, Bool) in
            return (v, true)
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
    }
    
}


extension MainViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cardCollectionViewItem = CardCollectionViewItem.storyboardResources
        let model = userCards[indexPath.item]
        cardCollectionViewItem.setupView(withModel: model.0, idolized: model.1)
        return cardCollectionViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return userCards.count
    }
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}
