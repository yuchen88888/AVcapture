//
//  YCVideoDecoder.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "YCAVConfig.h"

/**h264解码回调代理*/
@protocol YCVideoDecoderDelegate <NSObject>
//解码后H264数据回调
- (void)videoDecodeCallback:(CVPixelBufferRef)imageBuffer;
@end

@interface YCVideoDecoder : NSObject
@property (nonatomic, strong) YCVideoConfig *config;
@property (nonatomic, weak) id<YCVideoDecoderDelegate> delegate;

/**初始化解码器**/
- (instancetype)initWithConfig:(YCVideoConfig*)config;

/**解码h264数据*/
- (void)decodeNaluData:(NSData *)frame;
@end
