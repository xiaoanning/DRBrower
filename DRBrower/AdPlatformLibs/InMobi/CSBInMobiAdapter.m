//
//  CSBInMobiAdapter.m
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/5/25.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBInMobiAdapter.h"
#import <InMobiSDK/InMobiSDK.h>

#define Class_IMSdk         NSClassFromString(@"IMSdk")
#define Class_BannerView    NSClassFromString(@"IMBanner")
#define Class_Interstitial  NSClassFromString(@"IMInterstitial")

@interface CSBInMobiAdapter () <IMBannerDelegate, IMInterstitialDelegate>
@property (nonatomic, strong) NSString *accountIdB;
@property (nonatomic, strong) NSString *placeIdB;
@property (nonatomic, strong) NSString *accountIdI;
@property (nonatomic, strong) NSString *placeIdI;

@property (nonatomic, strong) IMBanner *imBannerView;
@property (nonatomic, strong) IMInterstitial *imInterstitial;
@end

@implementation CSBInMobiAdapter

+ (void)load
{
    NSString *version = [Class_IMSdk getVersion];
    if (version.length > 0) {
        NSLog(@"当前InMobi SDK版本：%@", version);
    }
}

+ (instancetype)sharedInstance
{
    static CSBInMobiAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSBInMobiAdapter alloc] init];
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
    if (self.accountIdI.length < 1 ||
        self.placeIdI.length < 1) {
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
    if (nil == self.imInterstitial) {
        return NO;
    }
    return [self.imInterstitial isReady];
}

// 获取广告平台类型
- (CSBADPlatform)platformType
{
    return CSBADPlatform_InMobi;
}

// 设置广告平台Banner参数
- (void)setParamsOfBanner:(NSDictionary *)dicParam
{
    self.accountIdB = dicParam[@"accountid"];
    self.placeIdB = dicParam[@"placeid"];
}

// 设置广告平台插屏广告参数
- (void)setParamsOfInterstitial:(NSDictionary *)dicParam
{
    self.accountIdI = dicParam[@"accountid"];
    self.placeIdI = dicParam[@"placeid"];
}

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    if (self.accountIdB.length > 0 && self.placeIdB.length > 0) {
        self.imBannerView.delegate = nil;
        [self.imBannerView removeFromSuperview];
        [Class_IMSdk initWithAccountID:self.accountIdB];
        self.imBannerView = [[Class_BannerView alloc] initWithFrame:bannerSuperView.bounds placementId:[self.placeIdB longLongValue] delegate:self];
        [self.imBannerView shouldAutoRefresh:NO];
        [self.imBannerView setRefreshInterval:2*displayTime];
        self.imBannerView.delegate = self;
        [bannerSuperView addSubview:self.imBannerView];
        [self.imBannerView load];
        [self.bannerDelegate csbAdapterBannerRequest:CSBAdOwner_InMobi];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    self.imBannerView.delegate = nil;
    [self.imBannerView removeFromSuperview];
    self.imBannerView = nil;
}

// 加载插屏广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadInterstitial:(BOOL)ispre withPlacementID:(NSString *)placementID
{
    [super loadInterstitial:ispre withPlacementID:placementID];
    
    if (self.accountIdI.length > 0 && self.placeIdI.length > 0) {
        [Class_IMSdk initWithAccountID:self.accountIdI];
        if (nil == self.imInterstitial || !self.imInterstitial.isReady) {
            self.imInterstitial.delegate = nil;
            self.imInterstitial = [[Class_Interstitial alloc] initWithPlacementId:[self.placeIdI longLongValue] delegate:self];
        }
        // 加载
        self.interstitialLoadFinished = NO;
        [self.imInterstitial load];
        [self.interstitialDelegate csbAdapterInterstitialRequest:CSBAdOwner_InMobi];
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
    BOOL canShow = YES;
    if (self.interstitialIsReady) {
        @try {
            [self.imInterstitial showFromViewController:[self topVC]];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
            canShow = NO;
            [self.interstitialDelegate csbAdapter:CSBAdOwner_InMobi interstitialShowFailure:@"InMobiAd show failed"];
        } @finally {
            if(canShow){
                [self.imInterstitial showFromViewController:[self topVC]];
            }
        }
        
        return YES;
    }
    return NO;
}


#pragma mark - Private


#pragma mark - IMBannerDelegate

/**
 * Notifies the delegate that the banner has finished loading
 */
-(void)bannerDidFinishLoading:(IMBanner*)banner
{
    NSLog(@"展现Banner成功");
    [self.bannerDelegate csbAdapterBannerShowSuccess:CSBAdOwner_InMobi];
}
/**
 * Notifies the delegate that the banner has failed to load with some error.
 */
-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus*)error
{
    NSLog(@"加载Banner失败：%@", error.localizedDescription);
    [self.bannerDelegate csbAdapter:CSBAdOwner_InMobi showBannerFailure:error.localizedDescription];
}
/**
 * Notifies the delegate that the banner was interacted with.
 */
