//
//  SIFCardPredicateEditorSelectTableViewCell.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/8.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardFilterPredicateEditorSelectTableViewCell: UITableViewCell {

    var select: Bool = false {
        
        didSet {
            if select {
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        }
        
    }
}

extension SIFCardFilterPredicateEditorSelectTableViewCell {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
}
