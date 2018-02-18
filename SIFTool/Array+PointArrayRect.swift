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
            let p = v.pointValue;
            if p.x > maxPointX {
                maxPointX = p.x
            }
            if p.y > maxPointY {
                maxPointY = p.y
            }
            if p.x < minPointX {
                minPointX = p.x
            }
            if p.y < minPointY {
                minPointY = p.y
            }
        }
        let weight = maxPointX - minPointX
        let height = maxPointY - minPointY
        
        let rect = CGRect(x: minPointX, y: minPointY, width: weight, height: height)
        return rect
    }
}
