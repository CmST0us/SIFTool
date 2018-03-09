//
//  SIFCardFilterPredicateProvider.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/8.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

class SIFCardFilterPredicate: NSObject {
    
    var keyPath: String = ""
    var condition: String = ""
    var value: String = ""
    var keyPathDisplayName: String = ""
    var conditionDisplayName: String = ""
    var valueDisplayName: String = ""
    
    init(withKeyPath keyPath: String, conditions: String, value: String) {
        self.keyPath = keyPath
        self.condition = conditions
        self.value = value
        
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    var predicate: NSPredicate {
        return NSPredicate.init(format: "\(keyPath) \(condition) %@", value)
    }
    
}

class SIFCardFilterPredicateCondition: NSObject {
    enum Condition: String {
        case equal = "=="
        case notEqual = "!="
        case lessThan = "<"
        case greaterThan = ">"
        case lessThanOrEqualTo = "<="
        case greaterThanOrEqualTo = ">="
        case `in` = "in"
        case matches = "matches"
        case like = "like"
        case begins = "begins"
        case ends = "ends"
        case contains = "contains"
    }
    
    var conditions: [Condition] = [.equal]
    
    init(withConditions: [Condition]) {
        conditions = withConditions
    }
    
    func currentConditions() -> [String] {
        return conditions.map { item in
            item.rawValue
        }
    }
    func currentConditionsDisplayName() -> [String] {
//        return conditions.map { item in
//            return NSLocalizedString(item.rawValue, comment: "")
//        }
        return currentConditions()
    }
}

class SIFCardFilterPredicateEditorRowTemplate: NSObject {
    var leftExpression: (expression: NSExpression, displayName: String)
    var rightExpression: [(expression: NSExpression, displayName: String)]
    var condition: SIFCardFilterPredicateCondition
    var rightExpressionType: NSExpression.ExpressionType
    
    init(withLeftExpression: (expression: NSExpression, displayName: String),
         rightExpression: [(expression: NSExpression, displayName: String)],
         condition: SIFCardFilterPredicateCondition,
         rightExpressionType: NSExpression.ExpressionType) {
        
        self.leftExpression = withLeftExpression
        self.rightExpression = rightExpression
        self.condition = condition
        self.rightExpressionType = rightExpressionType
        
    }
    
}
