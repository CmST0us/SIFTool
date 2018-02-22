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
        return defaultRoundIconConfiguration(radio: 1)
    }
    
    static var defaultRadioRoundIconConfiguration: SIFRoundIconDetectorConfiguration {
        return SIFRoundIconDetectorConfiguration.init(patternWidth: 40.0, patternHeight: 40.0, patternLeft: 7.5, patternRight: 8.5, patternTop: 8, patternBottom: 7.5)
    }
    
    static func defaultRoundIconConfiguration(radio: Double ) -> SIFRoundIconDetectorConfiguration {
        return SIFRoundIconDetectorConfiguration.init(patternWidth: 80.0 * radio, patternHeight: 80.0 * radio, patternLeft: 15.0 * radio, patternRight: 17.0 * radio, patternTop: 16.0 * radio, patternBottom: 15.0 * radio)
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
