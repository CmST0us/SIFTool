//
//  CreateNewCardSetViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/3/3.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class CreateNewCardSetViewController: NSViewController {

    @IBOutlet weak var cardSetNameTextField: NSTextField!
    
    @IBAction func create(_ sender: Any) {
        var name = cardSetNameTextField.stringValue
        if name.count == 0 {
            name = "default"
        }
        
        SIFCacheHelper.shared.currentCardSetName = name
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.NotificationName.reloadData), object: nil)
        NSApplication.shared.keyWindow!.close()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
