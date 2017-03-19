//
//  UserInfo.m
//  DRBrower
//
//  Created by QiQi on 2017/3/9.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (void)userInfoDefaults:(NSString *)gender {
    [[NSUserDefaults standardUserDefaults] setObject:gender forKey:USERINFO_GENDER];
}

+ (NSString *)getUserGender {
    NSString *gender = [[NSUserDefaults standardUserDefaults] objectForKey:USERINFO_GENDER];
    return gender;
}

+ (NSURLSessionDataTask *)firstLaunchBlock:(void (^)(id, NSError *))completion {
    
    NSString *urlStr = [[URL_FirstLAUNCH stringByReplacingOccurrencesOfString:@"DEVID" withString:[UserInfo getDeviceID]] stringByReplacingOccurrencesOfString:@"SEX" withString:[NSString stringWithFormat:@"%ld",[UserInfo getGenderType]]];
    
    return [[DRDataService sharedClient] DR_get:[PHP_BASE_URL stringByAppendingString:urlStr]
                                     parameters:@{}
                                     completion:^(id response, NSError *error, NSDictionary *header) {
                                        
                                         completion(response, error);
                                     }];
}

+ (NSURLSessionDataTask *)everyLaunchBlock:(void (^)(id, NSError *))completion {
    NSString *urlStr = [URL_EVERYLAUNCH stringByReplacingOccurrencesOfString:@"DEVID" withString:[UserInfo getDeviceID]];
    NSLog(@"%@",[PHP_BASE_URL stringByAppendingString:urlStr]);
    return [[DRDataService sharedClient]DR_get:[PHP_BASE_URL stringByAppendingString:urlStr]
                                    parameters:@{}
                                    completion:^(id response, NSError *error, NSDictionary *header) {
                                        
                                        completion(response, error);
                                    }];
}

+ (NSString *)getDeviceID {
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    return identifierForVendor;
}

+ (UserGenderType)getGenderType {
    NSString *gender = [UserInfo getUserGender];
    if ([gender isEqualToString:@"男"]) {
        return UserGenderTypeMan;
    }else if ([gender isEqualToString:@"女"]) {
        return UserGenderTypeWoman;
    }else {
        return UserGenderTypeUnknown;
    }
        
}

@end
