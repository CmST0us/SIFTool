//
//  SIFCardPredicateEditorTableViewController.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/8.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardFilterPredicateEditorTableViewController: UITableViewController {
    typealias DisplayTuple = (keyPath: String, conditions: [String], value: (type: SIFCardFilterPredicateEditorTableViewController.CellType, inputList: [String]?))
    
    enum CellType {
        case value
        case select
    }
    
    // ("id", ["is", "or", "contains"], (.value, nil))
    // ("rarity", ["is", "or", "contains"], (.select, ["UR", "SSR"]))
    lazy var displayTuples: [DisplayTuple] = {
        return templateRow.map { template in
            let keyPath = template.leftExpression.displayName
            let conditions = template.condition.currentConditionsDisplayName()
            var valueType = SIFCardFilterPredicateEditorTableViewController.CellType.value
            var valueInputList: [String]? = nil
            
            if template.rightExpressionType == .constantValue {
                valueType = .select
                valueInputList = template.rightExpression.map { obj in
                    obj.displayName
                }
                
            } else {
                valueType = .value
            }
            let retTuple = (
                keyPath: keyPath,
                conditions: conditions,
                value: (type: valueType, inputList: valueInputList)
            )
            return retTuple
        }
    }()

    var rowIndex: Int = 0
    
    var templateRow: [SIFCardFilterPredicateEditorRowTemplate]!
    
    // select row in (Section 0, Section 1, Section 2)
    var currentSelectIndex: (Int, Int, Int) = (0, 0, 0)
    
    var currentInputValue: String = ""
    
    var delegate: SIFCardFilterPredicateEditorDelegate? = nil
    
    func setup(withExistedPredicate: SIFCardFilterPredicate) {
        currentSelectIndex.0 = templateRow.index(where: { (template) -> Bool in
            return template.leftExpression.expression.keyPath == withExistedPredicate.keyPath
        }) ?? 0
        
        currentSelectIndex.1 = templateRow[currentSelectIndex.0].condition.conditions.index(where: { (item) -> Bool in
            return item.rawValue == withExistedPredicate.condition
        }) ?? 0
        
        if displayTuples[currentSelectIndex.0].value.type == .select {
            currentSelectIndex.2 = templateRow[currentSelectIndex.0].rightExpression.index(where: { (item) -> Bool in
                return item.expression.constantValue as! String == withExistedPredicate.value
            }) ?? 0
        } else {
            currentSelectIndex.2 = 0
            currentInputValue = withExistedPredicate.value
        }

    }

}

// MARK: - View Life Cycle Method
extension SIFCardFilterPredicateEditorTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if displayTuples[currentSelectIndex.0].value.type == .select {
            let predicate = SIFCardFilterPredicate(withKeyPath: templateRow[currentSelectIndex.0].leftExpression.expression.keyPath, conditions: templateRow[currentSelectIndex.0].condition.conditions[currentSelectIndex.1].rawValue, value: templateRow[currentSelectIndex.0].rightExpression[currentSelectIndex.2].expression.constantValue as! String)
            
            predicate.keyPathDisplayName = displayTuples[currentSelectIndex.0].keyPath
            predicate.conditionDisplayName = displayTuples[currentSelectIndex.0].conditions[currentSelectIndex.1]
            predicate.valueDisplayName = displayTuples[currentSelectIndex.0].value.inputList![currentSelectIndex.2]
            
            if let _delegate = delegate {
                _delegate.predicateEditor(self, row: self.rowIndex, didChangePredicate: predicate)
            }
        } else {
            let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 2)) as! SIFCardFilterPredicateEditorValueTableViewCell
            let predicate = SIFCardFilterPredicate(withKeyPath: templateRow[currentSelectIndex.0].leftExpression.expression.keyPath, conditions: templateRow[currentSelectIndex.0].condition.conditions[currentSelectIndex.1].rawValue, value: cell.value ?? "")
            
            predicate.keyPathDisplayName = displayTuples[currentSelectIndex.0].keyPath
            predicate.conditionDisplayName = displayTuples[currentSelectIndex.0].conditions[currentSelectIndex.1]
            predicate.valueDisplayName = predicate.value
            
            if let _delegate = delegate {
                _delegate.predicateEditor(self, row: self.rowIndex, didChangePredicate: predicate)
            }
        }
        
        super.viewWillDisappear(animated)
    }
}

