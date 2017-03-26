//
//  SplashAd.h
//  JoyingSpot
//
//  Created by linxiaolong on 16/1/20.
//  Copyright © 2016年 yuxuhong. All rights reserved.
//
/**
 *
 * 本开屏样式不适用ipad
 */
#import <Foundation/Foundation.h>
#import "UMAdsView.h"
/**
 * 
 *  使用方法：
 
 1. 先初始化并设置delegate
 - (void)testShowAd{
    if (self.splashAd) {
        self.splashAd = nil;
    }
    //初始化
    self.splashAd = [[SplashAd alloc]init];
    _splashAd.delegate = self;
    _splashAd.fetchDelay = 5.0;
    //拉取广告
    [_splashAd loadSplashAd];
 }
 
 2.开发者通过代理获取到请求广告的4个状态
 
 -(void)SplashLoadSuccess:(UIView *)adView{
    NSLog(@"************获取成功，显示广告************");
    [self.window addSubview:adView];
 }

 -(void)SplashLoadError{
    NSLog(@"************获取广告失败************");
 }
 -(void)SplashClick{
    NSLog(@"************广告被点击************");
 }
 -(void)ZhangySpotLoadedTimeOut{
    NSLog(@"************超时************");
 }
 */

@protocol SplashDelegate <NSObject>

/**
 *  超时回调
 */
-(void)ZhangySpotLoadedTimeOut;


-(void)SplashClosePerformprivacy;
/**
 *  点击回调
 */
-(void)SplashClick;

/**
 *  拉取成功回调  获取到adView请在立即展示给用户，否则失效。
 */
-(void)SplashLoadSuccess:(UIView*)adView;

/**
 *  拉取失败回调
 */
-(void)SplashLoadError;

@end

@interface UMSplashAd : NSObject<UMAdsViewDelegate>

/**
 *  开始拉取广告
 *  注：拉取广告前会判断是不是ipad设备，如果是ipad会跳到SplashLoadError代理方法
 */
-(void)loadSplashAd;

/**
 *  委托对象
 */
@property (nonatomic, assign) id<SplashDelegate> delegate;

/**
 *  拉取广告超时时间，默认为3秒
 */
@property (nonatomic, assign) int fetchDelay;

@end
