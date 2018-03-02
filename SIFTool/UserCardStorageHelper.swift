//
//  UserCardStorageHelper.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/25.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
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
    func fetchUserCardManagedObject(withCardId cardId: Int, user: String) -> NSManagedObject? {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: UserCardDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "cardId == %d AND user == %@", cardId, user)
        do {
            if let result = try viewContext.fetch(fetchRequest).first {
                return result
            }
        } catch {
            return nil
        }
        return nil
    }
    
    
    
    func fetchAllUserCard(user: String) -> [UserCardDataModel]? {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: UserCardDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
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
    
    func fetchAllUsers() -> NSOrderedSet {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: UserCardDataModel.entityName)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            var userSet = Set<String>.init()
            for result in results {
                let user = result.value(forKey: "user") as! String
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
    func addUserCard(card: UserCardDataModel, checkExist: Bool = true) {
        
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
            if let _ = fetchUserCardManagedObject(withCardId: card.cardId, user: card.user) {
                return
            } else {
                add(card: card)
            }
        }
    }
}

// MARK: - remove method
extension UserCardStorageHelper {
    func removeUserCard(withCardId cardId: Int, user: String) {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        if let managedObject = fetchUserCardManagedObject(withCardId: cardId, user: user) {
            viewContext.delete(managedObject)
            doSave()
        }
    }
    func removeAllUserCards(user: String) {
        let viewContext = UserCardCoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>.init(entityName: UserCardDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
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


