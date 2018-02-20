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
    var patternRadio: Double = 1.0
    
    static var defaultRoundIconConfiguration: SIFRoundIconDetectorConfiguration {
        return SIFRoundIconDetectorConfiguration.init(patternWidth: 80, patternHeight: 80, patternRadio: 0.5)
    }
    
    var patternRealSize: CGSize {
        return CGSize.init(width: patternWidth * patternRadio, height: patternHeight * patternRadio)
    }
    
    var patternRealWidth: Double {
        return patternWidth * patternRadio
    }
    
    var patternRealHeight: Double {
        return patternHeight * patternRadio
    }
}
