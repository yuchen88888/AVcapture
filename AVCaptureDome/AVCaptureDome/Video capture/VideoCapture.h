//
//  VideoCapture.h
//  AVCaptureDome
//
//  Created by 雨尘 on 2021/2/2.
//  Copyright © 2021 雨尘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol VideoCaptureDelegate <NSObject>
- (void)captureFailedWithError:(NSError *_Nullable)error;
- (void)updateCaptureTimeDisplay:(CMTime)time;
- (void)creatImage:(UIImage *_Nullable)image; // 参数视频后者image的封面图
- (void)captureImage:(UIImage *_Nullable)image;  //拍摄获取的image
- (void)captureVideo:(NSString *_Nullable)filePath;//拍摄获取的video
@end
NS_ASSUME_NONNULL_BEGIN

@interface VideoCapture : NSObject
@property (weak, nonatomic) id<VideoCaptureDelegate> delegate;
@property (nonatomic) BOOL tapToFocusEnabled; //是否需要聚焦
@property (nonatomic) BOOL tapToExposeEnabled; //是否需要曝光
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus; //聚焦能力
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;//曝光能力
@property (nonatomic,readonly) BOOL isRecording; // 是否正在录制
@property (nonatomic, readonly) BOOL cameraHasTorch; //手电筒
@property (nonatomic, readonly) BOOL cameraHasFlash; //闪光灯
@property (nonatomic) BOOL saveVideoToAlbum; //是否存入相册
@property (nonatomic) AVCaptureTorchMode torchMode; //手电筒模式
@property (nonatomic) AVCaptureFlashMode flashMode; //闪光灯模式

+ (VideoCapture *)captureWith:(UIView *)preView;
//开始录制
- (void)startRecording;
//停止录制
- (void)stopRecording;
// 是否支持切换
- (BOOL)canSwitchCameras;
// 切换摄像头
- (BOOL)switchCameras;
//是否支持手电筒
- (BOOL)cameraHasTorch;
//判断是否有闪光灯
- (BOOL)cameraHasFlash;
//设置闪光灯
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;
//设置手电筒
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;
// 捕捉静态图片
- (void)captureStillImage;

@end

NS_ASSUME_NONNULL_END
