//
//  AppDelegate.m
//  AVCaptureDome
//
//  Created by 雨尘 on 2021/2/2.
//  Copyright © 2021 雨尘. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 导航栏设置
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UIApplication  sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // 强制关闭暗黑模式
#if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
    if(@available(iOS 13.0,*)){
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif
    
    self.window.rootViewController = [ViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle




@end
