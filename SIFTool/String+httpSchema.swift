//
//  String+httpSchema.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/15.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension String {
    func addHttpSchemaString() -> String {
        if self.prefix(2) == "//" {
            return "http:\(self)"
        }
        return self
    }
}
