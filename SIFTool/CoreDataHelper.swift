//
//  InformationCoreDataHelper.swift
//  LLInfo
//
//  Created by CmST0us on 2018/1/7.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
import CoreData

class CardCoreDataHelper {
    //MARK: - Private Member
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CardCoreDataHelper.coreDataModelFileName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                //[TODO] handle error, remember do not use fatalError when shipping
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - Private Method
    private init() {
        
    }
    //MARK: - Public Member
    private static let coreDataModelFileName = "card"
    //    static let coreDataModelFileName = "test"
    
    //MARK: Single Instance
    static let shared = CardCoreDataHelper()
    
    
    //MARK: - Public Method
    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
}
