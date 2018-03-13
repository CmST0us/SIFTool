//
//  UIViewController+ErrorAlert.swift
//  LLInfo
//
//  Created by CmST0us on 2018/1/31.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func showErrorAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let c = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        a.addAction(c)
        self.present(a, animated: true, completion: nil)
    }
    
}
