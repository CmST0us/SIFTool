//
//  MainViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/24.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var userCardCollectionView: NSCollectionView!
    
    lazy var userCards: [UserCardDataModel] = {
        return UserCardStorageHelper.shared.fetchAllUserCard() ?? []
    }()
    
    @IBAction func reloadData(_ sender: Any) {
        userCards = UserCardStorageHelper.shared.fetchAllUserCard() ?? []
        self.userCardCollectionView.reloadData()
        Logger.shared.output("total count: \(String(userCards.count))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
        ApiHelper.shared.taskWaitTime = 15
        SIFCacheHelper.shared.cacheDirectory = "/Users/cmst0us/Downloads/round_card_images"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: NSNotification.Name.init(ImportCardViewController.NotificationName.importOk), object: nil)
    }
    
}


extension MainViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cardCollectionViewItem = CardCollectionViewItem.storyboardResources
        if !SIFCacheHelper.shared.isCardsCached {
            do {
                try SIFCacheHelper.shared.cacheCards(process: nil)
            } catch {
                Logger.shared.output(error.localizedDescription)
            }
            
        }
        let cardDataModel = SIFCacheHelper.shared.cards[userCards[indexPath.item].cardId]
        let idolized = userCards[indexPath.item].idolized
        cardCollectionViewItem.setupView(withModel: cardDataModel!, idolized: idolized)
        return cardCollectionViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return userCards.count
    }
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}
