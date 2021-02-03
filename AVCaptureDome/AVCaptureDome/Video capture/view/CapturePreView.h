//
//  CapturePreView.h
//  AVCaptureDome
//
//  Created by 雨尘 on 2021/2/2.
//  Copyright © 2021 雨尘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol PreviewViewDelegate <NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;//聚焦
- (void)tappedToExposeAtPoint:(CGPoint)point;//曝光
- (void)tappedToResetFocusAndExposure;//点击重置聚焦&曝光
@end

@interface CapturePreView : UIView
//session用来关联AVCaptureVideoPreviewLayer 和 激活AVCaptureSession
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) id<PreviewViewDelegate> delegate;
@property (nonatomic) BOOL tapToFocusEnabled; //是否聚焦
@property (nonatomic) BOOL tapToExposeEnabled; //是否曝光
@end


