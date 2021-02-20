//
//  YCAudioPCMPlayer.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YCAudioConfig;
@interface YCAudioPCMPlayer : NSObject

- (instancetype)initWithConfig:(YCAudioConfig *)config;
/**播放pcm*/
- (void)playPCMData:(NSData *)data;
/** 设置音量增量 0.0 - 1.0 */
- (void)setupVoice:(Float32)gain;
/**销毁 */
- (void)dispose;

@end
