//
//  OpenCardSetViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/3/3.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class OpenCardSetViewController: NSViewController {

    @IBOutlet weak var cardSetTableView: NSTableView!
    
    lazy var users: NSOrderedSet = {
        return UserCardStorageHelper.shared.fetchAllCardSetName()
    }()	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func comfirm(_ sender: Any) {
        let selectIndex = cardSetTableView.selectedRow
        let name = users.object(at: selectIndex) as! String
        SIFCacheHelper.shared.currentCardSetName = name
        NotificationCenter.default.post(name: NSNotification.Name.init(MainViewController.NotificationName.reloadData), object: nil)
        NSApplication.shared.keyWindow!.close()
    }
}

extension OpenCardSetViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return users.object(at: row)
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return users.count
    }
    
}
