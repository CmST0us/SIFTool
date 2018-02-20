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
#import "NSImage+CVMat.h"

@implementation CVMat {
    cv::Mat _mat;
}

- (void)setMat:(cv::Mat)mat {
    _mat = mat;
}

- (cv::Mat &)mat {
    return _mat;
}

- (CVMat *)clone {
    auto m = [[CVMat alloc] init];
    m.mat = self.mat.clone();
    return m;
}

- (CGSize)size {
    return CGSizeMake(self.mat.cols, self.mat.rows);
}

- (int)channels {
    return _mat.channels();
}

- (CVMat *)roiAt:(CGRect)rect {
    cv::Rect r;
    r.width = rect.size.width;
    r.height = rect.size.height;
    r.x = rect.origin.x;
    r.y = rect.origin.y;
    
    auto m = [[CVMat alloc] init];
    m.mat = _mat(r);
    return m;
}

- (void)fillBy:(CVMat *)mat {
    cv::resize(mat.mat, mat.mat, cv::Size(_mat.cols, _mat.rows));
    mat.mat.copyTo(_mat);
}

@end

@implementation NSImage (CVMat)
- (CGImageRef)cgImage {
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [self size].width,
                                                   [self size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [self drawInRect:NSMakeRect(0,0, [self size].width, [self size].height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);
    return cgImage;
}

- (CVMat *)mat {
    CGImageRef imageRef = [self cgImage];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    
    auto mat = [[CVMat alloc] init];
    mat.mat = cvMat;
    return mat;
}

+ (NSImage *)imageWithCVMat:(CVMat *)mat {
    NSData *data = [NSData dataWithBytes:mat.mat.data length:mat.mat.elemSize() * mat.mat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (mat.mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(mat.mat.cols,                                     // Width
                                        mat.mat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * mat.mat.elemSize(),                           // Bits per pixel
                                        mat.mat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
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

- (NSArray *)splitImage:(CVMat *)mat {
    auto array = [NSMutableArray arrayWithCapacity:4];
    cv::Mat channel[4];
    cv::split(mat.mat, channel);
    for (int i = 0; i < mat.channels; i++) {
        auto m = [[CVMat alloc] init];
        m.mat = channel[i];
        [array addObject:m];
    }
    return array;
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

- (CVMat *)morphologyExWithImage:(CVMat *)mat
                       operation:(CVBridgeMorphType)operation
                      iterations:(int)iterations
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
    cv::morphologyEx(mat.mat, output.mat, operation, element, cv::Point(-1, -1), iterations);
    return output;
}

- (CVMat *)cropWithImage:(CVMat *)mat
                  byRect:(CGRect)rect {
    auto output = [[CVMat alloc] init];
    output.mat = mat.mat(cv::Range(rect.origin.y, rect.origin.y + rect.size.height + 1), cv::Range(rect.origin.x, rect.size.width + rect.origin.x + 1)).clone();
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
