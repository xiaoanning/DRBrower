//
//  CSBAdmobAdapter.m
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/4/13.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBAdmobAdapter.h"
@import GoogleMobileAds;

#define Class_BannerView    NSClassFromString(@"GADBannerView")
#define Class_Interstitial  NSClassFromString(@"GADInterstitial")
#define Class_Request       NSClassFromString(@"GADRequest")

@interface CSBAdmobAdapter () <GADBannerViewDelegate, GADInterstitialDelegate>
@property (nonatomic, copy) NSString *adUnitIDB;
@property (nonatomic, copy) NSString *adUnitIDI;
@property (nonatomic, strong) GADBannerView *gadBannerView;
@property (nonatomic, strong) GADInterstitial *gadInterstitial;
@end

@implementation CSBAdmobAdapter

+ (void)load
{
    NSString *version = [Class_Request sdkVersion];
    if (version.length > 0) {
        NSLog(@"当前Admob SDK版本：%@", version);
    }
}

+ (instancetype)sharedInstance
{
    static CSBAdmobAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSBAdmobAdapter alloc] init];
    });
    return sharedInstance;
}

- (GADBannerView *)createBannerView
{
    return  [[GADBannerView alloc] initWithAdSize:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone?kGADAdSizeBanner:kGADAdSizeLeaderboard];
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
    if (self.adUnitIDI.length < 1) {
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
    if (nil == self.gadInterstitial || self.gadInterstitial.hasBeenUsed) {
        return NO;
    }
    return self.gadInterstitial.isReady && !self.gadInterstitial.hasBeenUsed;
}

// 获取广告平台类型
- (CSBADPlatform)platformType
{
    return CSBADPlatform_Admob;
}

// 设置广告平台Banner参数
- (void)setParamsOfBanner:(NSDictionary *)dicParam
{
    self.adUnitIDB = dicParam[@"adUnitIDB"];
}

// 设置广告平台插屏广告参数
- (void)setParamsOfInterstitial:(NSDictionary *)dicParam
{
    self.adUnitIDI = dicParam[@"adUnitIDI"];
}

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    if (self.adUnitIDB.length > 0) {
        self.gadBannerView.delegate = nil;
        [self.gadBannerView removeFromSuperview];
        self.gadBannerView = [self createBannerView];
        self.gadBannerView.adUnitID = self.adUnitIDB;
        self.gadBannerView.rootViewController = [self topVC];
        self.gadBannerView.delegate = self;
        [bannerSuperView addSubview:self.gadBannerView];
        self.gadBannerView.center = CGPointMake(bannerSuperView.bounds.size.width/2,
                                                bannerSuperView.bounds.size.height/2);
        // 加载广告
        GADRequest *gadRequest = [Class_Request request];
        if (self.testDevices.count > 0) {
            gadRequest.testDevices = self.testDevices;
        }
        else {
            gadRequest.testDevices = @[];
        }
        [self.gadBannerView loadRequest:gadRequest];
        [self.bannerDelegate csbAdapterBannerRequest:CSBAdOwner_Admob];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    self.gadBannerView.delegate = nil;
    [self.gadBannerView removeFromSuperview];
    self.gadBannerView = nil;
}

// 加载插屏广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadInterstitial:(BOOL)ispre withPlacementID:(NSString *)placementID
{
    [super loadInterstitial:ispre withPlacementID:placementID];
    
    if (self.adUnitIDI.length > 0) {
        if (nil == self.gadInterstitial || self.gadInterstitial.hasBeenUsed) {
            self.gadInterstitial = [[Class_Interstitial alloc] initWithAdUnitID:self.adUnitIDI];
            self.gadInterstitial.delegate = self;
        }
        // 加载
        self.interstitialLoadFinished = NO;
        GADRequest *gadRequest = [Class_Request request];
        if (self.testDevices.count > 0) {
            gadRequest.testDevices = self.testDevices;
        }
        else {
            gadRequest.testDevices = @[];
        }
        [self.gadInterstitial loadRequest:gadRequest];
        [self.interstitialDelegate csbAdapterInterstitialRequest:CSBAdOwner_Admob];
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
        [self.gadInterstitial presentFromRootViewController:[self topVC]];
        return YES;
    }
    return NO;
}


#pragma mark - Private


#pragma mark - GADBannerViewDelegate

/// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
/// the banner view to the view hierarchy if it hasn't been added yet.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"展现Banner成功");
    [self.bannerDelegate csbAdapterBannerShowSuccess:CSBAdOwner_Admob];
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"加载Banner失败：%@", error.localizedDescription);
    [self.bannerDelegate csbAdapter:CSBAdOwner_Admob showBannerFailure:error.localizedDescription];
}

/// Tells the delegate that a full screen view will be presented in response to the user clicking on
/// an ad. The delegate may want to pause animations and time sensitive interactions.
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.bannerDelegate csbAdapterBannerClicked:CSBAdOwner_Admob];
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    
}

/// Tells the delegate that the full screen view has been dismissed. The delegate should restart
/// anything paused while handling adViewWillPresentScreen:.
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    
}

/// Tells the delegate that the user click will open another app, backgrounding the current
/// application. The standard UIApplicationDelegate methods, like applicationDidEnterBackground:,
/// are called immediately before this method is called.
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    [self.bannerDelegate csbAdapterBannerClicked:CSBAdOwner_Admob];
}


#pragma mark - GADInterstitialDelegate

/// Called when an interstitial ad request succeeded. Show it at the next transition point in your
/// application such as when transitioning between view controllers.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"加载Interstitial成功");
    self.interstitialLoadFinished = YES;
    [self.interstitialDelegate csbAdapterInterstitialLoadSuccess:CSBAdOwner_Admob];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"加载Interstitial失败：%@", error.localizedDescription);
    self.interstitialLoadFinished = YES;
    [self.interstitialDelegate csbAdapter:CSBAdOwner_Admob interstitialLoadFailure:error.localizedDescription];
}

/// Called just before presenting an interstitial. After this method finishes the interstitial will
/// animate onto the screen. Use this opportunity to stop animations and save the state of your
/// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
/// Store from a link on the interstitial).
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    NSLog(@"Interstitial将要展现");
    [self.interstitialDelegate csbAdapterInterstitialShowSuccess:CSBAdOwner_Admob];
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    NSLog(@"Interstitial关闭完成");
    self.gadInterstitial.delegate = nil;
    self.gadInterstitial = nil;
    __weak id delegate = self.interstitialDelegate;
    self.interstitialDelegate = nil;
    [delegate csbAdapterInterstitialDidDismiss:CSBAdOwner_Admob];
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    [self.interstitialDelegate csbAdapterInterstitialClicked:CSBAdOwner_Admob];
}

@end
