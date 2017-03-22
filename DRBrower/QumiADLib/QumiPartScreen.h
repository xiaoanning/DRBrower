//
//  QumiPartScreen.h
//  QumiSdkTem
//
//  Created by diangao on 15/11/6.
//  Copyright © 2015年 DianGao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DQUHeader.h"

typedef NS_ENUM(NSInteger,QumiAnimationType)
{
    QMElasticity = 1,
    QMSlide
};

@protocol QumiInterStitialDelegate;

@interface QumiPartScreen : UIView


@property (nonatomic,assign) id<QumiInterStitialDelegate>   delegate;
/**
 *  插屏广告显示
 */
-(void)displayInterCutAd:(UIViewController *)rootViewController withAnimation:(QumiAnimationType)antype;

@end

@protocol QumiInterStitialDelegate <NSObject>
//加载插屏广告成功后，回调该方法
- (void)qmInterCutAdSuccessToLoadAd:(QumiPartScreen *)qmAdView;
//加载插屏广告失败后，回调该方法
- (void)qmInterCutAdFailToLoadAd:(QumiPartScreen *)qmAdView qmWithError:(NSError *)error;
//显示插屏广告，回调该方法
- (void)qmInterCutAdPresent:(QumiPartScreen *)qmAdView Error:(NSError *)error;
//关闭插屏广告，回调该方法
- (void)qmInterCutAdDismiss:(QumiPartScreen *)qmAdView;
//点击插屏广告，回调该方法
- (void)qmInterCutAdClicked:(QumiPartScreen *)qmAdView;

@end