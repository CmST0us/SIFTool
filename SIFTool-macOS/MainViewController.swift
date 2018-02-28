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
    
    @IBOutlet weak var cardsInfoLabel: NSTextField!
    
    @IBOutlet weak var cardsFiltePredicateEditor: NSPredicateEditor!
    
    lazy var userCards: [UserCardDataModel] = {
        return UserCardStorageHelper.shared.fetchAllUserCard() ?? []
    }()
    
    lazy var filterUserCards: [UserCardDataModel] = []
    
    
    @IBAction func reloadData(_ sender: Any) {
        userCards = UserCardStorageHelper.shared.fetchAllUserCard() ?? []
        filterUserCards.removeAll()
        if self.cardsFiltePredicateEditor.numberOfRows > 0 {
            cardsInfoLabel.stringValue = "持有 \(String(filterUserCards.count)) 种卡"
        } else {
            cardsInfoLabel.stringValue = "持有 \(String(userCards.count)) 种卡"
        }
        
        self.userCardCollectionView.reloadData()
    }
    
    func filterData() {
        if self.cardsFiltePredicateEditor.numberOfRows > 0 {
            cardsInfoLabel.stringValue = "持有 \(String(filterUserCards.count)) 种卡"
        } else {
            cardsInfoLabel.stringValue = "持有 \(String(userCards.count)) 种卡"
        }
        self.userCardCollectionView.reloadData()
    }
    
    @IBAction func startFilter(_ sender: Any) {
        self.cardsFiltePredicateEditor.addRow(nil)
    }

    @IBAction func predicateEditorChange(_ sender: Any) {
        if self.cardsFiltePredicateEditor.numberOfRows == 0 {
            reloadData(self)
        }
        
        if let p = cardsFiltePredicateEditor.objectValue as? NSPredicate {
            filterUserCards = userCards.filter({ (model) -> Bool in
                let cardModel = SIFCacheHelper.shared.cards[model.cardId]
                let b = p.evaluate(with: cardModel)
                return b
            })
            
        }
        filterData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
        ApiHelper.shared.taskWaitTime = 15
        SIFCacheHelper.shared.cacheDirectory = "/Users/cmst0us/Downloads/round_card_images"
        cardsInfoLabel.stringValue = "持有 \(String(userCards.count)) 种卡"
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
        
        var dataModel = userCards
        if self.cardsFiltePredicateEditor.numberOfRows > 0 {
            dataModel = filterUserCards
        }
        let cardDataModel = SIFCacheHelper.shared.cards[dataModel[indexPath.item].cardId]
        let idolized = dataModel[indexPath.item].idolized
        cardCollectionViewItem.setupView(withModel: cardDataModel!, idolized: idolized)
        return cardCollectionViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.cardsFiltePredicateEditor.numberOfRows > 0 {
            return filterUserCards.count
        }
        return userCards.count
    }
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}

