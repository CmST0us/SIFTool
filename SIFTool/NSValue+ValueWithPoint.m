//
//  NSValue+ValueWithPoint_h.m
//  SIFTool
//
//  Created by CmST0us on 2018/3/15.
//  Copyright © 2018年 eki. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NSValue+ValueWithPoint.h"

@implementation NSValue (ValueWithPoint)
+ (NSValue *)valueWithPoint:(CGPoint)point {
    return [NSValue valueWithCGPoint:point]
}
@end
#endif
