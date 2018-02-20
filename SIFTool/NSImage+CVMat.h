//
//  NSImage+NSImage_CVMat.h
//  SIFTool
//
//  Created by CmST0us on 2018/2/19.
//  Copyright © 2018年 eki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface NSImage (CVMat)
@property (nonatomic, readonly) CVMat * _Nonnull mat;
+ (NSImage * _Nonnull)imageWithCVMat:(CVMat * _Nonnull)mat;
@end
