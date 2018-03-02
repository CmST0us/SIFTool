//
//  UserCardDataModel.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/25.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

@objcMembers
class UserCardDataModel: NSObject {
    var cardId: Int = 0
    var idolized: Bool = false
    var user: String = ""
    
    var isImport: Bool = true

    init(withDictionary dictionary:[String: Any]) {
        cardId = dictionary["cardId"] as! Int
        idolized = dictionary["idolized"] as! Bool
        user = dictionary["user"] as! String
    }
    
    override init() {
        super.init()
    }
    
}

extension UserCardDataModel: CoreDataModelBridgeProtocol {
    static var entityName: String = "UserCard"
    
    func copy(to managedObject: NSManagedObject) {
        managedObject.setValue(cardId, forKey: "cardId")
        managedObject.setValue(idolized, forKey: "idolized")
        managedObject.setValue(user, forKey: "user")
    }
}

