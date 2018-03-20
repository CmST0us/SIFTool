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
import MBProgressHUD

class SIFCardToolListViewController: UIViewController {
    
    struct Segue {
        static let cardFilterSegue = "cardFilterSegue"
        static let importCardSegue = "importCardSegue"
    }
    
    struct Identificer {
        static let userCardCell = "userCardCell"
        static let sortCell = "sortCell"
        
    }

    private var processHUD: MBProgressHUD!
    private var selectScreenshots: [UIImage]!
    
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
        
       return UserCardStorageHelper.shared.fetchAllCard(cardSetName: SIFCacheHelper.shared.currentCardSetName) ?? []
        
    }
    
    private var collectionViewDataSource: [UserCardDataModel] {
        
        if cardFiltePredicates.count > 0 {
            return filteCardDataSource
        }
        
        return userCardDataSource
        
    }
    
    private func isPhotoLibraryAvailable() -> Bool {
        
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        
    }
    
    @IBOutlet private weak var userCardCollectionView: UICollectionView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    @IBAction func onEditButtonDown(_ sender: Any) {
        
        self.isEditing = !self.isEditing
        
        if self.isEditing {
            editButton.title = "完成"
        } else {
            editButton.title = "编辑"
        }
        
        self.userCardCollectionView.reloadData()
        
    }
    
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
    
    @IBAction func refreshCache(_ sender: Any) {

        try? SIFCacheHelper.shared.deleteMatchPattern()
        
        processHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(processHUD)
        
        processHUD.show(animated: true)
        
        func hideHUD(afterDelay: TimeInterval) {
            
            DispatchQueue.main.async {
                self.processHUD.hide(animated: true, afterDelay: afterDelay)
            }
            
        }
        
        func setHUDLabelText(_ text: String) {
            
            DispatchQueue.main.async {
                self.processHUD.label.text = text
            }
            
        }
        
        DispatchQueue.global().async {
            do {
                try SIFCacheHelper.shared.cacheCards(process: { (current, total) in
                    setHUDLabelText("\(String(current)) / \(String(total))")
                })
                hideHUD(afterDelay: 0)
            } catch let e as ApiRequestError{
                setHUDLabelText(e.message)
                hideHUD(afterDelay: 1.0)
            } catch {
                setHUDLabelText(error.localizedDescription)
                hideHUD(afterDelay: 1.0)
            }
        }
        
    }
    
    
}

// MARK: - Notification Method
extension SIFCardToolListViewController {
    
    @objc func reloadData() {
        self.userCardCollectionView.reloadData()
    }
    
}

// MARK: - View Life Cycle
extension SIFCardToolListViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        userCardCollectionView.delegate = self
        userCardCollectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: SIFCardImportCollectionViewController.NotificationName.importFinish), object: nil)
        

    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        userCardCollectionView.setContentOffset(CGPoint.init(x: 0, y: 50), animated: false)
        
    }
    
}

// MARK: - Collection View Delegate And DataSouce
extension SIFCardToolListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionViewDataSource.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identificer.userCardCell, for: indexPath) as! SIFUserCardCollectionViewCell
        let userCardModel = collectionViewDataSource[indexPath.row]
        cell.setupView(withCard: SIFCacheHelper.shared.cards[userCardModel.cardId]!, userCard: userCardModel)
        
        if self.isEditing {
            cell.selectCheckMarkImageView.isHidden = false
            cell.isCellSelected = false
        } else {
            cell.selectCheckMarkImageView.isHidden = true
            cell.isCellSelected = false
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identificer.sortCell, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SIFUserCardCollectionViewCell
        
        if self.isEditing {
            cell.isCellSelected = !cell.isCellSelected
        } else {
            // open detail
        }
        
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
        
        self.selectScreenshots = []
        var originCallCount: Int = 0 {
            didSet {
                if originCallCount == assets.count {
                    self.performSegue(withIdentifier: Segue.importCardSegue, sender: nil)
                }
            }
            
        }
        
        for item in assets {
            TZImageManager.default().getOriginalPhoto(withAsset: item, completion: { (image, info) in
                guard image != nil else {
                    originCallCount += 1
                    return
                }
                self.selectScreenshots.append(image!)
                originCallCount += 1
            })
        }
        
    }

    
}

// MARK: - UINavigationController Delegate
extension SIFCardToolListViewController: UINavigationControllerDelegate {
    
}
