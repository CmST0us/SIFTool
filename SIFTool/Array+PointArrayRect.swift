//
//  Array+PointArrayRect.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/19.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension Array where Element == NSValue {
    func contoursRect() -> CGRect {
        var minPointX = CGFloat.greatestFiniteMagnitude
        var minPointY = CGFloat.greatestFiniteMagnitude
        var maxPointX = CGFloat.leastNormalMagnitude
        var maxPointY = CGFloat.leastNormalMagnitude
        for v in self {
            #if iOS
                let p = v.cgPointValue
            #elseif macOS
                let p = v.pointValue
            #endif
            maxPointX = Swift.max(p.x, maxPointX)
            maxPointY = Swift.max(p.y, maxPointY)
            minPointX = Swift.min(p.x, minPointX)
            minPointY = Swift.min(p.y, minPointY)
        }
        let weight = maxPointX - minPointX
        let height = maxPointY - minPointY
        
        let rect = CGRect(x: minPointX, y: minPointY, width: weight, height: height)
        return rect
    }
}

