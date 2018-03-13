//
//  ViewController.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit
import MobileCoreServices
import TZImagePickerController

class SIFCardToolListViewController: UIViewController {
    
    struct Segue {
        static let cardFilterSegue = "cardFilterSegue"
        static let importCardSegue = "importCardSegue"
    }
    
    private var selectScreenshots: [UIImage]!
    
//    private lazy var _collectionViewDataSource: [UserCardDataModel] = {
//
//       return UserCardStorageHelper.shared.fetchAllUserCard(user: user) ?? []
//
//    }()
    
    private var cardFiltePredicates: [SIFCardFilterPredicate] = []

    private var filteCardDataSource: [UserCardDataModel] {
        
        let p = cardFiltePredicates.map { (item) -> NSPredicate in
            item.predicate
        }
        
        return userCardDataSource.filter { (item) -> Bool in
            let cardInfoModel = SIFCacheHelper.shared.cards[item.cardId]!
            for i in p {
                if i.evaluate(with: cardInfoModel) == false {
                    return false
                }
            }
            return true
        }
        
    }
    
    private var userCardDataSource: [UserCardDataModel] {
        
        return (1000 ... 1100).map { (item) -> UserCardDataModel in
            return UserCardDataModel.init(withDictionary: ["cardId": item, "idolized": false, "cardSetName": "default", "isKizunaMax": false])
        }
        
    }
    
    private var collectionViewDataSource: [UserCardDataModel] {
        
        if cardFiltePredicates.count > 0 {
            return filteCardDataSource
        }
        
        return userCardDataSource
        
    }
    
    @IBOutlet private weak var userCardCollectionView: UICollectionView!
    
    @IBAction func addCard(_ sender: Any) {
        
        let addMethodSheet = UIAlertController(title: "添加卡片", message: nil, preferredStyle: .actionSheet)
        let addMethodAllCard = UIAlertAction(title: "从所有卡片中添加", style: .default) { (action) in
            
        }
        let addMethodScreenshot = UIAlertAction(title: "从游戏截图添加", style: .default) { (action) in
            guard self.isPhotoLibraryAvailable() else {
                return
            }
            
            let photoPicker = TZImagePickerController()
            photoPicker.allowCrop = false
            photoPicker.allowTakePicture = true
            photoPicker.allowPickingVideo = false
            photoPicker.pickerDelegate = self
            
            self.present(photoPicker, animated: true, completion: nil)
        }
        let addMethodCancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        addMethodSheet.addAction(addMethodScreenshot)
        addMethodSheet.addAction(addMethodAllCard)
        addMethodSheet.addAction(addMethodCancel)
        
        let popoverController = addMethodSheet.popoverPresentationController
        
        if popoverController != nil {
            if sender is UIBarButtonItem {
                popoverController!.barButtonItem = (sender as! UIBarButtonItem)
            }
            popoverController!.permittedArrowDirections = .any
        }
        
        self.present(addMethodSheet, animated: true, completion: nil)
        
    }
    
    func isPhotoLibraryAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
    }
    
}

// MARK: - View Life Cycle
extension SIFCardToolListViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        userCardCollectionView.delegate = self
        userCardCollectionView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
}

// MARK: - Collection View Delegate And DataSouce
extension SIFCardToolListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionViewDataSource.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SIFUserCardCollectionViewCell.Identificer.userCardCell, for: indexPath) as! SIFUserCardCollectionViewCell
        let userCardModel = collectionViewDataSource[indexPath.row]
        cell.setupView(withCard: SIFCacheHelper.shared.cards[userCardModel.cardId]!, userCard: userCardModel)
        return cell
        
    }
    
}


// MARK: - StoryBoard Method
extension SIFCardToolListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            if identifier == Segue.cardFilterSegue {
                let dest = (segue.destination as! UINavigationController).topViewController! as! SIFCardFilterViewController
                dest.predicates = self.cardFiltePredicates
                dest.delegate = self
                dest.templateRow = [
                    SIFCardFilterPredicateEditorRowTemplate.init(
                        withLeftExpression: (expression: NSExpression.init(forKeyPath: "id"), displayName: "卡片ID"),
                        rightExpression: [(expression: NSExpression.init(expressionType: NSExpression.ExpressionType.variable), displayName: "")],
                        condition: SIFCardFilterPredicateCondition.init(withConditions: [SIFCardFilterPredicateCondition.Condition.equal]),
                        rightExpressionType: .variable),
                    
                    SIFCardFilterPredicateEditorRowTemplate.init(
                        withLeftExpression: (expression: NSExpression.init(forKeyPath: "idol.name"), displayName: "名字"),
                        rightExpression: [(expression: NSExpression.init(expressionType: NSExpression.ExpressionType.variable), displayName: "")],
                        condition: SIFCardFilterPredicateCondition.init(withConditions: [SIFCardFilterPredicateCondition.Condition.equal, .contains]),
                        rightExpressionType: .variable),
                    
                    SIFCardFilterPredicateEditorRowTemplate.init(
                        withLeftExpression: (expression: NSExpression.init(forKeyPath: "rarity"), displayName: "稀有度"),
                        rightExpression: [(expression: NSExpression.init(forConstantValue: "N"), displayName: "N"),
                                          (expression: NSExpression.init(forConstantValue: "R"), displayName: "R"),
                                          (expression: NSExpression.init(forConstantValue: "SR"), displayName: "SR"),
                                          (expression: NSExpression.init(forConstantValue: "SSR"), displayName: "SSR"),
                                          (expression: NSExpression.init(forConstantValue: "UR"), displayName: "UR"),
                                          ],
                        condition: SIFCardFilterPredicateCondition.init(withConditions: [SIFCardFilterPredicateCondition.Condition.equal]),
                        rightExpressionType: .constantValue),
                    
                    SIFCardFilterPredicateEditorRowTemplate.init(
                        withLeftExpression: (expression: NSExpression.init(forKeyPath: "attribute"), displayName: "属性"),
                        rightExpression: [(expression: NSExpression.init(forConstantValue: "Pure"), displayName: "清纯"),
                                          (expression: NSExpression.init(forConstantValue: "Cool"), displayName: "洒脱"),
                                          (expression: NSExpression.init(forConstantValue: "Smile"), displayName: "甜美")
                        ],
                        condition: SIFCardFilterPredicateCondition.init(withConditions: [SIFCardFilterPredicateCondition.Condition.equal]),
                        rightExpressionType: NSExpression.ExpressionType.constantValue)
                ]
            } else if identifier == Segue.importCardSegue {
                let importViewController = segue.destination as! SIFCardImportCollectionViewController
                importViewController.screenshots = self.selectScreenshots
            }
        }
        
    }
    
}
// MARK: - SIFCardFilterDelegate
extension SIFCardToolListViewController: SIFCardFilterDelegate {
    
    func cardFilter(_ cardFilter: SIFCardFilterViewController, didFinishPredicateEdit predicates: [SIFCardFilterPredicate]) {
        
        self.cardFiltePredicates = predicates
        self.userCardCollectionView.reloadData()
        
    }
    
}

// MARK: - TZImagePickerControllerDelegate Delegate
extension SIFCardToolListViewController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
//        self.selectScreenshots = [UIImage.init(contentsOfFile:  SIFCacheHelper.shared.cacheDirectory.appendingPathComponent("test.png"))!]
        self.selectScreenshots = photos
        self.performSegue(withIdentifier: "importCardSegue", sender: nil)
        
    }

    
}

// MARK: - UINavigationController Delegate
extension SIFCardToolListViewController: UINavigationControllerDelegate {
    
}
