//
//  YCVideoConfig.m
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import "YCAVConfig.h"

@implementation YCAudioConfig

+ (instancetype)defaultConifg {
    return  [[YCAudioConfig alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bitrate = 96000;
        self.channelCount = 1;
        self.sampleSize = 16;
        self.sampleRate = 44100;
    }
    return self;
}
@end
@implementation YCVideoConfig

+ (instancetype)defaultConifg {
    return [[YCVideoConfig alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = 480;
        self.height = 640;
        self.bitrate = 640*1000;
        self.fps = 25;
    }
    return self;
}
@end

