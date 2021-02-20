//
//  YCVideoEncoder.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "YCAVConfig.h"

/**h264编码回调代理*/
@protocol YCVideoEncoderDelegate <NSObject>
//Video-H264数据编码完成回调
- (void)videoEncodeCallback:(NSData *)h264Data;
//Video-SPS&PPS数据编码回调
- (void)videoEncodeCallbacksps:(NSData *)sps pps:(NSData *)pps;
@end

/**h264硬编码器 (编码和回调均在异步队列执行)*/
@interface YCVideoEncoder : NSObject
@property (nonatomic, strong) YCVideoConfig *config;
@property (nonatomic, weak) id<YCVideoEncoderDelegate> delegate;

- (instancetype)initWithConfig:(YCVideoConfig*)config;
/**编码*/
-(void)encodeVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
