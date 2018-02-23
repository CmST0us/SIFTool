//
//  SIFImageCacheHelper.swift
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

class SIFImageCacheHelper {
    private init() {
        
    }
    
    static var shared: SIFImageCacheHelper = SIFImageCacheHelper()
    
    var cacheDirectory: String = NSTemporaryDirectory()
    
    func image(withUrl url: URL?, refresh: Bool = false) -> UIImage? {
        if let u = url {
            let fileName = u.lastPathComponent
            let filePath = self.cacheDirectory + fileName
            if !refresh {
                if let data = NSData.init(contentsOfFile: filePath) as Data? {
                    Logger.shared.console("read \(fileName) from cache")
                    return UIImage.init(data: data)
                }
            }
            Logger.shared.output("request \(fileName) from network")
            return UIImage.init(contentsOf: u)
        }
        Logger.shared.output("not specific url")
        return nil
    }
    
}


