//
//  NSValue+pointValue.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/15.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension NSValue {
    #if iOS
    var pointValue: CGPoint {
        return self.cgPointValue
    }
    #endif
}
