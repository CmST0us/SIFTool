//
//  UserCardStorageHelper.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/25.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
import CoreData

class UserCardStorageHelper {
    private init() {
        
    }
    static var shared: UserCardStorageHelper = UserCardStorageHelper()
    
    private func doSave() {
        do {
            try UserCardCoreDataHelper.shared.saveContext()
        } catch {
            Logger.shared.output("can not save core data")
        }
    }
}

// MARK: - fetch method
extension UserCardStorageHelper {
    func fetchUserCardManagedObject(withCardId cardId: Int, cardSetName: String) -> NSManagedObject? {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: UserCardDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "cardId == %d AND cardSetName == %@", cardId, cardSetName)
        do {
            if let result = try viewContext.fetch(fetchRequest).first {
                return result
            }
        } catch {
            return nil
        }
        return nil
    }
    
    
    
    func fetchAllCard(cardSetName: String) -> [UserCardDataModel]? {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: UserCardDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "cardSetName == %@", cardSetName)
        fetchRequest.resultType = .dictionaryResultType
        do {
            if let result = try viewContext.fetch(fetchRequest) as? [[String: Any]] {
                return result.map({ (obj) -> UserCardDataModel in
                    return UserCardDataModel(withDictionary: obj)
                })
            }
        } catch {
            return nil
        }
        return nil
    }
    
    func fetchAllCardSetName() -> NSOrderedSet {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: UserCardDataModel.entityName)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            var userSet = Set<String>.init()
            for result in results {
                let user = result.value(forKey: "cardSetName") as! String
                userSet.insert(user)
            }
            return NSOrderedSet.init(set: userSet)
        } catch {
            return []
        }
    }
}


// MARK: - add method
extension UserCardStorageHelper {
    func addCard(card: UserCardDataModel, checkExist: Bool = true) {
        
        func add(card: UserCardDataModel) {
            let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
            let description = NSEntityDescription.insertNewObject(forEntityName: UserCardDataModel.entityName, into: viewContext)
            card.copy(to: description)
            doSave()
            do {
                try UserCardCoreDataHelper.shared.saveContext()
            } catch {
                Logger.shared.output("can not save core data")
            }
        }
        
        if checkExist == false {
            add(card: card)
        } else {
            if let _ = fetchUserCardManagedObject(withCardId: card.cardId, cardSetName: card.cardSetName) {
                return
            } else {
                add(card: card)
            }
        }
    }
}

// MARK: - remove method
extension UserCardStorageHelper {
    func removeUserCard(withCardId cardId: Int, cardSetName: String) {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        if let managedObject = fetchUserCardManagedObject(withCardId: cardId, cardSetName: cardSetName) {
            viewContext.delete(managedObject)
            doSave()
        }
    }
    func removeAllCards(cardSetName: String) {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: UserCardDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "cardSetName == %@", cardSetName)
        do {
            let results = try viewContext.fetch(fetchRequest)
            for result in results {
                viewContext.delete(result)
            }
            doSave()
        } catch {
            return
        }
    }
}


