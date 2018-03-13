//
//  NSImage+NSImage_CVMat.h
//  SIFTool
//
//  Created by CmST0us on 2018/2/19.
//  Copyright © 2018年 eki. All rights reserved.
//

#if TARGET_OS_OSX

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface NSImage (CVMat)

@property (nonatomic, readonly, nonnull) CVMat *mat;
+ (nonnull NSImage *)imageWithCVMat:(nonnull CVMat *)mat;

@end

#endif
