//
//  NSMutableArray+ZQQMutableArray.m
//  DRBrower
//
//  Created by QiQi on 2017/3/15.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "NSMutableArray+ZQQMutableArray.h"
#import "WebsiteModel.h"

@implementation NSMutableArray (ZQQMutableArray)
-(void)containsObjectModel:(NSMutableArray *)model{

    for (WebsiteModel *object in self) {
        for (WebsiteModel *new in model) {
            if ([object.name isEqualToString:new.name]) {
                object.isAdd = YES;
                break;
            }else{
            
                object.isAdd = NO;

            }
            
        }
    }
}

@end
