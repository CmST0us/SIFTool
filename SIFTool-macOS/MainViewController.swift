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
    
    @IBOutlet weak var sortAttributeSegmentedControl: NSSegmentedControl!
    
    @IBOutlet weak var sortRankSegmentedControl: NSSegmentedControl!
    
    @IBOutlet weak var sortMethodSegmentedControl: NSSegmentedControl!
    
    private lazy var userCards: [UserCardDataModel] = {
        return UserCardStorageHelper.shared.fetchAllUserCard() ?? []
    }()
    
    private lazy var filterUserCards: [UserCardDataModel] = []
    
    var collectionViewDataModel: [UserCardDataModel] {
        if self.cardsFiltePredicateEditor.numberOfRows > 0 {
            return filterUserCards
        }
        return userCards
    }
    
    func sortDataModel(dataModel: inout [UserCardDataModel]) {
        let type = self.sortMethodSegmentedControl.selectedSegment
        if type == 2 {
            reloadData(self)
            return
        }
        
        dataModel.sort { (a, b) -> Bool in
            let aCard = SIFCacheHelper.shared.cards[a.cardId]!
            let bCard = SIFCacheHelper.shared.cards[b.cardId]!
            
            let aSortArray = [
                [aCard.minimumStatisticsCool, aCard.minimumStatisticsPure, aCard.minimumStatisticsSmile, aCard.minimumStatisticsMax],
                [aCard.nonIdolizedMaximumStatisticsCool, aCard.nonIdolizedMaximumStatisticsPure, aCard.nonIdolizedMaximumStatisticsSmile, aCard.nonIdolizedMaximumStatisticsMax],
                [aCard.idolizedMaximumStatisticsCool, aCard.idolizedMaximumStatisticsPure, aCard.idolizedMaximumStatisticsSmile, aCard.idolizedMaximumStatisticsMax]
            ]
            
            let bSortArray = [
                [bCard.minimumStatisticsCool, bCard.minimumStatisticsPure, bCard.minimumStatisticsSmile, bCard.minimumStatisticsMax],
                [bCard.nonIdolizedMaximumStatisticsCool, bCard.nonIdolizedMaximumStatisticsPure, bCard.nonIdolizedMaximumStatisticsSmile, bCard.nonIdolizedMaximumStatisticsMax],
                [bCard.idolizedMaximumStatisticsCool, bCard.idolizedMaximumStatisticsPure, bCard.idolizedMaximumStatisticsSmile, bCard.idolizedMaximumStatisticsMax]
            ]
            
            let attributeSegmentedIndex = self.sortAttributeSegmentedControl.selectedSegment
            let rankSegmentedIndex = self.sortRankSegmentedControl.selectedSegment
            
            
            let sortScoreA = aSortArray[rankSegmentedIndex][attributeSegmentedIndex]?.intValue ?? 0
            let sortScoreB = bSortArray[rankSegmentedIndex][attributeSegmentedIndex]?.intValue ?? 0
            
            if type == 0 {
                return sortScoreA > sortScoreB
            }
            return sortScoreA < sortScoreB
        }
    }
    @IBAction func reloadData(_ sender: Any) {
        userCards = UserCardStorageHelper.shared.fetchAllUserCard() ?? []
        filterUserCards.removeAll()
        cardsInfoLabel.stringValue = "持有 \(String(collectionViewDataModel.count)) 种卡"
        self.userCardCollectionView.reloadData()
    }
    
    func filterData() {
        cardsInfoLabel.stringValue = "持有 \(String(collectionViewDataModel.count)) 种卡"
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
    
    @IBAction func sortTypeChange(_ sender: Any) {
        if self.cardsFiltePredicateEditor.numberOfRows > 0 {
            sortDataModel(dataModel: &filterUserCards)
        } else {
            sortDataModel(dataModel: &userCards)
        }
        self.userCardCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
        ApiHelper.shared.taskWaitTime = 15
        SIFCacheHelper.shared.cacheDirectory = "/Users/cmst0us/Downloads/round_card_images"
        cardsInfoLabel.stringValue = "持有 \(String(collectionViewDataModel.count)) 种卡"
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
        
        let cardDataModel = SIFCacheHelper.shared.cards[collectionViewDataModel[indexPath.item].cardId]
        let idolized = collectionViewDataModel[indexPath.item].idolized
        cardCollectionViewItem.setupView(withModel: cardDataModel!, idolized: idolized)
        return cardCollectionViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataModel.count
    }
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}

