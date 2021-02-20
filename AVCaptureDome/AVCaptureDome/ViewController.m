//
//  ViewController.m
//  AVCaptureDome
//
//  Created by 雨尘 on 2021/2/2.
//  Copyright © 2021 雨尘. All rights reserved.
//

#import "ViewController.h"
#import "VideoCapture.h"
#import "CaptureButton.h"
#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "YCSystemCapture.h"
#import "YCAudioEncoder.h"
#import "YCAudioDecoder.h"
#import "YCAudioPCMPlayer.h"
#import "YCAVConfig.h"
#import "YCVideoEncoder.h"
#import "YCVideoDecoder.h"
#import "AAPLEAGLLayer.h"

@interface ViewController ()<YCSystemCaptureDelegate,YCVideoEncoderDelegate, YCVideoDecoderDelegate,YCAudioEncoderDelegate,YCAudioDecoderDelegate>
@property(nonatomic,strong)UILabel *timeL;
@property(nonatomic,strong)UIImageView *thumImageV;

@property (nonatomic, strong) YCSystemCapture *capture;
@property (nonatomic, strong) YCVideoEncoder *videoEncoder;
@property (nonatomic, strong) YCVideoDecoder *videoDecoder;
@property (nonatomic, strong) YCAudioEncoder *audioEncoder;
@property (nonatomic, strong) AAPLEAGLLayer *displayLayer;
@property (nonatomic, strong) YCAudioDecoder *audioDecoder;
@property (nonatomic, strong) YCAudioPCMPlayer *pcmPlayer;
@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, copy) NSString *path;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [YCSystemCapture checkCameraAuthorComple:^(int num) {
        if(num == 1){
            [self setVideo];
        }
    }];
}

- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100 - 20, self.view.bounds.size.height - 60, 100, 50)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [self.capture start];
    }];
    
    
    UIButton *button1 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 + 20, self.view.bounds.size.height - 60, 100, 50)];
    [button1 setTitle:@"结束" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor redColor];
    [self.view addSubview:button1];
    [[button1 rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [self.capture stop];
    }];
    
    
    self.thumImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 , self.view.frame.size.width / 2, self.view.frame.size.height / 2 )];
    [self.view addSubview:self.thumImageV];
    
    
}
- (void)setVideo{
    _path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"h264video.h264"];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:_path]) {
        [fileManger removeItemAtPath:_path error:nil];
        if ([fileManger createFileAtPath:_path contents:nil attributes:nil]) {
            NSLog(@"文件创建成功%@",_path);
        }else{
            NSLog(@"文件创建失败%@",_path);
        }
    }else{
        if ([fileManger createFileAtPath:_path contents:nil attributes:nil]) {
            NSLog(@"2文件创建成功%@",_path);
        }else{
            NSLog(@"2文件创建失败%@",_path);
        }
    }
    _handle  = [NSFileHandle fileHandleForWritingAtPath:_path];
    
    //捕捉
    _capture = [[YCSystemCapture alloc]initWithType:YCSystemCaptureTypeAll];
    CGSize size = CGSizeMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [_capture prepareWithPreviewSize:size];
    _capture.preview.frame = CGRectMake(0, 0, size.width, size.height);
    [self.view addSubview:_capture.preview];
    self.capture.delegate = self;
    
    //设置编解码
    YCVideoConfig *config = [YCVideoConfig defaultConifg];
    config.width = _capture.witdh;
    config.height = _capture.height;
    config.bitrate = config.height * config.width * 5;
    // 编码
    _videoEncoder = [[YCVideoEncoder alloc]initWithConfig:config];
    _videoEncoder.delegate = self;
    // 解码
    _videoDecoder = [[YCVideoDecoder alloc]initWithConfig:config];
    _videoDecoder.delegate = self;
    
    
    //aac编码器
    _audioEncoder = [[YCAudioEncoder alloc] initWithConfig:[YCAudioConfig defaultConifg]];
    _audioEncoder.delegate = self;
    
    _audioDecoder = [[YCAudioDecoder alloc]initWithConfig:[YCAudioConfig defaultConifg]];
    _audioDecoder.delegate = self;
    
    
    _pcmPlayer = [[YCAudioPCMPlayer alloc]initWithConfig:[YCAudioConfig defaultConifg]];
    _displayLayer = [[AAPLEAGLLayer alloc]initWithFrame:CGRectMake(size.width, 0, size.width, size.height)];
    [self.view.layer addSublayer:_displayLayer];
    
}




