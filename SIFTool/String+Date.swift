//
//  String+Date.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/15.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension String {
    func dateObj(withFormat format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
