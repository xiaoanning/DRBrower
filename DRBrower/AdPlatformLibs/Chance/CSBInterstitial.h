//
//  CSBInterstitial.h
//  BundleADSDK
//
//  Created by Chance_yangjh on 14-8-19.
//  Copyright (c) 2014年 yangjh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSBInterstitialDelegate;

@interface CSBInterstitial : NSObject

@property (nonatomic, weak) id<CSBInterstitialDelegate> delegate;

// 插屏广告只有一个
+ (CSBInterstitial *)sharedInterstitial;

// 加载插屏广告
- (void)loadInterstitial;

// 加载插屏广告
- (void)loadInterstitial:(NSString *)placementID;

// 打开插屏广告
- (void)showInterstitial;

// 打开插屏广告
- (void)showInterstitial:(NSString *)placementID;

// 取消未打开的插屏广告，即未打开的插屏广告不再需要打开
- (void)cancelInterstitial;

@end


@protocol CSBInterstitialDelegate <NSObject>

@optional

// 插屏广告加载成功
- (void)csbInterstitialLoadSuccess;

// 插屏广告加载失败
- (void)csbInterstitialLoadFailure:(NSString *)errorMsg;

// 插屏广告展现成功
- (void)csbInterstitialShowSuccess;

// 插屏广告关闭完成
- (void)csbInterstitialDidDismiss;

// 插屏广告被点击
- (void)csbInterstitialClicked;

@end


