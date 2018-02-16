//
//  ApiRequestParamProtocol.swift
//  SIFTool
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
protocol CardApiRequestParamProtocol {
    static func requestPage(_ page: Int, pageSize: Int) -> ApiRequestParam 
}

protocol IdolApiRequestParamProtocol {
    static func requestPage(_ page: Int, pageSize: Int) -> ApiRequestParam
    static func requestIdol(withEnglishName englishName: String) -> ApiRequestParam
}