// MARK: - Table View Delegate And DataSource Method
extension SIFCardFilterPredicateEditorTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return displayTuples.count
        case 1:
            return displayTuples[currentSelectIndex.0].conditions.count
        case 2:
            if displayTuples[currentSelectIndex.0].value.type == .select {
               return displayTuples[currentSelectIndex.0].value.inputList!.count
            } else {
                return 1
            }
        default:
            break
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.tuple {
        case (0, let row):
            let cell = tableView.cellForRow(at: indexPath) as! SIFCardFilterPredicateEditorSelectTableViewCell
            let lastCell = tableView.cellForRow(at: IndexPath.init(row: currentSelectIndex.0, section: 0)) as! SIFCardFilterPredicateEditorSelectTableViewCell
            lastCell.select = false
            cell.select = true
            currentSelectIndex = (0, 0, 0)
            currentSelectIndex.0 = row
            tableView.reloadSections(IndexSet.init(integersIn: 1 ... 2), with: UITableViewRowAnimation.automatic)
            currentInputValue = ""
            break
        case (1, let row):
            let cell = tableView.cellForRow(at: indexPath) as! SIFCardFilterPredicateEditorSelectTableViewCell
            let lastCell = tableView.cellForRow(at: IndexPath.init(row: currentSelectIndex.1, section: 1)) as! SIFCardFilterPredicateEditorSelectTableViewCell
            lastCell.select = false
            cell.select = true
            currentSelectIndex.1 = row
            currentInputValue = ""
            break
        case (2, let row):
            if displayTuples[currentSelectIndex.0].value.type == .select {
                let cell = tableView.cellForRow(at: indexPath) as! SIFCardFilterPredicateEditorSelectTableViewCell
                let lastCell = tableView.cellForRow(at: IndexPath.init(row: currentSelectIndex.2, section: 2)) as! SIFCardFilterPredicateEditorSelectTableViewCell
                lastCell.select = false
                cell.select = true
                currentSelectIndex.2 = row
            }
            break
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.tuple {
        case (0, let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: SIFCardFilterPredicateEditorSelectTableViewCell.Identifier.selectCell.rawValue, for: indexPath) as! SIFCardFilterPredicateEditorSelectTableViewCell
            if row == currentSelectIndex.0 {
                cell.select = true
            } else {
                cell.select = false
            }
            cell.textLabel?.text = displayTuples[row].keyPath
            return cell
        case (1, let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: SIFCardFilterPredicateEditorSelectTableViewCell.Identifier.selectCell.rawValue, for: indexPath) as! SIFCardFilterPredicateEditorSelectTableViewCell
            if row == currentSelectIndex.1 {
                cell.select = true
            } else {
                cell.select = false
            }
            cell.textLabel?.text = displayTuples[currentSelectIndex.0].conditions[row]
            return cell
        case (2, let row):
            if displayTuples[currentSelectIndex.0].value.type == .select {
                let cell = tableView.dequeueReusableCell(withIdentifier: SIFCardFilterPredicateEditorSelectTableViewCell.Identifier.selectCell.rawValue, for: indexPath) as! SIFCardFilterPredicateEditorSelectTableViewCell
                if row == currentSelectIndex.2 {
                    cell.select = true
                } else {
                    cell.select = false
                }
                cell.textLabel?.text = displayTuples[currentSelectIndex.0].value.inputList?[row]
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SIFCardFilterPredicateEditorValueTableViewCell.Identifier.valueCell.rawValue, for: indexPath) as! SIFCardFilterPredicateEditorValueTableViewCell
                cell.value = currentInputValue
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
}
