//
//  WebsiteModel.h
//  DRBrower
//
//  Created by QiQi on 2017/1/7.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebsiteListModel.h"

@interface WebsiteModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *icon;
@property (nonatomic, strong)NSString *url;
@property (nonatomic, assign)BOOL isAdd;


+ (NSURLSessionDataTask *)getWebsiteUrl:(NSString *)url
                               parameters:(NSDictionary *)parameters
                                    block:(void (^)(WebsiteListModel *websiteList,
                                                    NSError *error))completion;

-(NSMutableArray *)EqualModels:(NSMutableArray *)array newArray:(NSMutableArray *)newArray;
@end
