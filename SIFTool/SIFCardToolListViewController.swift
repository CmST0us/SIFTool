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
import SnapKit

class SIFCardToolListViewController: UIViewController {
    
    struct Segue {
        static let cardFilterSegue = "cardFilterSegue"
        static let importCardSegue = "importCardSegue"
    }
    
    struct Identificer {
        static let userCardCell = "userCardCell"
        static let sortCell = "sortCell"
        
    }

    //MARK: Private Member
    private var processHUD: MBProgressHUD!
    
    private var sortToolView: SIFCardSortToolView!
    
    private var lastScrollViewOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    private var selectScreenshots: [UIImage]!
    
    private var sortConfigSelectIndexTuple = (attribute: 0, rank: 0, method: 0) {
        didSet {
            userCardDataSource.sort { (a, b) -> Bool in
                let aCard = SIFCacheHelper.shared.cards[a.cardId]!
                let bCard = SIFCacheHelper.shared.cards[b.cardId]!
                
                /*
                 <rank attr=min>
                 <attribute attr=Cool> </attribute>
                 <attribute attr=Pure> </attribute>
                 <attribute attr=Smile> </attribute>
                 <attribute attr=All> </attribute>
                 </rank>
                 <rank attr=nonidolized>
                 <attribute attr=Cool> </attribute>
                 <attribute attr=Pure> </attribute>
                 <attribute attr=Smile> </attribute>
                 <attribute attr=All> </attribute>
                 </rank>
                 <rank attr=idolized>
                 <attribute attr=Cool> </attribute>
                 <attribute attr=Pure> </attribute>
                 <attribute attr=Smile> </attribute>
                 <attribute attr=All> </attribute>
                 </rank>
                 <rank attr=user>
                 <attribute attr=Cool> </attribute>
                 <attribute attr=Pure> </attribute>
                 <attribute attr=Smile> </attribute>
                 <attribute attr=All> </attribute>
                 </rank>
                 */
                
                let aSortArray = [
                    [aCard.minimumStatisticsCool, aCard.minimumStatisticsPure, aCard.minimumStatisticsSmile],
                    [aCard.nonIdolizedMaximumStatisticsCool, aCard.nonIdolizedMaximumStatisticsPure, aCard.nonIdolizedMaximumStatisticsSmile],
                    [aCard.idolizedMaximumStatisticsCool, aCard.idolizedMaximumStatisticsPure, aCard.idolizedMaximumStatisticsSmile],
                    [aCard.statisticsCool(idolized: a.idolized, isKizunaMax: a.isKizunaMax), aCard.statisticsPure(idolized: a.idolized, isKizunaMax: a.isKizunaMax), aCard.statisticsSmile(idolized: a.idolized, isKizunaMax: a.isKizunaMax)]
                    
                ]
                
                let bSortArray = [
                    [bCard.minimumStatisticsCool, bCard.minimumStatisticsPure, bCard.minimumStatisticsSmile],
                    [bCard.nonIdolizedMaximumStatisticsCool, bCard.nonIdolizedMaximumStatisticsPure, bCard.nonIdolizedMaximumStatisticsSmile],
                    [bCard.idolizedMaximumStatisticsCool, bCard.idolizedMaximumStatisticsPure, bCard.idolizedMaximumStatisticsSmile],
                    [bCard.statisticsCool(idolized: b.idolized, isKizunaMax: b.isKizunaMax), bCard.statisticsPure(idolized: b.idolized, isKizunaMax: b.isKizunaMax), bCard.statisticsSmile(idolized: b.idolized, isKizunaMax: b.isKizunaMax)]
                ]
                
                let attributeIndex = sortConfigSelectIndexTuple.attribute
                let rankIndex = sortConfigSelectIndexTuple.rank
                
                
                let sortScoreA = aSortArray[rankIndex][attributeIndex].intValue
                let sortScoreB = bSortArray[rankIndex][attributeIndex].intValue
                
                if sortConfigSelectIndexTuple.method == 0 {
                    return sortScoreA > sortScoreB
                }
                return sortScoreA < sortScoreB
            }
            self.reloadData()
        }
    }
    
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
    
    lazy private var userCardDataSource: [UserCardDataModel] = {
        
       return UserCardStorageHelper.shared.fetchAllCard(cardSetName: SIFCacheHelper.shared.currentCardSetName) ?? []
        
    }()
    
