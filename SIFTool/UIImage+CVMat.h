//
//  NSImage+UIImage_CVMat.h
//  SIFTool
//
//  Created by CmST0us on 2018/3/11.
//  Copyright © 2018年 eki. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (CVMat)

@property (nonatomic, readonly, nonnull) CVMat *mat;
+ (nonnull UIImage *)imageWithCVMat:(nonnull CVMat *)mat;

@end

#endif
