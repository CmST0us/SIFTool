//
//  SIFCardSortCollectionReusableView.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/15.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardSortCollectionReusableView: UICollectionReusableView {
    
    var attributeSortBlock: ((_ sender: UIButton) -> Void)? = nil
    var rankSortBlock: ((_ sender: UIButton) -> Void)? = nil
    var sortMethodBlcok: ((_ sender: UIButton) -> Void)? = nil
    
    @IBAction func onAttributeSortButtonDown(_ sender: UIButton) {
        if attributeSortBlock != nil {
            attributeSortBlock!(sender)
        }
    }
    
    @IBAction func onRankSortButtonDown(_ sender: UIButton) {
        if rankSortBlock != nil {
            rankSortBlock!(sender)
        }
    }
    
    @IBAction func onSortMethodDown(_ sender: UIButton) {
        if sortMethodBlcok != nil {
            sortMethodBlcok!(sender)
        }
    }
    
}


extension SIFCardSortCollectionReusableView {
    
    
    
}
