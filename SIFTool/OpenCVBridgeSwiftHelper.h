//
//  OpenCVBridgeSwiftHelper.h
//  SIFTool
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CVMat.h"

typedef NS_ENUM(NSInteger, CVBridgeBorderType) {
    CVBridgeBorderTypeDefault
};


/**
 Bridge to cv::ColorConversionCodes

 - CVBridgeColorCovertTypeBGR2Gray: the same as COLOR_BGR2GRAY(6)
 */
typedef NS_ENUM(NSInteger, CVBridgeColorCovertType) {
    CVBridgeColorCovertTypeBGR2Gray = 6
};


/**
 Bridge to cv::ThresholdTypes

 - CVBridgeThresholdTypeBIN: the same as THRESH_BINARY(1)
 */
typedef NS_ENUM(NSInteger, CVBridgeThresholdType) {
    CVBridgeThresholdTypeBinary = 0
};

typedef NS_ENUM(NSInteger, CVBridgeRetrievalMode) {
    /** retrieves only the extreme outer contours. It sets `hierarchy[i][2]=hierarchy[i][3]=-1` for
     all the contours. */
    CVBridgeRetrievalModeExternal = 0,
    /** retrieves all of the contours without establishing any hierarchical relationships. */
    CVBridgeRetrievalModeList      = 1,
    /** retrieves all of the contours and organizes them into a two-level hierarchy. At the top
     level, there are external boundaries of the components. At the second level, there are
     boundaries of the holes. If there is another contour inside a hole of a connected component, it
     is still put at the top level. */
    CVBridgeRetrievalModeCcomp     = 2,
    /** retrieves all of the contours and reconstructs a full hierarchy of nested contours.*/
    CVBridgeRetrievalModeTree      = 3,
    CVBridgeRetrievalModeFloodFill = 4 //!<
};

//! the contour approximation algorithm
typedef NS_ENUM(NSInteger, CVBridgeApproximationMode) {
    /** stores absolutely all the contour points. That is, any 2 subsequent points (x1,y1) and
     (x2,y2) of the contour will be either horizontal, vertical or diagonal neighbors, that is,
     max(abs(x1-x2),abs(y2-y1))==1. */
    CVBridgeApproximationModeNone = 1,
    /** compresses horizontal, vertical, and diagonal segments and leaves only their end points.
     For example, an up-right rectangular contour is encoded with 4 points. */
    CVBridgeApproximationModeSimple = 2,
    /** applies one of the flavors of the Teh-Chin chain approximation algorithm @cite TehChin89 */
    CVBridgeApproximationModeTC89_L1 = 3,
    /** applies one of the flavors of the Teh-Chin chain approximation algorithm @cite TehChin89 */
    CVBridgeApproximationModeTC89_KCOS = 4
};


@interface OpenCVBridgeSwiftHelper: NSObject
+ (instancetype _Nonnull)sharedInstance;

- (CVMat * _Nonnull )readImageWithNamePath: (NSString * _Nonnull)namePath;

- (BOOL)saveImage:(CVMat * _Nonnull)mat
         fileName:(NSString * _Nonnull)fileName;

@end

#pragma mark - 图像处理方法
@interface OpenCVBridgeSwiftHelper(imageProcMethod)

/**
 高斯模糊

 @param mat 图像输入矩阵
 @param size 高斯模糊内核大小
 @param sigmaX 高斯核函数在X方向上的标准偏差
 @param sigmaY 高斯核函数在Y方向上的标准偏差，如果sigmaY是0，则函数会自动将sigmaY的值设置为与sigmaX相同的值，如果sigmaX和sigmaY都是0，这两个值将由ksize.width和ksize.height计算而来
 @param type 推断图像外部像素的某种便捷模式
 @return 高斯模糊后的图像矩阵
 */
- (CVMat * _Nonnull)gaussianBlurWithImage:(CVMat * _Nonnull)mat
                               kernelSize:(NSSize)size
                                   sigmaX:(double)sigmaX
                                   sigmaY:(double)sigmaY
                               borderType:(CVBridgeBorderType)type;


/**
 Canny边缘检测

 @param mat 图像输入矩阵
 @param lowThreshold first threshold for the hysteresis procedure
 @param highThreshold second threshold for the hysteresis procedure.
 @return Canny边缘检测后图像矩阵
 */
- (CVMat * _Nonnull)cannyWithImage:(CVMat * _Nonnull)mat
                      lowThreshold:(double)lowThreshold
                     highThreshold:(double)highThreshold;



/**
 色彩转换

 @param mat 图像输入矩阵
 @param type 目标色彩
 @return 转换后的图像矩阵
 */
- (CVMat * _Nonnull)covertColorWithImage:(CVMat * _Nonnull)mat
                             targetColor:(CVBridgeColorCovertType)type;



/**
 二值化

 @param mat 图像输入矩阵
 @param thresh 阈值
 @param maxValue 最大值
 @param type 二值化方式
 @return 二值化后的图像矩阵
 */
- (CVMat * _Nonnull)thresholdWithImage:(CVMat * _Nonnull)mat
                                thresh:(double)thresh
                              maxValue:(double)maxValue
                                  type:(CVBridgeThresholdType)type;

- (CVMat * _Nonnull)findContoursWithImage:(CVMat * _Nonnull)mat
                                     mode:(CVBridgeRetrievalMode)mode
                                   method:(CVBridgeApproximationMode)method
                              offsetPoint:(CGPoint)point;
@end
