//
//  Bridge.h
//  SIFTool
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//
#import "CVMat.h"
#import "OpenCVBridgeSwiftHelper.h"

#if TARGET_OS_IPHONE
#import "UIImage+CVMat.h"
#elif TARGET_OS_OSX
#import "NSImage+CVMat.h"
#endif
