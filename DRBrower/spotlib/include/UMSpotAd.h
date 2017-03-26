//
//  SPTSDK
//
//  Created by um on 15-10-16.
//  Copyright (c) 2015年 um. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum {
    kTypePortrait = 0, //竖屏
    kTypeLandscape = 1, //横屏
    kTypeBoth = 2, //横竖屏同时支持   注意选这个sdk会缓存两张图片,不支持旋转的应用不建议选这个
} SsType;

@interface UMSpotAd : NSObject

/**
 * 初始化appid和secretId
 * 您需要先在有米官网注册并创建一个应用，在项目初始化的时候调用本方法传入对应的值
 */
+(void)initAppId:(NSString *)appid secretId:(NSString *)secretId;

/**
 * 初始化插屏广告并设置使用的广告类型
 *［建议］
 *      1如果您的App是横屏请设置为kTypeLandscape
 *      2如果是竖屏请设置为kTypePortrait
 *      3当您的App兼容横屏和竖屏的时候才设定为kTypeBoth
 */
+ (void)initAdDeveLoper:(SsType)ssType;

/*
 * 显示插屏广告
 * flag： YES代表广告展示成功 / NO代表广告展示失败
 */
+ (BOOL)showAdAction:(void (^)(BOOL flag))dismissAction;

/*
 * 点击插屏广告的回调,点击成功,flag为YES,否则为NO
 */
+ (BOOL)clickAdAction:(void (^)(BOOL flag))callbackAction;

/*
 * 设置controller
 */
+ (void)setAdController:(UIViewController *)controller;


+(NSString *)SDKVersion;
@end
