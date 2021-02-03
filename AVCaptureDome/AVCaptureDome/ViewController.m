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
@interface ViewController ()<VideoCaptureDelegate>
@property(nonatomic,strong)UILabel *timeL;
@property(nonatomic,strong)UIImageView *thumImageV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    
    
}
- (void)setUI{
    VideoCapture *cap  = [VideoCapture captureWith:self.view];
    if (cap) {
        cap.delegate = self;
        cap.saveVideoToAlbum = YES;
        NSLog(@"1");
    }
    CaptureButton *btn = [CaptureButton captureButtonWithframe:CGRectMake(self.view.bounds.size.width / 2 - 35, self.view.bounds.size.height - 80, 70, 70)];
    [self.view addSubview:btn];
    
    self.timeL = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 50, 20, 100, 30)];
    self.timeL.text = @"00:00:00";
    self.timeL.textColor = [UIColor whiteColor];
    self.timeL.font = [UIFont systemFontOfSize:16];
    self.timeL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timeL];
    
    UIButton *lightBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 25, 25)];
    [lightBtn setBackgroundImage:[UIImage imageNamed:@"flash_icon"] forState:UIControlStateNormal];
    [self.view addSubview:lightBtn];
    
    UIButton *torchBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 20, 25, 25)];
    [torchBtn setBackgroundImage:[UIImage imageNamed:@"torch_icon"] forState:UIControlStateNormal];
    [self.view addSubview:torchBtn];
    
    UIButton *camera = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 20, 28, 21)];
      [camera setBackgroundImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
      [self.view addSubview:camera];
    
     UIButton *photoTake = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 80, self.view.bounds.size.height - 60, 40, 40)];
    [photoTake setTitle:@"拍照" forState:UIControlStateNormal];
    [self.view addSubview:photoTake];
    
    
    //开始录制
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        if (!cap.isRecording) {
            btn.selected = YES;
            btn.highlighted = NO;
            [cap startRecording];
        }else{
            btn.highlighted = YES;
            btn.selected = NO;
            [cap stopRecording];
        }
    }];
    //闪光灯
    [[lightBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        if (cap.cameraHasFlash) {
            if (cap.flashMode == AVCaptureFlashModeOff) {
                [cap setFlashMode:AVCaptureFlashModeOn];
                NSLog(@"闪光等开启成功");
            }else{
                [cap setFlashMode:AVCaptureFlashModeOff];
                NSLog(@"闪光等关闭成功");
            }
        }
    }];
    // 手电筒
    [[torchBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        if (cap.cameraHasTorch) {
            if (cap.torchMode == AVCaptureTorchModeOff) {
                [cap setTorchMode:AVCaptureTorchModeOn];
            }else{
                [cap setTorchMode:AVCaptureTorchModeOff];
            }
        }
    }];
    // 切换摄像头
    [[camera rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        if ([cap canSwitchCameras]) {
             [cap switchCameras];
        }
    }];
    
    //
    [[photoTake rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [cap captureStillImage];
    }];
}

- (void)captureFailedWithError:(NSError *)error{
    NSLog(@"出错了%@",error);
}


- (void)updateCaptureTimeDisplay:(CMTime)time{
    CMTime duration = time;
    NSUInteger time1 = (NSUInteger)CMTimeGetSeconds(duration);
    NSInteger hours = (time1 / 3600);
    NSInteger minutes = (time1 / 60) % 60;
    NSInteger seconds = time1 % 60;
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    self.timeL.text = timeString;
 
}
- (void)creatImage:(UIImage *)image{
    self.thumImageV.image = image;
    self.thumImageV.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumImageV.layer.borderWidth = 1.0f;
}
- (UIImageView *)thumImageV{
    if (!_thumImageV) {
        _thumImageV = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.view.bounds.size.height - (60  / 9 * 16 ) - 20 , 60, 60  / 9 * 16)];
        [self.view addSubview:_thumImageV];
        UIButton *btn  = [[UIButton alloc]initWithFrame:_thumImageV.frame];
        [self.view addSubview:btn];
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            [self showCameraRoll];
        }];
    }
    return _thumImageV;;
}
- (void)showCameraRoll {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)captureImage:(UIImage *_Nullable)image{
    NSLog(@"%@",image);
}
- (void)captureVideo:(NSString *_Nullable)filePath{
    NSLog(@"%@",filePath);
}
@end