#pragma mark -- YCSystemCaptureDelegate
//捕获音视频回调
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer type: (YCSystemCaptureType)type{
    if (type == YCSystemCaptureTypeAudio) {
        //音频数据
        //1.直接播放PCM数据
//        NSData *pcmData = [self convertAudioSamepleBufferToPcmData:sampleBuffer];
//        [_pcmPlayer playPCMData:pcmData];
        
        //2.AAC编码
        [_audioEncoder encodeAudioSamepleBuffer:sampleBuffer];
    }else{
        //        NSLog(@"sampleBuffer == %@",sampleBuffer);
        //        NSLog(@"解码前 == %@",CMSampleBufferGetImageBuffer(sampleBuffer));
        [_videoEncoder encodeVideoSampleBuffer:sampleBuffer];
        
        
        

//       _displayLayer.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        //        // 转成图片显示 显示截图可以
        //        UIImage *image =  [self uiImageFromPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer)];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //          [self.thumImageV setImage:image];
        //        });
        
        
    }
    
}

//将sampleBuffer数据提取出PCM数据返回给ViewController.可以直接播放PCM数据
- (NSData *)convertAudioSamepleBufferToPcmData: (CMSampleBufferRef)sampleBuffer {
    
    //获取pcm数据大小
    size_t size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
    //分配空间
    int8_t *audio_data = (int8_t *)malloc(size);
    memset(audio_data, 0, size);
    
    //获取CMBlockBuffer, 这里面保存了PCM数据
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    //将数据copy到我们分配的空间中
    CMBlockBufferCopyDataBytes(blockBuffer, 0, size, audio_data);
    //PCM data->NSData
    NSData *data = [NSData dataWithBytes:audio_data length:size];
    free(audio_data);
    return data;
}

- (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)p {
    
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:p];
    
    CIContext* context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(p), CVPixelBufferGetHeight(p));
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    
    UIImage* image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}

#pragma mark--YCVideoEncoder/Decoder Delegate
//h264编码回调（sps/pps）
- (void)videoEncodeCallbacksps:(NSData *)sps pps:(NSData *)pps {
    //解码
    [_videoDecoder decodeNaluData:sps];
    
    //    测试写入文件
    //    [_handle seekToEndOfFile];
    //    [_handle writeData:sps];
    
    //解码（这两个不能直接和在一起解码）
    [_videoDecoder decodeNaluData:pps];
    
    //    [_handle seekToEndOfFile];
    //    [_handle writeData:pps];
}
//h264编码回调 （数据）
- (void)videoEncodeCallback:(NSData *)h264Data {
    //编码
    [_videoDecoder decodeNaluData:h264Data];
    //    测试写入文件
    //    [_handle seekToEndOfFile];
    //    [_handle writeData:h264Data];
}

//h264解码回调
- (void)videoDecodeCallback:(CVPixelBufferRef)imageBuffer {
    //显示
    if (imageBuffer) {
        _displayLayer.pixelBuffer = imageBuffer;
    }
}


#pragma mark--YCAudioEncoder/Decoder Delegate
//aac编码回调
- (void)audioEncodeCallback:(NSData *)aacData {
 
     //1.写入文件
    // [_handle seekToEndOfFile];
    // [_handle writeData:aacData];

    //2.直接解码
    [_audioDecoder decodeAudioAACData:aacData];
    
}

- (void)audioDecodeCallback:(NSData *)pcmData{
     [_pcmPlayer playPCMData:pcmData];
}



@end
