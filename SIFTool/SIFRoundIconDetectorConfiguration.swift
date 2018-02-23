//
//  SIFRoundIconDetectorConfiguration.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/21.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
struct SIFRoundIconDetectorConfiguration {
    var patternWidth = 1
    var patternHeight = 1
    
    var patternLeft = 1
    var patternRight = 1
    var patternTop = 1
    var patternBottom = 1
    
    static var defaultRoundIconConfiguration: SIFRoundIconDetectorConfiguration {
        return defaultRoundIconConfiguration(radio: 1)
    }
    
    static func defaultRoundIconConfiguration(radio: Double ) -> SIFRoundIconDetectorConfiguration {
        return SIFRoundIconDetectorConfiguration.init(patternWidth: Int(80.0 * radio), patternHeight: Int(80.0 * radio), patternLeft: Int(15.0 * radio), patternRight: Int(17.0 * radio), patternTop: Int(16.0 * radio), patternBottom: Int(15.0 * radio))
    }
    
    var patternSize: CGSize {
        return CGSize.init(width: patternWidth, height: patternHeight)
    }
    var patternRealSize: CGSize {
        return CGSize.init(width: patternRealWidth, height: patternRealHeight)
    }
    
    var patternRealWidth: Int {
        return patternWidth - patternLeft - patternRight
    }
    
    var patternRealHeight: Int {
        return patternHeight - patternTop - patternBottom
    }
    
    var patternRealRect: CGRect {
        return CGRect.init(x: CGFloat(patternLeft), y: CGFloat(patternTop), width: CGFloat(patternRealWidth), height: CGFloat(patternRealHeight))
    }
}
