//
//  CheckBoxTableCellView.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/25.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class CheckBoxTableCellView: NSTableCellView {

    
    @IBOutlet weak var checkBoxButton: NSButton!
    
    var on: Bool {
        get {
            return checkBoxButton.state == .on
        }
        set {
            if newValue == true {
                checkBoxButton.state = .on
            } else {
                checkBoxButton.state = .off
            }
        }
    }
}
