//
//  SIFCardFilterPredicateEditorDelegate.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/9.
//  Copyright © 2018年 eki. All rights reserved.
//

protocol SIFCardFilterDelegate {
    func cardFilter(_ cardFilter: SIFCardFilterViewController, didFinishPredicateEdit predicates: [SIFCardFilterPredicate])
}
