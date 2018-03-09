//
//  SIFCardPredicateEditorValueTableViewCell.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/8.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit


protocol SIFCardFilterPredicateEditorDelegate {
    func predicateEditor(_ predicateEditor: SIFCardFilterPredicateEditorTableViewController, row: Int, didChangePredicate predicate: SIFCardFilterPredicate)
}


class SIFCardFilterPredicateEditorValueTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var valueTextField: UITextField!
    
    enum Identifier: String {
        case valueCell = "valueCell"
    }
    
    var value: String? {
        get {
            return valueTextField.text
        }
        set {
            valueTextField.text = newValue
        }
    }
}

extension SIFCardFilterPredicateEditorValueTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
