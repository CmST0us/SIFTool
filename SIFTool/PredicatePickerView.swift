//
//  PredicatePickerView.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/8.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class PredicatePickerView: UIView {

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func done(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}

extension PredicatePickerView {
    
}

extension PredicatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}
