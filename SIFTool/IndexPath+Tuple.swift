//
//  IndexPath+Tuple.swift
//  LLInfo
//
//  Created by CmST0us on 2018/1/6.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension IndexPath {
    var tuple: (Int, Int) {
        return (self.section, self.row)
    }
}
