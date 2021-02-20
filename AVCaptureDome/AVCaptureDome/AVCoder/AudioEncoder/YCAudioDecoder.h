//
//  YCAudioDecoder.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class YCAudioConfig;

/**AAC解码回调代理*/
@protocol YCAudioDecoderDelegate <NSObject>
- (void)audioDecodeCallback:(NSData *)pcmData;
@end

@interface YCAudioDecoder : NSObject
@property (nonatomic, strong) YCAudioConfig *config;
@property (nonatomic, weak) id<YCAudioDecoderDelegate> delegate;

//初始化 传入解码配置
- (instancetype)initWithConfig:(YCAudioConfig *)config;

/**解码aac*/
- (void)decodeAudioAACData: (NSData *)aacData;
@end
