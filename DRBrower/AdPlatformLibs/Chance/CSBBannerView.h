//
//  CSBBannerView.h
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/3/4.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import <UIKit/UIKit.h>


#define CSBBannerSize  ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)?CGSizeMake(320.0f, 50.0f):CGSizeMake(728.0f, 90.0f))

@protocol CSBBannerViewDelegate;

@interface CSBBannerView : UIView

@property (nonatomic, assign) NSUInteger requestInterval; // 广告请求间隔，单位为秒，最小值5
@property (nonatomic, assign) NSUInteger displayTime;     // 广告展现时长，单位为秒，最小值5

@property (nonatomic, weak) id <CSBBannerViewDelegate> delegate;

// 加载广告
- (void)loadAd;

@end


@protocol CSBBannerViewDelegate <NSObject>

@optional

// Banner广告展现成功
- (void)csbBannerViewShowSuccess;

// Banner广告展现失败
- (void)csbBannerViewShowFailure:(NSString *)errorMsg;

// Banner广告被移除
- (void)csbBannerViewRemoved;

// Banner广告被点击
- (void)csbBannerViewClicked;

@end
