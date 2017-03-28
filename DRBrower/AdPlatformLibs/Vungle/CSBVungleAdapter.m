//
//  CSBVungleAdapter.m
//  BundleADSDK
//
//  Created by Chance_yangjh on 2016/11/24.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBVungleAdapter.h"
#import <VungleSDK/VungleSDK.h>

#define Class_VungleSDK   NSClassFromString(@"VungleSDK")

@interface CSBVungleAdapter () <VungleSDKDelegate>
@property (nonatomic, copy) NSString *appId;
@end

@implementation CSBVungleAdapter

+ (void)load
{
    NSString *version = VungleSDKVersion;
    if (version.length > 0) {
        NSLog(@"当前Vungle SDK版本：%@", version);
    }
}

+ (instancetype)sharedInstance
{
    static CSBVungleAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSBVungleAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// Banner是否可用
- (BOOL)bannerEnabled
{
    return NO;
}
// Interstitial是否可用
- (BOOL)interstitialEnabled
{
    return NO;
}
// 视频广告是否可用
- (BOOL)videoEnabled
{
    return YES;
}

- (BOOL)videoAdLoadFinished
{
    if (self.appId.length < 1) {
        return YES;
    }
    return super.videoAdLoadFinished;
}
- (BOOL)videoAdIsReady
{
    if (self.appId.length > 0) {
        return [[Class_VungleSDK sharedSDK] isAdPlayable];
    }
    return NO;
}

// 获取广告平台类型
- (CSBADPlatform)platformType
{
    return CSBADPlatform_Vungle;
}

// 设置广告平台视频广告参数
- (void)setParamsOfVideo:(NSDictionary *)dicParam
{
    NSString *appId = dicParam[@"appId"];
    if ([appId isKindOfClass:NSString.class] && appId.length > 0) {
        self.appId = appId;
    }
}

// 加载视频广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadVideoAd:(BOOL)ispre withOrientation:(BOOL)portrait
     andPlacementId:(NSString *)placementId
{
    [super loadVideoAd:ispre withOrientation:portrait andPlacementId:placementId];
    
    if (self.appId.length > 0) {
        // 加载广告
        self.videoAdLoadFinished = NO;
        [[Class_VungleSDK sharedSDK] setDelegate:self];
        [[Class_VungleSDK sharedSDK] startWithAppId:self.appId];
        // 启动超时监测
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
        [self performSelector:@selector(loadVideoTimeout) withObject:nil afterDelay:self.timeoutOfLoadVideo];
        [self.videoAdDelegate csbAdapterVideoRequest:CSBAdOwner_Vungle];
        return YES;
    }
    else {
        // 没配置算加载完成
        self.videoAdLoadFinished = YES;
    }
    return NO;
}

// 打开视频广告
- (BOOL)showVideoAdWithOrientation:(BOOL)portrait
                    andPlacementId:(NSString *)placementId
{
    [super showVideoAdWithOrientation:portrait andPlacementId:placementId];
    
    if (self.videoAdIsReady) {
        [Class_VungleSDK sharedSDK].delegate = self;
        [[Class_VungleSDK sharedSDK] playAd:[self topVC] error:nil];
        return YES;
    }
    return NO;
}


#pragma mark - Private

- (void)loadVideoTimeout
{
    NSLog(@"%@ 视频广告加载超时", self.platformName);
    self.videoAdLoadFinished = YES;
    __weak id delegate = self.videoAdDelegate;
    self.videoAdDelegate = nil;
    [delegate csbAdapter:CSBAdOwner_Vungle loadVideoAdFailure:@"Timeout"];
}


#pragma mark - VungleSDKDelegate
/**
 * if implemented, this will get called when the SDK is about to show an ad. This point
 * might be a good time to pause your game, and turn off any sound you might be playing.
 */
- (void)vungleSDKwillShowAd
{
    NSLog(@"视频广告展现成功");
    [self.videoAdDelegate csbAdapterStartPlayVideo:CSBAdOwner_Vungle];
}

/**
 * if implemented, this will get called when the SDK closes the ad view, but there might be
 * a product sheet that will be presented. This point might be a good place to resume your game
 * if there's no product sheet being presented. The viewInfo dictionary will contain the
 * following keys:
 * - "completedView": NSNumber representing a BOOL whether or not the video can be considered a
 *               full view.
 * - "playTime": NSNumber representing the time in seconds that the user watched the video.
 * - "didDownload": NSNumber representing a BOOL whether or not the user clicked the download
 *                  button.
 * - "videoLength": **Deprecated** This will no longer be returned
 */
- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    NSLog(@"视频广告播放完成");
    [self.videoAdDelegate csbAdapterPlayVideoAdFinished:CSBAdOwner_Vungle];
    
    if ([viewInfo[@"didDownload"] boolValue]) {
        [self.videoAdDelegate csbAdapterVideoAdClicked:CSBAdOwner_Vungle];
    }
    if (!willPresentProductSheet) {
        __weak id delegate = self.videoAdDelegate;
        self.videoAdDelegate = nil;
        [delegate csbAdapterVideoAdDidDismiss:CSBAdOwner_Vungle];
    }
}

/**
 * if implemented, this will get called when the product sheet is about to be closed.
 */
- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    __weak id delegate = self.videoAdDelegate;
    self.videoAdDelegate = nil;
    [delegate csbAdapterVideoAdDidDismiss:CSBAdOwner_Vungle];
}

/**
 * if implemented, this will get called when the SDK has an ad ready to be displayed. Also it will
 * get called with an argument `NO` when for some reason, there's no ad available, for instance
 * there is a corrupt ad or the OS wiped the cache.
 * Please note that receiving a `NO` here does not mean that you can't play an Ad: if you haven't
 * opted-out of our Exchange, you might be able to get a streaming ad if you call `play`.
 */
- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
    
    if(!self.videoAdLoadFinished){
        if (isAdPlayable) {
            NSLog(@"加载视频广告成功");
            [self.videoAdDelegate csbAdapterLoadVideoAdSuccess:CSBAdOwner_Vungle];
        }
        else {
            NSLog(@"加载视频广告失败");
            [self.videoAdDelegate csbAdapter:CSBAdOwner_Vungle loadVideoAdFailure:@"Vungle视频广告失败"];
        }
        
        self.videoAdLoadFinished = YES;
    }
}

@end
