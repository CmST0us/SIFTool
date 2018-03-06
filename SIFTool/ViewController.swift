//
//  ViewController.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardToolMainViewController: UIViewController {

    @IBOutlet weak var userCardCollectionView: UICollectionView!
    
    lazy var user: String = UserDefaults.init().value(forKey: "user") as? String ?? "default"
    
    lazy var _collectionViewDataSource: [UserCardDataModel] = {
       return UserCardStorageHelper.shared.fetchAllUserCard(user: user) ?? []
    }()
    
    //mock
    var collectionViewDataSource: [UserCardDataModel] {
        return (1000 ... 1100).map { (item) -> UserCardDataModel in
            return UserCardDataModel.init(withDictionary: ["cardId": item, "idolized": false, "user": "default", "isKizunaMax": false])
        }
    }
}

// MARK: - View Life Cycle
extension SIFCardToolMainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userCardCollectionView.delegate = self
        userCardCollectionView.dataSource = self
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
        ApiHelper.shared.taskWaitTime = 15
        let tempDir = "/Users/cmst0us/Downloads/card_round"
        SIFCacheHelper.shared.cacheDirectory = tempDir
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - Collection View Delegate And DataSouce
extension SIFCardToolMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SIFUserCardCollectionViewCell.Identificer.userCardCell.rawValue, for: indexPath) as! SIFUserCardCollectionViewCell
        let userCardModel = collectionViewDataSource[indexPath.row]
        cell.setupView(withCard: SIFCacheHelper.shared.cards[userCardModel.cardId]!, userCard: userCardModel)
        return cell
    }
}

