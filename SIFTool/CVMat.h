//
//  CVMat.h
//  SIFTool
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface CVMat: NSObject

- (nonnull CVMat *)clone;

- (CGSize)size;
- (int)channels;

- (nonnull CVMat *)roiAt:(CGRect)rect;

- (float)floatValueAt:(CGPoint)point;
- (void)setFloatValue:(float)value at:(CGPoint)point;

- (unsigned char)ucharValueAt:(CGPoint)point;
- (void)setUcharValue:(unsigned char)value at:(CGPoint)point;

- (void)fillBy:(nonnull CVMat *)mat;

@end
