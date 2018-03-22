//
//  CardSetNameSelectTableViewController.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/22.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardSetNameSelectTableViewController: UITableViewController {
    
    struct Identifier {
        static let addCell = "addCell"
        static let nameCell = "nameCell"
    }
    
    // MARK: Private Member
    lazy var dataSource: [String] = {
        return UserCardStorageHelper.shared.fetchAllCardSetName().array as! [String]
    }()
    
}


// MARK: - View Life Cycle
extension SIFCardSetNameSelectTableViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }

}


// MARK: - Table View Delegate And Datasource
extension SIFCardSetNameSelectTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 4
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 4
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return dataSource.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.tuple {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.addCell, for: indexPath)
            return cell
        case (1, let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.nameCell, for: indexPath)
            if dataSource[row] == SIFCacheHelper.shared.currentCardSetName {
                cell.textLabel?.textColor = UIColor.currentCardSet
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            cell.textLabel?.text = dataSource[row]
            return cell
        default:
            break
        }
        
        fatalError()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.tuple {
        case (0, 0):
            //add
            let addNewCardSetNameController = UIAlertController(title: "创建新卡组", message: "输入卡组名", preferredStyle: UIAlertControllerStyle.alert)
            let commitAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                if let text = addNewCardSetNameController.textFields?.first?.text, text.count > 0 {
                    SIFCacheHelper.shared.currentCardSetName = text
                    NotificationCenter.default.post(name: NSNotification.Name.init(SIFCardToolListViewController.NotificationName.switchCardSet), object: nil)
                    self.dismiss(animated: false, completion: nil)
                }
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            addNewCardSetNameController.addTextField(configurationHandler: nil)
            addNewCardSetNameController.addAction(commitAction)
            addNewCardSetNameController.addAction(cancelAction)
            self.present(addNewCardSetNameController, animated: true, completion: nil)
            
        case (1, let row):
            //switch card set
            let selectCardSetName = dataSource[row]
            SIFCacheHelper.shared.currentCardSetName = selectCardSetName
            NotificationCenter.default.post(name: NSNotification.Name.init(SIFCardToolListViewController.NotificationName.switchCardSet), object: nil)
            self.dismiss(animated: false, completion: nil)
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.tuple {
        case (0, _):
            return false
        case (1, _):
            if dataSource.count == 1{
                return false
            }
            fallthrough
        default:
            return true
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "删除", message: "是否删除此卡组", preferredStyle: .alert)
        let commitAction = UIAlertAction(title: "确定", style: .default) { (action) in
            UserCardStorageHelper.shared.removeAllCards(cardSetName: self.dataSource[indexPath.row])
            self.dataSource.remove(at: indexPath.row)
            SIFCacheHelper.shared.currentCardSetName = self.dataSource.last!
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SIFCardToolListViewController.NotificationName.switchCardSet), object: nil, userInfo: nil)
            self.dismiss(animated: false, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(commitAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}

// MARK: - Story Board Method
extension SIFCardSetNameSelectTableViewController {
    
    static func storyBoardInstance() -> SIFCardSetNameSelectTableViewController {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: "SIFCardSetNameSelectTableViewController") as! SIFCardSetNameSelectTableViewController
        
    }
    
}

extension SIFCardSetNameSelectTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
