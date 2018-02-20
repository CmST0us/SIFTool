//
//  CVMat.h
//  SIFTool
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface CVMat: NSObject

- (CVMat * _Nonnull)clone;
- (CGSize)size;
- (int)channels;
- (CVMat * _Nonnull)roiAt:(CGRect)rect;
- (void)fillBy:(CVMat * _Nonnull)mat;
@end
