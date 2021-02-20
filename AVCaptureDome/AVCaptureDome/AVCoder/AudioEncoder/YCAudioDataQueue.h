//
//  YCAudioDataQueue.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCAudioDataQueue : NSObject
@property (nonatomic, readonly) int count;

+(instancetype) shareInstance;

- (void)addData:(id)obj;

- (id)getData;
@end
