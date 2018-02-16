//
//  OpenCVBridgeSwiftHelper.m
//  SIFTool
//
//  Created by CmST0us on 2018/2/17.
//  Copyright © 2018年 eki. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <opencv2/opencv.hpp>

@interface OpenCVBridgeSwiftHelper: NSObject {
    
}

+ (instancetype)sharedInstance;

- (cv::Mat)readImageWithNamePath: (NSString *)namePath;
@end

@interface OpenCVBridgeSwiftHelper() {
    
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

- (cv::Mat)readImageWithNamePath: (NSString *)namePath {
    auto str = cv::String([namePath cStringUsingEncoding: NSUTF8StringEncoding]);
    return cv::imread(str);
}

@end
