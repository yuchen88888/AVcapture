//
//  YCSystemCapture.m
//  001-Demo
//
//  Created by YC老师 on 2019/2/16.
//  Copyright © 2019年 YC老师. All rights reserved.
//

#import "YCSystemCapture.h"
@interface YCSystemCapture ()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

/********************控制相关**********/
//是否进行
@property (nonatomic, assign) BOOL isRunning;

/********************公共*************/
//会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//代理队列
@property (nonatomic, strong) dispatch_queue_t captureQueue;

/********************音频相关**********/
//音频设备
@property (nonatomic, strong) AVCaptureDeviceInput *audioInputDevice;
//输出数据接收
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;

/********************视频相关**********/
//当前使用的视频设备
@property (nonatomic, weak) AVCaptureDeviceInput *videoInputDevice;
//前后摄像头
@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;
//输出数据接收
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;

@end
@implementation YCSystemCapture{
    //捕捉类型
    YCSystemCaptureType capture;
}

- (instancetype)initWithType:(YCSystemCaptureType)type {
    self = [super init];
    if (self) {
        capture = type;
    }
    return self;
}

//准备捕获
- (void)prepare {
    [self prepareWithPreviewSize:CGSizeZero];
}

//准备捕获(视频/音频)
- (void)prepareWithPreviewSize:(CGSize)size {
    self.preview.bounds = CGRectMake(0, 0, size.width, size.height);
    if (capture == YCSystemCaptureTypeAudio) {
        [self setupAudio];
    }else if (capture == YCSystemCaptureTypeVideo) {
        [self setupVideo];
    }else if (capture == YCSystemCaptureTypeAll) {
        [self setupAudio];
        [self setupVideo];
    }
}

#pragma mark - Control start/stop capture or change camera
- (void)start{
    if (!self.isRunning) {
        self.isRunning = YES;
        [self.captureSession startRunning];
    }
}
- (void)stop{
    if (self.isRunning) {
        self.isRunning = NO;
        [self.captureSession stopRunning];
    }
    
}

- (void)changeCamera{
    [self switchCamera];
}

-(void)switchCamera{
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.videoInputDevice];
    if ([self.videoInputDevice isEqual: self.frontCamera]) {
        self.videoInputDevice = self.backCamera;
    }else{
        self.videoInputDevice = self.frontCamera;
    }
    [self.captureSession addInput:self.videoInputDevice];
    [self.captureSession commitConfiguration];
}

#pragma mark-init Audio/video
- (void)setupAudio{
    //麦克风设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //将audioDevice ->AVCaptureDeviceInput 对象
    self.audioInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    //音频输出
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    //配置
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
    }
    if([self.captureSession canAddOutput:self.audioDataOutput]){
        [self.captureSession addOutput:self.audioDataOutput];
    }
    [self.captureSession commitConfiguration];
    
    self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
}

// 设置视频输入
- (void)setupVideo{
    //所有video 设备
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //前置摄像头
    self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.lastObject error:nil];
    self.backCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.firstObject error:nil];
    //设置当前设备为前置
    self.videoInputDevice = self.backCamera;
    
    //输出
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    /*设置视频帧延迟到底时是否丢弃数据.
     YES: 处理现有帧的调度队列在captureOutput:didOutputSampleBuffer:FromConnection:Delegate方法中被阻止时，对象会立即丢弃捕获的帧。
     NO: 在丢弃新帧之前，允许委托有更多的时间处理旧帧，但这样可能会内存增加.
     */
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // 设置图像格式
    [self.videoDataOutput setVideoSettings:@{
        (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    }];
    
    //配置
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.videoInputDevice]) {
        [self.captureSession addInput:self.videoInputDevice];
    }
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    //分辨率
    [self setVideoPreset];
    // commit 提交配置信息
    [self.captureSession commitConfiguration];
    
    // 设置连接器
    self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    // 设置视频方向
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    /*
     FPS是图像领域中的定义，是指画面每秒传输帧数，通俗来讲就是指动画或视频的画面数。
     FPS是测量用于保存、显示动态视频的信息数量。每秒钟帧数愈多，所显示的动作就会越流畅。通常，要避免动作不流畅的最低是30。某些计算机视频格式，每秒只能提供15帧。
     
     */
    [self updateFps:25];
    //设置预览图层
    [self setupPreviewLayer];
    
}

