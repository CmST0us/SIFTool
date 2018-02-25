//
//  SIFCacheHelper.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/23.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

#if TARGET_OS_IPHONE
import UIKit
#else
typealias UIImage = NSImage
#endif

struct SIFCacheHelperError: Error {
    enum SIFCacheHelperErrorType {
        case notInitial
    }
    
    var localizedDescription: String = ""
    var code: SIFCacheHelperErrorType = .notInitial
}

class SIFCacheHelper {
    private init() {
        
    }
    
    static var shared: SIFCacheHelper = SIFCacheHelper()
    
    var imageCache = NSCache<NSString, UIImage>()
    
    var cacheDirectory: String = NSTemporaryDirectory()
    
    lazy var cards: [Int: CardDataModel] = {
        if let data = NSData(contentsOfFile: self.cacheDirectory.appendingPathComponent("cards.json")) as Data? {
            if let dictArray = DataModelHelper.shared.array(withJsonData: data) as? [Dictionary<String, Any>] {
                var tCard: [Int: CardDataModel] = [:]
                for dict in dictArray {
                    let card = CardDataModel(withDictionary: dict)
                    tCard[card.id] = card
                }
                return tCard
            }
        }
        return [:]
    }()
    
    func cacheCards(process: (Int, Int) -> Void) throws {
        var page = 1
        var currentCardIndex = 1
        var haveNext = true
        let results: NSMutableArray = NSMutableArray()
        do {
            //request total cards id
                let totalCardsIdParam = CardDataModel.requestIds()
            let totalCardsIdData = try ApiHelper.shared.request(param: totalCardsIdParam)
            let cardIdsArray = DataModelHelper.shared.array(withJsonData: totalCardsIdData) as! [Int]
            
            while haveNext {
                let p = CardDataModel.requestPage(page, pageSize: 100)
                let data = try ApiHelper.shared.request(param: p)
                if DataModelHelper.shared.next(withJsonData: data) == nil {
                    haveNext = false
                }
                if let dicts = DataModelHelper.shared.resultsDictionaries(withJsonData: data) {
                    for dict in dicts {
                        let card = CardDataModel(withDictionary: dict)
                        self.cards[card.id] = card
                        process(currentCardIndex, cardIdsArray.count)
                        currentCardIndex += 1
                    }
                    results.addObjects(from: dicts)
                }
                Logger.shared.output("page \(page) download ok")
                page += 1
            }
            Logger.shared.output("all page download ok")
            let jsonData = try JSONSerialization.data(withJSONObject: results, options: [.prettyPrinted])
            try jsonData.write(to: URL.init(fileURLWithPath: self.cacheDirectory.appendingPathComponent("cards.json")))
        } catch {
            cards.removeAll(keepingCapacity: true)
            throw error
        }
    }
    
    var isCardsCached: Bool {
        if self.cards.count == 0 {
            return false
        }
        return true
    }
    
    func image(withUrl url: URL?, refresh: Bool = false) -> UIImage? {
        if let u = url {
            let fileName = u.lastPathComponent
            //check cache
            if let cacheImage = imageCache.object(forKey: fileName as NSString) {
                Logger.shared.output("read \(fileName) from nscache")
                return cacheImage
            }
            
            let filePath = self.cacheDirectory.appendingPathComponent(fileName)
            if !refresh {
                if let data = NSData.init(contentsOfFile: filePath) as Data? {
                    Logger.shared.output("read \(fileName) from disk cache")
                    if let image = UIImage.init(data: data) {
                        imageCache.setObject(image, forKey: fileName as NSString)
                        return image
                    }
                }
            }
            
            Logger.shared.output("request \(fileName) from network")
            if let data = NSData.init(contentsOf: u) {
                if let image = UIImage.init(data: data as Data) {
                    imageCache.setObject(image, forKey: fileName as NSString)
                    do {
                        try data.write(toFile: filePath, options: .atomic)
                    } catch {
                        Logger.shared.output(error.localizedDescription)
                    }
                    return image
                }
            }
            return nil
        }
        Logger.shared.output("not specific url")
        return nil
    }
    
    
    
}

