//
//  NSValue+ValueWithPoint_h.h
//  SIFTool
//
//  Created by CmST0us on 2018/3/15.
//  Copyright © 2018年 eki. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSValue (ValueWithPoint)
+ (nonnull NSValue *)valueWithPoint:(CGPoint)point;
@end

#endif
