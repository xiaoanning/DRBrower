//
//  CSBGDTAdapter.m
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/2/25.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBGDTAdapter.h"
#import "GDTMobBannerView.h"
#import "GDTMobInterstitial.h"

#define Class_BannerView    NSClassFromString(@"GDTMobBannerView")
#define Class_Interstitial  NSClassFromString(@"GDTMobInterstitial")

@interface CSBGDTAdapter () <GDTMobBannerViewDelegate, GDTMobInterstitialDelegate>
@property (nonatomic, strong) NSString *appkeyBanner;
@property (nonatomic, strong) NSString *placementIdBanner;
@property (nonatomic, strong) NSString *appkeyInterstitial;
@property (nonatomic, strong) NSString *placementIdInterstitial;

@property (nonatomic, strong) GDTMobBannerView *gdtBannerView;
@property (nonatomic, strong) GDTMobInterstitial *gdtInterstitial;
@end


@implementation CSBGDTAdapter

+ (instancetype)sharedInstance
{
    static CSBGDTAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSBGDTAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// Banner是否可用
- (BOOL)bannerEnabled
{
    return Class_BannerView != nil;
}
// Interstitial是否可用
- (BOOL)interstitialEnabled
{
    return Class_Interstitial != nil;
}
// 视频广告是否可用
- (BOOL)videoEnabled
{
    return NO;
}

- (BOOL)interstitialLoadFinished
{
    if (self.appkeyInterstitial.length < 1) {
        return YES;
    }
    // 准备好了，肯定是加载完成了
    if (self.interstitialIsReady) {
        return YES;
    }
    return super.interstitialLoadFinished;
}
- (BOOL)interstitialIsReady
{
    if (nil == self.gdtInterstitial) {
        return NO;
    }
    return self.gdtInterstitial.isReady;
}

// 获取广告平台类型
- (CSBADPlatform)platformType
{
    return CSBADPlatform_GDT;
}

// 设置广告平台Banner参数
- (void)setParamsOfBanner:(NSDictionary *)dicParam
{
    self.appkeyBanner = dicParam[@"appkeyB"];
    self.placementIdBanner = dicParam[@"placeIdB"];
}

// 设置广告平台插屏广告参数
- (void)setParamsOfInterstitial:(NSDictionary *)dicParam
{
    self.appkeyInterstitial = dicParam[@"appkeyI"];
    self.placementIdInterstitial = dicParam[@"placeIdI"];
}

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    if (self.appkeyBanner.length > 0) {
        self.gdtBannerView.delegate = nil;
        [self.gdtBannerView removeFromSuperview];
        self.gdtBannerView = [[Class_BannerView alloc] initWithFrame:bannerSuperView.bounds appkey:self.appkeyBanner placementId:self.placementIdBanner];
        self.gdtBannerView.currentViewController = [self topVC];
        self.gdtBannerView.showCloseBtn = NO;
        self.gdtBannerView.delegate = self;
        [bannerSuperView addSubview:self.gdtBannerView];
        // 加载广告
        [self.gdtBannerView loadAdAndShow];
        [self.bannerDelegate csbAdapterBannerRequest:CSBAdOwner_GDT];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    self.gdtBannerView.delegate = nil;
    [self.gdtBannerView removeFromSuperview];
    self.gdtBannerView = nil;
}

// 加载插屏广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadInterstitial:(BOOL)ispre withPlacementID:(NSString *)placementID
{
    [super loadInterstitial:ispre withPlacementID:placementID];
    
    if (self.appkeyInterstitial.length > 0) {
        if (nil == self.gdtInterstitial) {
            self.gdtInterstitial = [[Class_Interstitial alloc] initWithAppkey:self.appkeyInterstitial placementId:self.placementIdInterstitial];
        }
        self.gdtInterstitial.delegate = self;
        // 加载广告
        self.interstitialLoadFinished = NO;
        [self.gdtInterstitial loadAd];
        [self.interstitialDelegate csbAdapterInterstitialRequest:CSBAdOwner_GDT];
        return YES;
    }
    else {
        // 没配置算加载完成
        self.interstitialLoadFinished = YES;
    }
    return NO;
}

// 打开插屏广告
- (BOOL)showInterstitialWithPlacementID:(NSString *)placementID
{
    [super showInterstitialWithPlacementID:placementID];
    
    if (self.interstitialIsReady) {
        self.gdtInterstitial.delegate = self;
        [self.gdtInterstitial presentFromRootViewController:[self topVC]];
        return YES;
    }
    return NO;
}


#pragma mark - Private


#pragma mark - GDTMobBannerViewDelegate

- (void)bannerViewMemoryWarning
{
}

/**
 *  请求广告条数据成功后调用
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)bannerViewDidReceived
{
    NSLog(@"展现Banner成功");
    [self.bannerDelegate csbAdapterBannerShowSuccess:CSBAdOwner_GDT];
}

/**
 *  请求广告条数据失败后调用
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)bannerViewFailToReceived:(NSError *)error
{
    NSLog(@"加载Banner失败：%@", error.localizedDescription);
    [self.bannerDelegate csbAdapter:CSBAdOwner_GDT showBannerFailure:error.localizedDescription];
}

/**
 *  应用进入后台时调用
 *  详解:当点击应用下载或者广告调用系统程序打开，应用将被自动切换到后台
 */
- (void)bannerViewWillLeaveApplication
{
}

/**
 *  banner条被用户关闭时调用
 *  详解:当打开showCloseBtn开关时，用户有可能点击关闭按钮从而把广告条关闭
 */
- (void)bannerViewWillClose
{
}
/**
 *  banner条曝光回调
 */
- (void)bannerViewWillExposure
{
}
/**
 *  banner条点击回调
 */
- (void)bannerViewClicked
{
    [self.bannerDelegate csbAdapterBannerClicked:CSBAdOwner_GDT];
}

/**
 *  banner广告点击以后即将弹出全屏广告页
 */
- (void)bannerViewWillPresentFullScreenModal
{
}
/**
 *  banner广告点击以后弹出全屏广告页完毕
 */
- (void)bannerViewDidPresentFullScreenModal
{
}
/**
 *  全屏广告页即将被关闭
 */
- (void)bannerViewWillDismissFullScreenModal
{
}
/**
 *  全屏广告页已经被关闭
 */
- (void)bannerViewDidDismissFullScreenModal
{
}


#pragma mark - GDTMobInterstitialDelegate

/**
 *  广告预加载成功回调
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial
{
    NSLog(@"加载Interstitial成功");
    self.interstitialLoadFinished = YES;
    [self.interstitialDelegate csbAdapterInterstitialLoadSuccess:CSBAdOwner_GDT];
}

/**
 *  广告预加载失败回调
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error
{
    NSLog(@"加载Interstitial失败：%@", error.localizedDescription);
    self.interstitialLoadFinished = YES;
    [self.interstitialDelegate csbAdapter:CSBAdOwner_GDT interstitialLoadFailure:error.localizedDescription];
}

/**
 *  插屏广告将要展示回调
 *  详解: 插屏广告即将展示回调该函数
 */
- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial
{
}

/**
 *  插屏广告视图展示成功回调
 *  详解: 插屏广告展示成功回调该函数
 */
- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial
{
    NSLog(@"展现Interstitial完成");
    [self.interstitialDelegate csbAdapterInterstitialShowSuccess:CSBAdOwner_GDT];
}

/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial
{
    NSLog(@"Interstitial关闭完成");
    [self.interstitialDelegate csbAdapterInterstitialDidDismiss:CSBAdOwner_GDT];
    self.gdtInterstitial.delegate = nil;
    self.gdtInterstitial = nil;
    self.interstitialDelegate = nil;
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial
{
}

/**
 *  插屏广告曝光回调
 */
- (void)interstitialWillExposure:(GDTMobInterstitial *)interstitial
{
}

/**
 *  插屏广告点击回调
 */
- (void)interstitialClicked:(GDTMobInterstitial *)interstitial
{
    [self.interstitialDelegate csbAdapterInterstitialClicked:CSBAdOwner_GDT];
}

@end
