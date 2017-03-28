//
//  CSBUnityAdapter.m
//  BundleADSDK
//
//  Created by Chance_yangjh on 2016/11/24.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBUnityAdapter.h"
#import <UnityAds/UnityAds.h>
#import <UnityAds/UnityAdsExtended.h>

#define Class_UnityAds      NSClassFromString(@"UnityAds")

@interface CSBUnityAdapter () <UnityAdsDelegate, UnityAdsExtendedDelegate>
@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, assign)BOOL didDownload;
@end

@implementation CSBUnityAdapter

+ (void)load
{
    NSString *version = [Class_UnityAds getVersion];
    if (version.length > 0) {
        NSLog(@"当前UnityAds版本：%@", version);
    }
}

+ (instancetype)sharedInstance
{
    static CSBUnityAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSBUnityAdapter alloc] init];
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
    return [Class_UnityAds isSupported];
}

- (BOOL)videoAdLoadFinished
{
    if (self.gameId.length < 1) {
        return YES;
    }
    // 准备好了，肯定是加载完成了
    if (self.videoAdIsReady) {
        return YES;
    }
    return super.videoAdLoadFinished;
}
- (BOOL)videoAdIsReady
{
    if (self.gameId.length > 0) {
        return [Class_UnityAds isReady];
    }
    return NO;
}

// 获取广告平台类型
- (CSBADPlatform)platformType
{
    return CSBADPlatform_Unity;
}

// 设置广告平台视频广告参数
- (void)setParamsOfVideo:(NSDictionary *)dicParam
{
    NSString *gameId = dicParam[@"gameId"];
    if ([gameId isKindOfClass:NSString.class] && gameId.length > 0) {
        self.gameId = gameId;
    }
}

// 加载视频广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadVideoAd:(BOOL)ispre withOrientation:(BOOL)portrait
     andPlacementId:(NSString *)placementId
{
    [super loadVideoAd:ispre withOrientation:portrait andPlacementId:placementId];
    
    if (self.gameId.length > 0) {
        // 加载广告
        self.videoAdLoadFinished = NO;
        // 启动超时监测
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
        [self performSelector:@selector(loadVideoTimeout) withObject:nil afterDelay:self.timeoutOfLoadVideo];
        [Class_UnityAds initialize:self.gameId delegate:self];
        [self.videoAdDelegate csbAdapterVideoRequest:CSBAdOwner_Unity];
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
        [Class_UnityAds setDelegate:self];
        [Class_UnityAds show:[self topVC]];
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
    [delegate csbAdapter:CSBAdOwner_Unity loadVideoAdFailure:@"Timeout"];
}


#pragma mark - UnityAdsDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    self.videoAdLoadFinished = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
    
    if([placementId isEqualToString:@"rewardedVideo"]){
        NSLog(@"加载成功");
        [self.videoAdDelegate csbAdapterLoadVideoAdSuccess:CSBAdOwner_Unity];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    self.videoAdLoadFinished = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
    
    NSLog(@"加载视频广告失败");
    [self.videoAdDelegate csbAdapter:CSBAdOwner_Unity loadVideoAdFailure:@"Unity视频广告失败"];
}

- (void)unityAdsDidStart:(NSString *)placementId
{
    NSLog(@"视频广告开始播放");
    [self.videoAdDelegate csbAdapterStartPlayVideo:CSBAdOwner_Unity];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    NSLog(@"视频广告播放完成");
    [self.videoAdDelegate csbAdapterPlayVideoAdFinished:CSBAdOwner_Unity];
    self.didDownload = NO;
    
    __weak id delegate = self.videoAdDelegate;
    self.videoAdDelegate = nil;
    [delegate csbAdapterVideoAdDidDismiss:CSBAdOwner_Unity];
}

#pragma mark - UnityAdsExtendedDelegate
- (void)unityAdsDidClick:(NSString *)placementId
{
    //每次点击下载都会有回调，只在第一次点击下载回调
    if(!self.didDownload){
        NSLog(@"视频广告下载点击");
        [self.videoAdDelegate csbAdapterVideoAdClicked:CSBAdOwner_Unity];
    }
    self.didDownload = YES;
}

@end
