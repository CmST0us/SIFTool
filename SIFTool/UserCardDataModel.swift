//
//  UserCardDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/25.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class UserCardDataModel {
    var cardId: Int
    var idolized: Bool
    
    var isImport: Bool = true
    
    init(withDictionary dictionary:[String: Any]) {
        cardId = dictionary["cardId"] as! Int
        idolized = dictionary["idolized"] as! Bool
    }
    
    init() {
        cardId = 0
        idolized = false
    }
}

extension UserCardDataModel: CoreDataModelBridgeProtocol {
    static var entityName: String = "UserCard"
    
    func copy(to managedObject: NSManagedObject) {
        managedObject.setValue(cardId, forKey: "cardId")
        managedObject.setValue(idolized, forKey: "idolized")
    }
}
