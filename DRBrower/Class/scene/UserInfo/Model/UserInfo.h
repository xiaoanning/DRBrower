//
//  UserInfo.h
//  DRBrower
//
//  Created by QiQi on 2017/3/9.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserGenderType) {
    UserGenderTypeMan = 0,
    UserGenderTypeWoman,
    UserGenderTypeUnknown
};

@interface UserInfo : NSObject

+ (void)userInfoDefaults:(NSString *)gender;
+ (NSString *)getUserGender;

+ (NSURLSessionDataTask *)firstLaunchBlock:(void (^)(id response,
                                                    NSError *error))completion;
+ (NSURLSessionDataTask *)everyLaunchBlock:(void (^)(id response,
                                                     NSError *error))completion;
@end
