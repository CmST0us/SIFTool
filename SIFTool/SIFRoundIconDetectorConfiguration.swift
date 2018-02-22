//
//  SIFRoundIconDetectorConfiguration.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/21.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
struct SIFRoundIconDetectorConfiguration {
    var patternWidth: Double = 1.0
    var patternHeight: Double = 1.0
    
    var patternLeft: Double = 1.0
    var patternRight: Double = 1.0
    var patternTop: Double = 1.0
    var patternBottom: Double = 1.0
    
    static var defaultRoundIconConfiguration: SIFRoundIconDetectorConfiguration {
        return SIFRoundIconDetectorConfiguration.init(patternWidth: 80.0, patternHeight: 80.0, patternLeft: 15.0, patternRight: 17.0, patternTop: 16.0, patternBottom: 15.0)
    }
    
    var patternSize: CGSize {
        return CGSize.init(width: patternWidth, height: patternHeight)
    }
    var patternRealSize: CGSize {
        return CGSize.init(width: patternRealWidth, height: patternRealHeight)
    }
    
    var patternRealWidth: Double {
        return patternWidth - patternLeft - patternRight
    }
    
    var patternRealHeight: Double {
        return patternHeight - patternTop - patternBottom
    }
    
    var patternRealRect: CGRect {
        return CGRect.init(x: CGFloat(patternLeft), y: CGFloat(patternTop), width: CGFloat(patternRealWidth), height: CGFloat(patternRealHeight))
    }
}
