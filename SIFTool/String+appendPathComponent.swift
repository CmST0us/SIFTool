//
//  String+appendUrlComponent.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/24.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension String {
    func appendingPathComponent(_ p: String) -> String {
        let string = self as NSString
        return string.appendingPathComponent(p)
    }
}