    private var collectionViewDataSource: [UserCardDataModel] {
        
        if cardFiltePredicates.count > 0 {
            return filteCardDataSource
        }
        
        return userCardDataSource
        
    }
    
    private func isPhotoLibraryAvailable() -> Bool {
        
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        
    }
    
    // MARK: Private Method
    private func setupSortToolView() {
        
        self.sortToolView = Bundle.main.loadNibNamed("SortToolView", owner: SIFCardSortToolView.self, options: nil)?.last! as! SIFCardSortToolView
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        
        sortToolView.attributeSortBlock = { [weak self] sender in
            
            let sheet = UIAlertController(title: "排序属性", message: nil, preferredStyle: .actionSheet)
            
            let pureSortAction = UIAlertAction(title: "洒脱", style: .default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.attribute = 0
            })
            let coolSortAction = UIAlertAction(title: "清纯", style: .default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.attribute = 1
            })
            let smileSortActin = UIAlertAction(title: "甜美", style: .default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.attribute = 2
            })
            
            sheet.addAction(pureSortAction)
            sheet.addAction(coolSortAction)
            sheet.addAction(smileSortActin)
            sheet.addAction(cancelAction)
            
            if let sheetPopverController = sheet.popoverPresentationController {
                sheetPopverController.sourceView = sender
                sheetPopverController.permittedArrowDirections = .any
                self?.present(sheet, animated: true, completion: nil)
            } else {
                self?.present(sheet, animated: true, completion: nil)
            }
            
        }
        
        sortToolView.rankSortBlock = { [weak self] sender in
            let sheet = UIAlertController(title: "排序等级", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let minRankSortAction = UIAlertAction(title: "1级", style: UIAlertActionStyle.default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.rank = 0
            })
            let maxRankNonIdolizedAction = UIAlertAction(title: "未觉醒最高", style: UIAlertActionStyle.default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.rank = 1
            })
            let maxRankIdolizedAction = UIAlertAction(title: "觉醒最高", style: UIAlertActionStyle.default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.rank = 2
            })
            let userIdolizedStateAction = UIAlertAction(title: "用户持有觉醒状态", style: UIAlertActionStyle.default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.rank = 3
            })
            
            sheet.addAction(minRankSortAction)
            sheet.addAction(maxRankNonIdolizedAction)
            sheet.addAction(maxRankIdolizedAction)
            sheet.addAction(userIdolizedStateAction)
            sheet.addAction(cancelAction)
            
            if let sheetPopverController = sheet.popoverPresentationController {
                sheetPopverController.sourceView = sender
                sheetPopverController.permittedArrowDirections = .any
                self?.present(sheet, animated: true, completion: nil)
            } else {
                self?.present(sheet, animated: true, completion: nil)
            }
            
        }
        
        sortToolView.sortMethodBlcok = { [weak self] sender in
            let sheet = UIAlertController(title: "排序方式", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let ascendingMethodAction = UIAlertAction(title: "升序", style: UIAlertActionStyle.default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.method = 0
            })
            let deascendingMethodAction = UIAlertAction(title: "降序", style: UIAlertActionStyle.default, handler: { (action) in
                self?.sortConfigSelectIndexTuple.method = 1
            })
            
            sheet.addAction(ascendingMethodAction)
            sheet.addAction(deascendingMethodAction)
            sheet.addAction(cancelAction)
            
            if let sheetPopverController = sheet.popoverPresentationController {
                sheetPopverController.sourceView = sender
                sheetPopverController.permittedArrowDirections = .any
                self?.present(sheet, animated: true, completion: nil)
            } else {
                self?.present(sheet, animated: true, completion: nil)
            }
            
        }
        
    }
    
    // MARK: IBOutlet
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

        setupSortToolView()
        
        self.sortToolView.translatesAutoresizingMaskIntoConstraints = false
        
        self.userCardCollectionView.addSubview(self.sortToolView)
        
        self.sortToolView.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.userCardCollectionView.snp.top)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.height.equalTo(34)
        }
        
        self.userCardCollectionView.contentInset = UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: SIFCardImportCollectionViewController.NotificationName.importFinish), object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.userCardCollectionView.contentOffset = lastScrollViewOffset
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        lastScrollViewOffset = self.userCardCollectionView.contentOffset
        
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