-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary*)params
{
    [self.bannerDelegate csbAdapterBannerClicked:CSBAdOwner_InMobi];
}
/**
 * Notifies the delegate that the user would be taken out of the application context.
 */
-(void)userWillLeaveApplicationFromBanner:(IMBanner*)banner
{
}
/**
 * Notifies the delegate that the banner would be presenting a full screen content.
 */
-(void)bannerWillPresentScreen:(IMBanner*)banner
{
}
/**
 * Notifies the delegate that the banner has finished presenting screen.
 */
-(void)bannerDidPresentScreen:(IMBanner*)banner
{
}
/**
 * Notifies the delegate that the banner will start dismissing the presented screen.
 */
-(void)bannerWillDismissScreen:(IMBanner*)banner
{
}
/**
 * Notifies the delegate that the banner has dismissed the presented screen.
 */
-(void)bannerDidDismissScreen:(IMBanner*)banner
{
}
/**
 * Notifies the delegate that the user has completed the action to be incentivised with.
 */
-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards
{
}


#pragma mark - IMInterstitialDelegate
/**
 * Notifies the delegate that the interstitial has finished loading
 */
-(void)interstitialDidFinishLoading:(IMInterstitial*)interstitial
{
    if (interstitial == self.imInterstitial) {
        self.interstitialLoadFinished = YES;
        NSLog(@"加载插屏广告成功");
        [self.interstitialDelegate csbAdapterInterstitialLoadSuccess:CSBAdOwner_InMobi];
    }
}
/**
 * Notifies the delegate that the interstitial has failed to load with some error.
 */
-(void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error
{
    if (interstitial == self.imInterstitial) {
        self.interstitialLoadFinished = YES;
        NSLog(@"加载插屏广告失败：%@", error.localizedDescription);
        [self.interstitialDelegate csbAdapter:CSBAdOwner_InMobi interstitialLoadFailure:error.localizedDescription];
    }
}
/**
 * Notifies the delegate that the interstitial would be presented.
 */
-(void)interstitialWillPresent:(IMInterstitial*)interstitial
{
}
/**
 * Notifies the delegate that the interstitial has been presented.
 */
-(void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    if (interstitial == self.imInterstitial) {
        NSLog(@"插屏广告展现完成");
        [self.interstitialDelegate csbAdapterInterstitialShowSuccess:CSBAdOwner_InMobi];
    }
}
/**
 * Notifies the delegate that the interstitial has failed to present with some error.
 */
-(void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error
{
    if (interstitial == self.imInterstitial) {
        NSLog(@"插屏广告展现失败");
        [self.interstitialDelegate csbAdapter:CSBAdOwner_InMobi interstitialShowFailure:error.localizedDescription];
    }
}
/**
 * Notifies the delegate that the interstitial will be dismissed.
 */
-(void)interstitialWillDismiss:(IMInterstitial*)interstitial
{
    
}
/**
 * Notifies the delegate that the interstitial has been dismissed.
 */
-(void)interstitialDidDismiss:(IMInterstitial*)interstitial
{
    if (interstitial == self.imInterstitial) {
        NSLog(@"插屏关闭完成");
        self.imInterstitial.delegate = nil;
        self.imInterstitial = nil;
        __weak id delegate = self.interstitialDelegate;
        self.interstitialDelegate = nil;
        [delegate csbAdapterInterstitialDidDismiss:CSBAdOwner_InMobi];
    }
}
/**
 * Notifies the delegate that the interstitial has been interacted with.
 */
-(void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params
{
    if (interstitial == self.imInterstitial) {
        [self.interstitialDelegate csbAdapterInterstitialClicked:CSBAdOwner_InMobi];
    }
}
/**
 * Notifies the delegate that the user has performed the action to be incentivised with.
 */
-(void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards
{
    
}
/**
 * Notifies the delegate that the user will leave application context.
 */
-(void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial
{
    
}

@end
