//
//  SIFCacheTest.swift
//  SIFToolTest
//
//  Created by CmST0us on 2018/3/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import XCTest
import Gzip
class SIFCacheTest: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
        SIFCacheHelper.shared.cacheDirectory = NSTemporaryDirectory()
        
    }
    
    override func tearDown() {
    
        super.tearDown()
        
    }
    
}


// MARK: - Test Gizp
extension SIFCacheTest {
    
    func testGzip() {
        
    }
    
}
