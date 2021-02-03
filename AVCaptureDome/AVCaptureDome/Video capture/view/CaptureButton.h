
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, CaptureButtonMode) {
	CaptureButtonModePhoto = 0, // default
	CaptureButtonModeVideo = 1
};

@interface CaptureButton : UIButton

+ (instancetype)captureButtonWithframe:(CGRect)frame;
+ (instancetype)captureButtonWithMode:(CaptureButtonMode)captureButtonMode frame:(CGRect)frame;

@property (nonatomic) CaptureButtonMode captureButtonMode;


@end

