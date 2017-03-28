//
//  CSBAdmobAdapter.h
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/4/13.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBAdapter.h"

@interface CSBAdmobAdapter : CSBAdapter

/// Test ads will be returned for devices with device IDs specified in this array.
@property(nonatomic, copy) NSArray *testDevices;

@end
