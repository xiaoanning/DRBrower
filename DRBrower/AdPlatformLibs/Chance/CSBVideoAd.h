//
//  CSBVideoAd.h
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/9/19.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSBVideoAdDelegate;

@interface CSBVideoAd : NSObject

@property (nonatomic, weak) id <CSBVideoAdDelegate> delegate;

// 视频广告只有一个
+ (instancetype)sharedInstance;

// 加载视频广告
- (void)loadVideoAdWithOrientation:(BOOL)portrait;

// 加载视频广告
- (void)loadVideoAdWithOrientation:(BOOL)portrait andPlacementId:(NSString *)placementID;

// 打开视频广告
- (void)showVideoAdWithOrientation:(BOOL)portrait;

// 打开视频广告
- (void)showVideoAdWithOrientation:(BOOL)portrait andPlacementId:(NSString *)placementID;

@end


@protocol CSBVideoAdDelegate <NSObject>

@optional

// 视频广告加载成功
- (void)csbVideoAdLoadSuccess:(CSBVideoAd *)videoAd;

// 视频广告加载失败
- (void)csbVideoAd:(CSBVideoAd *)videoAd loadFailure:(NSString *)errorMsg;

// 视频广告开始播放
- (void)csbVideoAdStartPlayVideo:(CSBVideoAd *)videoAd;

// 视频广告播放完成
- (void)csbVideoAdPlayFinished:(CSBVideoAd *)videoAd;

// 视频广告关闭完成
- (void)csbVideoAdDidDismiss:(CSBVideoAd *)videoAd;

@end