/**设置分辨率**/
- (void)setVideoPreset{
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])  {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        _witdh = 1080; _height = 1920;
    }else if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        _witdh = 720; _height = 1280;
    }else{
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        _witdh = 480; _height = 640;
    }
    
}
-(void)updateFps:(NSInteger) fps{
    //获取当前capture设备
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    // 便利所有摄像头
    for (AVCaptureDevice *device in videoDevices) {
        // 获取支持的最大fps
        float maxRate = [[device.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0]maxFrameRate];
        // 如果想要设置fps 小于或者大fps
        if (maxRate >= fps) {
            if ([device lockForConfiguration:NULL]) {
                device.activeVideoMinFrameDuration = CMTimeMake(10, (int)(fps *10));
                device.activeVideoMaxFrameDuration = device.activeVideoMinFrameDuration;
                [device unlockForConfiguration];
            }
        }
        
    }
}
/**设置预览层**/
- (void)setupPreviewLayer{
    self.preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.preLayer.frame =  CGRectMake(0, 0, self.preview.bounds.
                                      size.width, self.preview.bounds.size.height);
    //设置满屏
    self.preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.preview.layer addSublayer:self.preLayer];
}

#pragma mark-懒加载
- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}
- (dispatch_queue_t)captureQueue{
    if (!_captureQueue) {
        _captureQueue = dispatch_queue_create("TMCapture Queue", NULL);
    }
    return _captureQueue;
}
- (UIView *)preview{
    if (!_preview) {
        _preview = [[UIView alloc] init];
    }
    return _preview;
}


- (void)dealloc{
    NSLog(@"capture销毁。。。。");
    [self destroyCaptureSession];
}

#pragma mark-销毁会话
-(void) destroyCaptureSession{
    if (self.captureSession) {
        if (capture == YCSystemCaptureTypeAudio) {
            [self.captureSession removeInput:self.audioInputDevice];
            [self.captureSession removeOutput:self.audioDataOutput];
        }else if (capture == YCSystemCaptureTypeVideo) {
            [self.captureSession removeInput:self.videoInputDevice];
            [self.captureSession removeOutput:self.videoDataOutput];
        }else if (capture == YCSystemCaptureTypeAll) {
            [self.captureSession removeInput:self.audioInputDevice];
            [self.captureSession removeOutput:self.audioDataOutput];
            [self.captureSession removeInput:self.videoInputDevice];
            [self.captureSession removeOutput:self.videoDataOutput];
        }
    }
    self.captureSession = nil;
}

#pragma mark-输出代理
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (connection == self.audioConnection) {
        if (_delegate && [_delegate respondsToSelector:@selector(captureSampleBuffer:type:)]) {
            [_delegate captureSampleBuffer:sampleBuffer type:YCSystemCaptureTypeAudio];
        }
        
    }else if (connection == self.videoConnection) {
        if (_delegate && [_delegate respondsToSelector:@selector(captureSampleBuffer:type:)]) {
            [_delegate captureSampleBuffer:sampleBuffer type:YCSystemCaptureTypeVideo];
        }
        
    }
}



#pragma mark-授权相关
/**
 *  麦克风授权
 *  0 ：未授权 1:已授权 -1：拒绝
 */
+ (int)checkMicrophoneAuthor{
    int result = 0;
    //麦克风
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:
            //    请求授权
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            }];
            result = 0;
            break;
        case AVAudioSessionRecordPermissionDenied://拒绝
            result = -1;
            break;
        case AVAudioSessionRecordPermissionGranted://允许
            result = 1;
            break;
        default:
            break;
    }
    return result;
    
    
}
/**
 *  摄像头授权
 *  0 ：未授权 1:已授权 -1：拒绝
 */
+ (void)checkCameraAuthorComple:(void(^)(int num))comple{
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoStatus) {
        case AVAuthorizationStatusNotDetermined://第一次
            //    请求授权
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                comple(granted?1:0);
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized://已授权
        {
            comple(1);
        }
            break;
        default:
        {
            comple(-1);
        }
            break;
    }
}

-(int)test{
    int result = 0;
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (videoStatus) {
        case AVAuthorizationStatusNotDetermined://第一次
            break;
        case AVAuthorizationStatusAuthorized://已授权
            result = 1;
            break;
        default:
            result = -1;
            break;
    }
    return result;
}
@end

