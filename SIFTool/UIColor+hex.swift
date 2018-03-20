//
//  UIColor+hex.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/20.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
extension UIColor {
    
    convenience init?(hex: String) {
        
        if let firstChar = hex.first, firstChar == "#" {
            let drop = hex.dropFirst()
            var a: [Int] = []
            
            for i in 0 ..< 3 {
                let startIndex = drop.index(drop.startIndex, offsetBy: i * 2)
                let offsetTo = drop.index(startIndex, offsetBy: 2)
                let component = drop[startIndex ..< offsetTo]
                let str = component.uppercased()
                var sum = 0
                for j in str.utf8 {
                    sum = sum * 16 + Int(j) - 48
                    if j >= 65 {
                        sum -= 7
                    }
                }
                a.append(sum)
            }
            
            let b = a.map { item in
                CGFloat(item) / 255
            }
            self.init(red: b[0], green: b[1], blue: b[2], alpha: 1.0)
        } else {
            return nil
        }
        
    }
    
}

extension UIColor {
    
    static let buttonOff = UIColor.init(hex: "#D8D8D8")!
    static let buttonOn = UIColor.init(hex: "#7ED321")!
    
}
