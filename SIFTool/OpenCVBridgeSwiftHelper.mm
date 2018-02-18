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

- (CVMat *)emptyImageWithSize:(CGSize)size
                      channel:(int)channel{
    auto m = [[CVMat alloc] init];
    m.mat = cv::Mat::zeros(size.height, size.width, CV_8UC(channel));
    return m;
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
    auto outputMat = [[CVMat alloc] init];
    auto s = cv::Size(size.width, size.width);
    cv::GaussianBlur(mat.mat, outputMat.mat, s, sigmaX, sigmaY, type);
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

- (NSArray *)findContoursWithImage:(CVMat *)mat
                            mode:(CVBridgeRetrievalMode)mode
                          method:(CVBridgeApproximationMode)method
                     offsetPoint:(CGPoint)point {
    auto outputMat = [[CVMat alloc] init];
    auto offsetPoint = cv::Point(point.x, point.y);
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(mat.mat, contours, hierarchy, mode, method, offsetPoint);
    
    auto points = [NSMutableArray array];
    for(int i = 0; i < contours.size(); i++) {
        auto pointPerContours = [NSMutableArray array];
        for(int j = 0; j < contours[i].size(); j++){
            NSPoint tp;
            tp.x = contours[i][j].x; tp.y = contours[i][j].y;
            auto value = [NSValue valueWithPoint:tp];
            [pointPerContours addObject:value];
        }
        [points addObject:pointPerContours];
    }
    
    return points;
}

- (CVMat *)morphologyExWithImage:(CVMat *)mat
                       operation:(CVBridgeMorphType)operation
                    elementSharp:(CVBridgeMorphShape)sharp
                     elementSize:(CGSize)size
                    elementPoint:(CGPoint)point {
    cv::Size s;
    s.height = size.height;
    s.width = size.width;
    cv::Point p;
    p.x = point.x;
    p.y = point.y;
    cv::Mat element = cv::getStructuringElement(sharp, s);
    auto output = [[CVMat alloc] init];
    cv::morphologyEx(mat.mat, output.mat, operation, element);
    return output;
}
#pragma mark - 绘制方法
- (CVMat *)drawRectWithImage:(CVMat *)mat
                      rect:(CGRect)rect
                         r:(double)r
                         g:(double)g
                         b:(double)b {
    cv::Rect rec;
    rec.x = rect.origin.x;
    rec.y = rect.origin.y;
    rec.height = rect.size.height;
    rec.width = rect.size.width;
    cv::Scalar s(r, g, b);
    auto output = [[CVMat alloc] init];
    output.mat = mat.mat.clone();
    cv::rectangle(output.mat, rec, s);
    return output;
}

- (void)drawRectInImage:(CVMat *)mat
                   rect:(CGRect)rect
                      r:(double)r
                      g:(double)g
                      b:(double)b {
    cv::Rect rec;
    rec.x = rect.origin.x;
    rec.y = rect.origin.y;
    rec.height = rect.size.height;
    rec.width = rect.size.width;
    cv::Scalar s(r, g, b);
    cv::rectangle(mat.mat, rec, s);
}
@end
