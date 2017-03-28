//
//  WaitView.h
//  OAOfHZBank
//
//  Created by Z&R on 7/2/13.
//  Copyright (c) 2013 P&C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface HZBWaitView : UIWindow
{

}


+(void )startLoading  ;
+(void)stopLoading ;

//自动会隐藏
+(void)show:(NSString *)message;

@end
