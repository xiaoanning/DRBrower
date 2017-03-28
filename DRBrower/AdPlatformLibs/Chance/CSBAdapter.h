//
//  CSBAdapter.h
//  BundleADSDK
//
//  Created by Chance_yangjh on 14-9-2.
//  Copyright (c) 2014年 yangjh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, CSBADPlatform) {
    CSBADPlatform_None,
    CSBADPlatform_Chance,
    CSBADPlatform_Chartboost,
    CSBADPlatform_Admob,
    CSBADPlatform_GDT,
    CSBADPlatform_InMobi,
    CSBADPlatform_Unity,
    CSBADPlatform_Vungle,
    CSBADPlatform_Count,
};


typedef NS_ENUM(unsigned int, CSBAdOwner) {
    CSBAdOwner_Chance,
    CSBAdOwner_Chartboost = 5000,
    CSBAdOwner_Admob,
    CSBAdOwner_GDT,
    CSBAdOwner_BaiDu,
    CSBAdOwner_InMobi,
    CSBAdOwner_Unity = 5005,
    CSBAdOwner_Vungle,
};


@protocol CSBAdapterBannerProtocol;
@protocol CSBAdapterInterstitialProtocol;
@protocol CSBAdapterVideoAdProtocol;

@interface CSBAdapter : NSObject
// 是否为再分配的Banner广告
@property (nonatomic, assign) BOOL reassignBanner;
// 是否为优先分配的平台
@property (nonatomic, assign) BOOL isPerferredI;
// 是否为再分配的视频广告
@property (nonatomic, assign) BOOL reassignVideoAd;
// 并发ID
@property (nonatomic, strong) NSString *concurrentID;
// 加载ID
@property (nonatomic, strong) NSString *loadID;
// 展现ID
@property (nonatomic, strong) NSString *showID;
// 视频广告加载ID
@property (nonatomic, strong) NSString *videoAdLoadId;
// 视频广告展现ID
@property (nonatomic, strong) NSString *videoAdShowId;

// 当前广告平台类型
@property (nonatomic, readonly) CSBADPlatform platformType;
// 当前广告平台名称
@property (nonatomic, readonly) NSString *platformName;
// 用于回调广告请求与展现
@property (nonatomic, weak) id <CSBAdapterBannerProtocol> bannerDelegate;
@property (nonatomic, weak) id <CSBAdapterInterstitialProtocol> interstitialDelegate;
@property (nonatomic, weak) id <CSBAdapterVideoAdProtocol> videoAdDelegate;

// 插屏广告是否加载完成
@property (nonatomic, assign) BOOL interstitialLoadFinished;
// 插屏广告是否准备好了
@property (nonatomic, readonly) BOOL interstitialIsReady;
// 是否需要展现插屏（未加载好就调用了close，则加载好后不需要展现）
@property (nonatomic, readonly) BOOL needShowInterstitial;

// 视频广告是否加载完成
@property (nonatomic, assign) BOOL videoAdLoadFinished;
// 视频广告是否准备好了
@property (nonatomic, readonly) BOOL videoAdIsReady;
// 是否需要展现视频（未加载好就调用了close，则加载好后不需要展现）
@property (nonatomic, readonly) BOOL needShowVideoAd;
// 超时时间
@property (nonatomic, readonly) NSInteger timeoutOfLoadVideo;

+ (instancetype)sharedInstance;

// Banner是否可用
- (BOOL)bannerEnabled;
// Interstitial是否可用
- (BOOL)interstitialEnabled;
// 视频广告是否可用
- (BOOL)videoEnabled;

// 设置广告平台Banner参数
- (void)setParamsOfBanner:(NSDictionary *)dicParam;

// 设置广告平台插屏广告参数
- (void)setParamsOfInterstitial:(NSDictionary *)dicParam;

// 设置广告平台视频广告参数
- (void)setParamsOfVideo:(NSDictionary *)dicParam;

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime;

// 移除Banner
- (void)removeBanner;

// 加载插屏广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadInterstitial:(BOOL)ispre withPlacementID:(NSString *)placementID;

// 打开插屏广告
- (BOOL)showInterstitialWithPlacementID:(NSString *)placementID;

// 取消未打开的插屏广告，即未打开的插屏广告不再需要打开
- (void)cancelInterstitial;

// 加载视频广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadVideoAd:(BOOL)ispre withOrientation:(BOOL)portrait
     andPlacementId:(NSString *)placementId;

// 打开视频广告
- (BOOL)showVideoAdWithOrientation:(BOOL)portrait
                    andPlacementId:(NSString *)placementId;

// 获取顶层VC
- (UIViewController *)topVC;

@end


@protocol CSBAdapterBannerProtocol <NSObject>

// 请求Banner
- (void)csbAdapterBannerRequest:(CSBAdOwner)adOwner;

// 展现Banner成功
- (void)csbAdapterBannerShowSuccess:(CSBAdOwner)adOwner;

// 展现Banner失败
- (void)csbAdapter:(CSBAdOwner)adOwner showBannerFailure:(NSString *)errorMsg;

// Banner被点击
- (void)csbAdapterBannerClicked:(CSBAdOwner)adOwner;

@end

@protocol CSBAdapterInterstitialProtocol <NSObject>

// 请求插屏广告
- (void)csbAdapterInterstitialRequest:(CSBAdOwner)adOwner;

// 插屏广告加载成功
- (void)csbAdapterInterstitialLoadSuccess:(CSBAdOwner)adOwner;

// 插屏广告加载失败
- (void)csbAdapter:(CSBAdOwner)adOwner interstitialLoadFailure:(NSString *)errorMsg;

// 插屏广告展现成功
- (void)csbAdapterInterstitialShowSuccess:(CSBAdOwner)adOwner;

// 插屏广告展现失败
- (void)csbAdapter:(CSBAdOwner)adOwner interstitialShowFailure:(NSString *)errorMsg;

// 插屏广告被点击
- (void)csbAdapterInterstitialClicked:(CSBAdOwner)adOwner;

// 插屏广告关闭完成
- (void)csbAdapterInterstitialDidDismiss:(CSBAdOwner)adOwner;

@end


@protocol CSBAdapterVideoAdProtocol <NSObject>

// 请求视频广告
- (void)csbAdapterVideoRequest:(CSBAdOwner)adOwner;

// 视频广告加载成功
- (void)csbAdapterLoadVideoAdSuccess:(CSBAdOwner)adOwner;

// 视频广告加载失败
- (void)csbAdapter:(CSBAdOwner)adOwner loadVideoAdFailure:(NSString *)errorMsg;

// 视频广告开始播放
- (void)csbAdapterStartPlayVideo:(CSBAdOwner)adOwner;

// 视频广告播放完成
- (void)csbAdapterPlayVideoAdFinished:(CSBAdOwner)adOwner;

// 视频广告关闭完成
- (void)csbAdapterVideoAdDidDismiss:(CSBAdOwner)adOwner;

// 视频广告被点击
- (void)csbAdapterVideoAdClicked:(CSBAdOwner)adOwner;

@end
