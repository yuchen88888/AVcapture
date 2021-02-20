//
//  YCSystemCapture.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//捕获类型
typedef NS_ENUM(int,YCSystemCaptureType){
    YCSystemCaptureTypeVideo = 0,
    YCSystemCaptureTypeAudio,
    YCSystemCaptureTypeAll
};

@protocol YCSystemCaptureDelegate <NSObject>
@optional
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type: (YCSystemCaptureType)type;

@end

/**捕获音视频*/
@interface YCSystemCapture : NSObject
/**预览层*/
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, weak) id<YCSystemCaptureDelegate> delegate;
/**捕获视频的宽*/
@property (nonatomic, assign, readonly) NSUInteger witdh;
/**捕获视频的高*/
@property (nonatomic, assign, readonly) NSUInteger height;

- (instancetype)initWithType:(YCSystemCaptureType)type;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/** 准备工作(只捕获音频时调用)*/
- (void)prepare;
//捕获内容包括视频时调用（预览层大小，添加到view上用来显示）
- (void)prepareWithPreviewSize:(CGSize)size;

/**开始*/
- (void)start;
/**结束*/
- (void)stop;
/**切换摄像头*/
- (void)changeCamera;


//授权检测
+ (int)checkMicrophoneAuthor;
+ (void)checkCameraAuthorComple:(void(^)(int num))comple;

@end
