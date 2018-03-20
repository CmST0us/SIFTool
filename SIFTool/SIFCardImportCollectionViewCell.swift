//
//  SIFCardImportCollectionViewCell.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardImportCollectionViewCell: SIFUserCardCollectionViewCell {

    var isKizunaMax: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                if self.isKizunaMax {
                    self.isKizunaMaxButton.backgroundColor = UIColor.buttonOn
                } else {
                    self.isKizunaMaxButton.backgroundColor = UIColor.buttonOff
                }
            })
        }
    }
    
    var isIdolized: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                if self.isIdolized {
                    self.isIdolizedButton.backgroundColor = UIColor.buttonOn
                } else {
                    self.isIdolizedButton.backgroundColor = UIColor.buttonOff
                }
            })
        }
    }
    
    var isImport: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                if self.isImport {
                    self.isImportButton.backgroundColor = UIColor.buttonOn
                } else {
                    self.isImportButton.backgroundColor = UIColor.buttonOff
                }
            })
        }
    }
    
    @IBOutlet weak var isKizunaMaxButton: UIButton!
    
    @IBOutlet weak var isIdolizedButton: UIButton!
    
    @IBOutlet weak var isImportButton: UIButton!
    
    
    @IBAction func onKizunaMaxButtonDown(_ sender: Any) {
        self.isKizunaMax = !self.isKizunaMax
    }
    
    
    @IBAction func onIdolizedButtonDown(_ sender: Any) {
        self.isIdolized = !self.isIdolized
    }
    
    @IBAction func onImportButtonDown(_ sender: Any) {
        self.isImport = !self.isImport
    }
    
    override func setupView(withCard: CardDataModel, userCard: UserCardDataModel) {
        
        super.setupView(withCard: withCard, userCard: userCard)
        self.isKizunaMax = userCard.isKizunaMax
        self.isImport = true
        self.isIdolized = userCard.idolized
        
    }
    
}

extension SIFCardImportCollectionViewCell {
    
}
