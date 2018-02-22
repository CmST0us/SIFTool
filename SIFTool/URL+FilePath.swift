//
//  URL+FilePath.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/23.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension URL {
    func filePath() -> String? {
        if self.isFileURL {
            let string = self.absoluteString
            let startIndex = string.index(string.startIndex, offsetBy: 7)
            let endIndex = string.endIndex
            return String(string[startIndex ..< endIndex])
        } else {
            return nil
        }
    }
}
