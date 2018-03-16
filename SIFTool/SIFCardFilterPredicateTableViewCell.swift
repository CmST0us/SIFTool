//
//  SIFCardFilterPredicateTableViewCell.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/7.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardFilterPredicateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var keyPathLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}

// MARK: - Life Cycle Method
extension SIFCardFilterPredicateTableViewCell {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
}
