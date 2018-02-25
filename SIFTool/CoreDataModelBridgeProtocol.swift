//
//  CoreDataModelBridgeProtocol.swift
//  LLInfo
//
//  Created by CmST0us on 2018/1/8.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataModelBridgeProtocol {
    static var entityName: String {get}
    
    func copy(to managedObject: NSManagedObject)
}
