//
//  AAPLEAGLLayer.h
//  001-Demo
//
//  Created by YC on 2019/2/16.
//  Copyright © 2019年 YC. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>

@interface AAPLEAGLLayer : CAEAGLLayer
@property CVPixelBufferRef pixelBuffer;
- (id)initWithFrame:(CGRect)frame;
- (void)resetRenderBuffer;
@end
