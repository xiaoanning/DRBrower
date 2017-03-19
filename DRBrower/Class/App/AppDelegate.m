//
//  AppDelegate.m
//  DRBrower
//
//  Created by QiQi on 2016/12/20.
//  Copyright © 2016年 QiQi. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>

#define APPKEY @"1b734ca46d7e8"
#define BUGLY_APPKEY @"749ac90a49"
@interface AppDelegate ()<CLLocationManagerDelegate>
@property (nonatomic, strong) DRLocationManager *locationManger;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:2];
    //保存系统亮度
    CGFloat sysLight = [UIScreen mainScreen].brightness;
    [[NSUserDefaults standardUserDefaults] setFloat:sysLight forKey:sys_light];

    [self shareRegist];
    [self location];
    [Bugly startWithAppId:BUGLY_APPKEY];
    [self everyLaunch];
    return YES;
}

- (void)everyLaunch {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }else{
        //不是第一次启动了
        [UserInfo everyLaunchBlock:^(id response, NSError *error) {
            
        }];
    }
}

- (void)shareRegist {
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:APPKEY
          activePlatforms:@[@(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:WEIXIN_APPID
                                       appSecret:WEIXIN_APPKEY];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:QQ_APPID
                                      appKey:QQ_APPKEY
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
    

}

// 支持所有iOS系统
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    BOOL result = [UMSocialSnsService handleOpenURL:url];
//    if (!result) {
//        // 其他如支付等SDK的回调
//    }
//    return result;
//}

//即将放弃活跃状态
- (void)applicationWillResignActive:(UIApplication *)application {
    //恢复系统亮度
    CGFloat sysLight = [[NSUserDefaults standardUserDefaults] floatForKey:sys_light];
    [[UIScreen mainScreen] setBrightness:sysLight];
}
//已经进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //恢复系统亮度
    CGFloat sysLight = [[NSUserDefaults standardUserDefaults] floatForKey:sys_light];
    [[UIScreen mainScreen] setBrightness:sysLight];
}
//即将进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    CGFloat sysLight = [UIScreen mainScreen].brightness;
    //设置app亮度
    CGFloat appLight = [[NSUserDefaults standardUserDefaults] floatForKey:app_light];
    [[UIScreen mainScreen] setBrightness:appLight?appLight:sysLight];
}

//恢复活跃状态
- (void)applicationDidBecomeActive:(UIApplication *)application {
    CGFloat sysLight = [UIScreen mainScreen].brightness;
    //设置app亮度
    CGFloat appLight = [[NSUserDefaults standardUserDefaults] floatForKey:app_light];
    [[UIScreen mainScreen] setBrightness:appLight?appLight:sysLight];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)location {
    self.locationManger = [[DRLocationManager alloc] init];
    self.locationManger.delegate = self;
    [self.locationManger creatManager];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        [self.locationManger requestWhenInUseAuthorization];
    }
}

#pragma mark - location delegate
// 当定位到用户位置时调用
// 调用非常频繁(耗电)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 一个CLLocation对象代表一个位置
    __block DRGeocoder *geo = [[DRGeocoder alloc] init];
    [geo creatGeocoder:locations.lastObject
                 block:^(DRGeocoder *geocoder, NSError *error) {
                     
                     [[NSUserDefaults standardUserDefaults] setObject:geocoder.city forKey:CITY];
                     [[NSUserDefaults standardUserDefaults] setObject:geocoder.subLocality forKey:SUBLOCALITY];

                     [manager stopUpdatingLocation];
                     
                     [[NSUserDefaults standardUserDefaults] setObject:@{@"city":geocoder.city,@"subLocality":geocoder.subLocality} forKey:GET_LOCATION];
                 }];
}


@end
