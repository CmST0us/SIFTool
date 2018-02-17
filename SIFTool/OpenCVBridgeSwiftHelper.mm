//
//  OpenCVBridgeSwiftHelper.mm
//  SIFTool
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import <vector>
#import "CVMat.h"
#import "OpenCVBridgeSwiftHelper.h"

@implementation CVMat {
    cv::Mat _mat;
}

- (void)setMat:(cv::Mat)mat {
    _mat = mat;
}

- (cv::Mat &)mat {
    return _mat;
}

@end

@implementation OpenCVBridgeSwiftHelper

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

+ (instancetype)sharedInstance {
    static OpenCVBridgeSwiftHelper *instance;
    if (instance == NULL) {
        instance = [[OpenCVBridgeSwiftHelper alloc] init];
    }
    return instance;
}

- (CVMat *)readImageWithNamePath: (NSString *)namePath {
    auto str = cv::String([namePath cStringUsingEncoding: NSUTF8StringEncoding]);
    cv::Mat mat = cv::imread(str);
    auto cvMat = [[CVMat alloc] init];
    cvMat.mat = mat;
    return cvMat;
}

- (BOOL)saveImage:(CVMat *)mat
         fileName:(NSString *)fileName {
    auto str = cv::String([fileName cStringUsingEncoding:NSUTF8StringEncoding]);
    return cv::imwrite(str, mat.mat);
}

- (void)showImage:(CVMat *)mat windowName:(NSString *)name {
    auto str = cv::String([name cStringUsingEncoding:NSUTF8StringEncoding]);
    cv::namedWindow(str);
    cv::imshow(str, mat.mat);
}

#pragma mark - 图像处理方法
- (CVMat *)gaussianBlurWithImage:(CVMat *)mat
                      kernelSize:(NSSize)size
                          sigmaX:(double)sigmaX
                          sigmaY:(double)sigmaY
                      borderType:(CVBridgeBorderType)type {
    auto t = cv::BORDER_DEFAULT;
    switch (type) {
        case CVBridgeBorderTypeDefault:
            t = cv::BORDER_DEFAULT;
            break;
        default:
            break;
    }
    auto outputMat = [[CVMat alloc] init];
    auto s = cv::Size(size.width, size.width);
    cv::GaussianBlur(mat.mat, outputMat.mat, s, sigmaX, sigmaY, t);
    return outputMat;
}

- (CVMat *)cannyWithImage:(CVMat *)mat
             lowThreshold:(double)lowThreshold
            highThreshold:(double)highThreshold {
    auto outputMat = [[CVMat alloc] init];
    cv::Canny(mat.mat, outputMat.mat, lowThreshold, highThreshold);
    return outputMat;
}

- (CVMat *)covertColorWithImage:(CVMat *)mat
                    targetColor:(CVBridgeColorCovertType)type {
    auto outputMat = [[CVMat alloc] init];
    cv::cvtColor(mat.mat, outputMat.mat, type);
    return outputMat;
}

- (CVMat *)thresholdWithImage:(CVMat *)mat
                       thresh:(double)thresh
                     maxValue:(double)maxValue
                         type:(CVBridgeThresholdType)type {
    auto outputMat = [[CVMat alloc] init];
    cv::threshold(mat.mat, outputMat.mat, thresh, maxValue, type);
    return outputMat;
}

- (CVMat *)findContoursWithImage:(CVMat *)mat
                            mode:(CVBridgeRetrievalMode)mode
                          method:(CVBridgeApproximationMode)method
                     offsetPoint:(CGPoint)point {
    auto outputMat = [[CVMat alloc] init];
    auto p = cv::Point(point.x, point.y);
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(mat.mat, contours, hierarchy, mode, method, p);
    
    outputMat.mat = cv::Mat::zeros(mat.mat.size(), CV_8UC1);
    for (int i = 0; i < contours.size(); i++) {
        for(int j = 0; j < contours[i].size(); j++){
            cv::Point po = cv::Point(contours[i][j].x, contours[i][j].y);
            outputMat.mat.at<uchar>(po) = 255;
        }
    }
    
    return outputMat;
}
@end
