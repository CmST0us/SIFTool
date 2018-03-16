//
//  SIFCardFilterViewController.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/7.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit
import CoreData

class SIFCardFilterViewController: UIViewController {
    
    struct Segue {
        static let predicateEditorSegue = "predicateEditorSegue"
    }
    
    struct Identifier {
        static let addCell = "addCell"
        static let predicateCell = "predicateCell"
    }
    var delegate: SIFCardFilterDelegate?
    
    var predicates: [SIFCardFilterPredicate] = []
    
    var templateRow: [SIFCardFilterPredicateEditorRowTemplate] = []
    
    private var nextViewController: UIViewController!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction func save(_ sender: Any) {
        
        if let _delegate = delegate {
            _delegate.cardFilter(self, didFinishPredicateEdit: predicates)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

// MARK: - Life Cycle Method
extension SIFCardFilterViewController {
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
}


// MARK: - Table View Data Souce And Delegate
extension SIFCardFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            return predicates.count
        }
        return 1
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.tuple {
        case (0, 0):
            return 44
        default:
            return 67
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.tuple {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.addCell, for: indexPath)
            return cell
        case (1, let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.predicateCell, for: indexPath) as! SIFCardFilterPredicateTableViewCell
            cell.keyPathLabel.text = predicates[row].keyPathDisplayName
            cell.conditionLabel.text = predicates[row].conditionDisplayName
            cell.valueLabel.text = predicates[row].valueDisplayName
            return cell
        default:
            fatalError()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.tuple {
        case (0, 0):
            let p = SIFCardFilterPredicate(withKeyPath: templateRow.first?.leftExpression.expression.keyPath ?? "", conditions: templateRow.first?.condition.currentConditions().first ?? "", value: "")
            p.keyPathDisplayName = templateRow.first?.leftExpression.displayName ?? ""
            p.conditionDisplayName = templateRow.first?.condition.currentConditionsDisplayName().first ?? ""
            predicates.append(p)
            tableView.reloadSections(IndexSet.init(integersIn: 1 ... 1), with: UITableViewRowAnimation.automatic)
            break
        case (1, let row):
            if nextViewController is SIFCardFilterPredicateEditorTableViewController {
                let v = nextViewController as! SIFCardFilterPredicateEditorTableViewController
                v.delegate = self
                v.rowIndex = row
                v.templateRow = templateRow
                v.setup(withExistedPredicate: predicates[row])
            }
            break
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch indexPath.tuple {
        case (1, let row):
            if editingStyle == .delete {
                predicates.remove(at: row)
                tableView.reloadSections(IndexSet.init(integersIn: 1 ... 1), with: UITableViewRowAnimation.none)
            }
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
}

extension SIFCardFilterViewController: SIFCardFilterPredicateEditorDelegate {
    
    func predicateEditor(_ predicateEditor: SIFCardFilterPredicateEditorTableViewController, row: Int, didChangePredicate predicate: SIFCardFilterPredicate) {
        
        predicates[row] = predicate
        tableView.reloadRows(at: [IndexPath.init(row: row, section: 1)], with: UITableViewRowAnimation.none)
        
    }
}

// MARK: - Story Board Method
extension SIFCardFilterViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else {
            return
        }
        
        switch segue.identifier! {
        case Segue.predicateEditorSegue:
            self.nextViewController = segue.destination
        default:
            break
        }
        
    }
    
}

// MARK: - Adaptive PopoverController Method
//extension SIFCardFilterViewController: UIPopoverPresentationControllerDelegate {
//
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return .none
//    }
//
//}

