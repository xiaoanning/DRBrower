//
//  WebsiteModel.m
//  DRBrower
//
//  Created by QiQi on 2017/1/7.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "WebsiteModel.h"

@implementation WebsiteModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

+ (NSURLSessionDataTask *)getWebsiteUrl:(NSString *)url
                             parameters:(NSDictionary *)parameters
                                  block:(void (^)(WebsiteListModel *websiteList,
                                                  NSError *error))completion {
    return [[DRDataService sharedClient] DR_get:url
                                     parameters:parameters
                                     completion:^(id response, NSError *error, NSDictionary *header) {
                                         WebsiteListModel *websiteList =
                                         [MTLJSONAdapter modelOfClass:[WebsiteListModel class]
                                                   fromJSONDictionary:response[@"data"]
                                                                error:&error];
                                         completion(websiteList, error);
                                     }];
}
-(void)isEqualModel:(WebsiteModel *)model{
    
    if (self.name == model.name) {
         self.isAdd = YES;
        
    }else{
        self.isAdd = NO;
    }

}

-(NSMutableArray *)EqualModels:(NSMutableArray *)array newArray:(NSMutableArray *)newArray{


    for (WebsiteModel *object in newArray) {
        [self isEqualModel:object];
    }
    
    
    for (int i = 0; i > newArray.count; i++) {
        
        
    }
    

    return array;

}

@end
