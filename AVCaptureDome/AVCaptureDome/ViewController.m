//
//  ViewController.m
//  AVCaptureDome
//
//  Created by 雨尘 on 2021/2/2.
//  Copyright © 2021 雨尘. All rights reserved.
//
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.24299
#import "ViewController.h"
#import "VideoCapture.h"
#import "CaptureButton.h"
#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)UILabel *timeL;
@property(nonatomic,strong)UIImageView *thumImageV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    
    
}
- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width - 100)/2,self.view.bounds.size.height - 60 , 100, 60)];
    [btn setTitle:@"拍摄" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [self startTranscribeVideo];
    }];
}
//选择本地视频
- (void)chooseLocalVideo
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
    [self presentViewController:ipc animated:YES completion:nil];
    ipc.delegate = self;//设置委托
}
//录制视频
- (void)startTranscribeVideo
{
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
        NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
        ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
        [self presentViewController:ipc animated:YES completion:nil];
        ipc.videoMaximumDuration = 30.0f;//30秒
        ipc.delegate = self;//设置委托
}


- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//此方法可以获取视频文件的时长。

//完成视频录制，并压缩后显示大小、时长
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:sourceURL]]);
    NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[sourceURL path]]]);
    NSURL *newVideoUrl ; //一般.mp4
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];
}
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    //presetName 几种格式
    //AVAssetExportPresetLowQuality,
    //AVAssetExportPreset960x540,
    //AVAssetExportPreset640x480,
    //AVAssetExportPresetMediumQuality,
    //AVAssetExportPreset1920x1080,
    //AVAssetExportPreset1280x720,
    //AVAssetExportPresetHighestQuality,
    //AVAssetExportPresetAppleM4A
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    // NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4; //转换的格式
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown:
                
                break;
            case AVAssetExportSessionStatusWaiting:
                
                break;
            case AVAssetExportSessionStatusExporting:
                
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"AVAssetExportSessionStatusCompleted");
                NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                NSLog(@"你的上传视频");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AVAssetExportSessionStatusFailed");
                break;
            case AVAssetExportSessionStatusCancelled:
                
                break;
        }
    }];
}
@end
