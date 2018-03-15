//
//  SIFCardImportCollectionViewController.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/11.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit
import MBProgressHUD

class SIFCardImportCollectionViewController: UICollectionViewController {

    struct Identifier {
        static let cardCell = "cardCell"
    }
    
    enum ImportType {
        case cardSet
        case screenshot
    }
    
    
    var screenshots: [UIImage]!
    var progressHud: MBProgressHUD!
    
    var detector: SIFRoundIconDetector!
    var detectorConfiguration: SIFRoundIconDetectorConfiguration!
    
    var cards: [UserCardDataModel] = []
    
    private func setupDetector() {
        
        let cardCache = SIFCacheHelper.shared.cards
        self.detectorConfiguration = SIFRoundIconDetectorConfiguration.defaultRoundIconConfiguration(radio: 0.5)
        if let patternImage = UIImage.init(contentsOfFile: SIFCacheHelper.shared.cacheDirectory.appendingPathComponent("pattern.png")) {
            self.detector = SIFRoundIconDetector(withCards: cardCache, configuration: self.detectorConfiguration, roundCardImagePattern: patternImage.mat)
            Logger.shared.console("use pattern image cache")
        } else {
            self.detector = SIFRoundIconDetector(withCards: cardCache, configuration: self.detectorConfiguration)
            
            for roundCardIconUrl in self.detector.roundCardUrls {
                var roundCardIconPair: (CVMat?, CVMat?) = (nil, nil)
                
                if let nonIdolizedRoundCardIconImage = roundCardIconUrl.1 {
                    roundCardIconPair.0 = SIFCacheHelper.shared.image(withUrl: nonIdolizedRoundCardIconImage)?.mat
                }
                
                if let idolizedRoundCardIconImage = roundCardIconUrl.2 {
                    roundCardIconPair.1 = SIFCacheHelper.shared.image(withUrl: idolizedRoundCardIconImage)?.mat
                }
                
                self.detector.makeRoundCardImagePattern(cardId: roundCardIconUrl.0, images: roundCardIconPair)
            }
            
            self.detector.saveRoundCardImagePattern(toPath: SIFCacheHelper.shared.cacheDirectory.appendingPathComponent("pattern.png"))
        }
        
    }

}


// MARK: - View Life Cycle Method
extension SIFCardImportCollectionViewController {
    
    func scanScreenshot() {
    
        self.progressHud = MBProgressHUD(view: self.view)
        self.view.addSubview(self.progressHud)
        self.progressHud.show(animated: true)
        self.progressHud.label.text = "正在扫描图片"
        self.cards = []
        func hideProgressHud() {
            
            DispatchQueue.main.async {
                self.progressHud.hide(animated: true)
            }
            
        }
        
        func setProgressHudLabelText(_ text: String) {
            
            DispatchQueue.main.async {
                self.progressHud.label.text = text
            }
            
        }
        
        func errorAlert(title: String, message: String) {
            
            DispatchQueue.main.async {
                self.showErrorAlert(title: title, message: message)
            }
            
        }
        
        func finish() {
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }
        
        DispatchQueue.global().async {
            if SIFCacheHelper.shared.cards.count == 0 {
                errorAlert(title: "扫描游戏截图", message: "卡片数据不存在，请前往设置下载更新卡片数据")
            }
            
            Logger.shared.output("load cards cache ok")
            
            setProgressHudLabelText("更新卡片数据")
            self.setupDetector()
            setProgressHudLabelText("扫描中")
            
            for screenshot in self.screenshots {
                let originMat = screenshot.mat
                let results = self.detector.search(screenshot: originMat)
                
                for result in results.1 {
                    let roi = originMat.roi(at: results.0)?.roi(at: result)
                    guard roi != nil else {
                        continue
                    }
                    
                    let template = self.detector.makeTemplateImagePattern(image: roi!)
                    
                    if let point = self.detector.match(image: template) {
                        let card = self.detector.card(atPatternPoint: point)
                        
                        if card == nil {
                            continue
                        }
                        
                        let userCard = UserCardDataModel()
                        userCard.cardId = card!.0.id.intValue
                        userCard.idolized = card!.1
                        userCard.isImport = true
                        userCard.isKizunaMax = true
                        userCard.cardSetName = SIFCacheHelper.shared.currentCardSetName
                        self.cards.append(userCard)
                        
                        setProgressHudLabelText("找到卡片(ID: \(String(userCard.cardId)))")
                    }
                    
                }
                
                hideProgressHud()
                finish()
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        scanScreenshot()
        
    }
    
}


// MARK: - Collection View DataSource And Delegate Method
extension SIFCardImportCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.cards.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.cardCell, for: indexPath) as! SIFCardImportCollectionViewCell
    
        let userCard = cards[indexPath.row]
        let cardDataModel = SIFCacheHelper.shared.cards[userCard.cardId]
        cell.setupView(withCard: cardDataModel!, userCard: userCard)
        return cell
        
    }
    
}

// MARK: - Story Board Instance
extension SIFCardImportCollectionViewController {
    
    static func storyBoardInstance() -> SIFCardImportCollectionViewController {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: "SIFCardImportCollectionViewController") as! SIFCardImportCollectionViewController
        
    }
    
}

