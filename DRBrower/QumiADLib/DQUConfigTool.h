//
//  DQUConfigTool.h
//  qm
//
//  Created by qm on 13-9-7.
//  Copyright (c) 2013年 qm. All rights reserved.
//

#define DQU_CONNECT_SUCCESS @"DQU_CONNECT_SUCCESS"
#define DQU_CONNECT_FAILED  @"DQU_CONNECT_FAILED"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DQUHeader.h"

@interface DQUConfigTool : NSObject
 //开发者ID 密钥
+ (void)startWithDQUAPPID:(NSString *)qmpublisherId qmsecretKey:(NSString *)qmsecretKey;

//开发者ID
+ (NSString *)DQUAppcodeId;

//密钥
+ (NSString*)DQUSecretKey;


+ (DQUConfigTool *)qmSharedInstance;

@end
