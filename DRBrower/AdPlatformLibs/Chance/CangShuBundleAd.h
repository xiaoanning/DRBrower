//
//  CangShuBundleAd.h
//  CangShuBundleAd
//
//  Created by Chance_yangjh on 14-8-29.
//  Copyright (c) 2014年 yangjh. All rights reserved.
//

#import <Foundation/Foundation.h>


// SDK_Version仅供参考，以[CangShuBundleAd sdkVersion];得到的版本号为准
#define BundleADSDK_Version  @"1.4.1"


@interface CangShuBundleAd : NSObject

// 设置聚合平台的PublisherID
+ (void)setPublisherID:(NSString *)publisherID;

/**
 *	@brief	获取SDK版本号
 *
 *	@return	SDK版本号
 */
+ (NSString *)sdkVersion;

///**
// *  为Admob广告设置测试设备
// *
// *  @param testDevices 测试设备id列表
// */
//+ (void)setTestDevicesForAdmob:(NSArray<NSString *> *)testDevices;

@end
