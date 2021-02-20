//
//  YCAudioEncoder.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class YCAudioConfig;

/**AAC编码器代理*/
@protocol YCAudioEncoderDelegate <NSObject>
- (void)audioEncodeCallback:(NSData *)aacData;
@end

/**AAC硬编码器 (编码和回调均在异步队列执行)*/
@interface YCAudioEncoder : NSObject

/**编码器配置*/
@property (nonatomic, strong) YCAudioConfig *config;
@property (nonatomic, weak) id<YCAudioEncoderDelegate> delegate;

/**初始化传入编码器配置*/
- (instancetype)initWithConfig:(YCAudioConfig*)config;

/**编码*/
- (void)encodeAudioSamepleBuffer: (CMSampleBufferRef)sampleBuffer;
@end
