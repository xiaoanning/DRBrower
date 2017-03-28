//
//  WaitView.m
//  PufaBankMobile
//
//  Created by yk on 11-1-7.
//	Copyright 2011 P&C. All rights reserved.
//

#import "HZBWaitView.h"

typedef NS_ENUM(NSInteger , KKShowTypeEnum)
{
    KKShowLoading = 1 ,
    KKShowText = 2 ,

};

@interface HZBWaitView ()

@property ( nonatomic , assign ) KKShowTypeEnum showType ;

@property ( nonatomic , assign ) BOOL loading ;
@property ( nonatomic , retain ) UIView * loadMainView ;

@property ( nonatomic , retain ) UIImageView * textbackgroundView ;
@property ( nonatomic , retain ) UILabel * textLabel ;
@property ( nonatomic , assign ) BOOL showingText ;

@end

@implementation HZBWaitView

static HZBWaitView * _instance = nil;
+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [HZBWaitView shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [HZBWaitView shareInstance] ;
}


+(void )startLoading
{
    HZBWaitView * waitView = [HZBWaitView shareInstance];
    waitView.hidden = YES ;
    
    if ([waitView showType] == KKShowLoading)
    {
        [waitView setHidden:NO];
        
        if ([waitView loading])
        {

        }else
        {
            [waitView setLoading:YES];
        }
        
        return  ;

    }else if ([waitView showType] == KKShowText)
    {
        waitView.textbackgroundView.hidden = YES ;
        waitView.showingText = NO ;
    }
    
    
    [waitView setHidden:NO];
    CGRect screenBounds = [[UIScreen mainScreen]bounds] ;

    waitView.frame = screenBounds ;
    waitView.showType = KKShowLoading ;
    waitView.loading = YES ;
    waitView.backgroundColor = [UIColor clearColor];
    
    //遮罩层
    waitView.loadMainView = [[UIView alloc] initWithFrame:screenBounds];
    waitView.loadMainView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0f];
    [waitView addSubview:waitView.loadMainView];

    //加载的背景图
    CGFloat backViewWidth = 90.0f ;
    UIImageView * backView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(screenBounds) - backViewWidth) / 2,(CGRectGetHeight(screenBounds) - backViewWidth) / 2, backViewWidth,backViewWidth)];
    [backView setImage:[UIImage imageNamed:@"loading_background.png"]];
    [backView setBackgroundColor:[UIColor clearColor]];
    backView.layer.cornerRadius = 7.0f ;
    backView.clipsToBounds = YES ;
    [waitView.loadMainView addSubview:backView];

    //GIF图片
    CGFloat gifWidth = 45.0f;
    CGFloat gifSpace = (backViewWidth - gifWidth)/2.0  ;
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(gifSpace, gifSpace, gifWidth, gifWidth)];
    NSArray *gifArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"spinner_01.png"],[UIImage imageNamed:@"spinner_02.png"],[UIImage imageNamed:@"spinner_03.png"],[UIImage imageNamed:@"spinner_04.png"],[UIImage imageNamed:@"spinner_05.png"],[UIImage imageNamed:@"spinner_06.png"],[UIImage imageNamed:@"spinner_07.png"],[UIImage imageNamed:@"spinner_08.png"],[UIImage imageNamed:@"spinner_09.png"],[UIImage imageNamed:@"spinner_10.png"],[UIImage imageNamed:@"spinner_11.png"],[UIImage imageNamed:@"spinner_12.png"],nil];
    gifImageView.animationImages = gifArray;
    gifImageView.animationDuration = 1;
    gifImageView.animationRepeatCount = 0;
    [gifImageView startAnimating];
    [backView addSubview:gifImageView];
    
    

    [waitView setWindowLevel:UIWindowLevelAlert ];
    [waitView makeKeyAndVisible];
    
}

+(void)stopLoading
{
    HZBWaitView * waitView = [HZBWaitView shareInstance];
    waitView.loading = NO ;
    waitView.hidden = !waitView.showingText ;
}

+(void)show:(NSString *)message
{
    HZBWaitView * waitView = [HZBWaitView shareInstance];
    waitView.hidden = YES ;
    
    if ([waitView showType] == KKShowText)
    {
        if ([waitView showingText])
        {
            [waitView setHidden:YES];
            [waitView.layer removeAllAnimations ];
            
        }else
        {
            
        }

        [[waitView textLabel]setText:message];

        [self setViewFrame:waitView];
        
        [self animate:waitView];
        
        return ;

    }else if([waitView showType] == KKShowLoading)
    {
        waitView.loadMainView.hidden = YES ;
        waitView.loading = NO ;
    }
    
    
    waitView.showType = KKShowText ;
    waitView.showingText = YES ;
    waitView.backgroundColor = [UIColor clearColor];
    
    
    //加载的背景图
    waitView.textbackgroundView = [[UIImageView alloc] init];
    waitView.textbackgroundView.hidden = NO ;
    [waitView.textbackgroundView setImage:[UIImage imageNamed:@"loading_background.png"]];
    [waitView.textbackgroundView setBackgroundColor:[UIColor clearColor]];
    waitView.textbackgroundView.layer.cornerRadius = 7.0f ;
    waitView.textbackgroundView.clipsToBounds = YES ;
    [waitView.textbackgroundView setContentMode:UIViewContentModeScaleToFill];
    [waitView addSubview:waitView.textbackgroundView];
    
    //文字
    waitView.textLabel = [[UILabel alloc]init ];
    waitView.textLabel.text = [NSString stringWithFormat:@"%@",message];
    waitView.textLabel.font = [UIFont systemFontOfSize:12.0f];
    waitView.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.85];
    waitView.textLabel.textAlignment = NSTextAlignmentCenter ;
    waitView.textLabel.numberOfLines = 0 ;
//    waitView.textLabel.backgroundColor = [UIColor blueColor];
    [waitView.textbackgroundView addSubview:waitView.textLabel];
    
    [self setViewFrame:waitView];
    
    [waitView setWindowLevel:UIWindowLevelAlert ];
    [waitView makeKeyAndVisible];
    
    [self animate:waitView];

}

+(void)setViewFrame:(HZBWaitView *)waitView
{
    CGFloat minTextHeight = 45.0f ;

    CGRect screenBounds = [[UIScreen mainScreen]bounds] ;
    CGFloat backgroundViewWidth = 200.0f ;
    CGFloat backgroundViewHeight = 0.0f ;
    
    
    CGSize size = [waitView.textLabel sizeThatFits:CGSizeMake(backgroundViewWidth-20, 200)];
    CGFloat newHeight = size.height + 20 ;
    
    if (newHeight < minTextHeight)
    {
        backgroundViewHeight = minTextHeight ;
    }else
    {
        backgroundViewHeight = newHeight;
    }
    
    waitView.textLabel.frame = CGRectMake(0, 0, backgroundViewWidth, backgroundViewHeight) ;
    waitView.textLabel.superview.frame = CGRectMake(0, 0, backgroundViewWidth, backgroundViewHeight)  ;
    waitView.frame = CGRectMake((CGRectGetWidth(screenBounds) - backgroundViewWidth) / 2, CGRectGetHeight(screenBounds)/2.0 - backgroundViewHeight/2.0, backgroundViewWidth, backgroundViewHeight) ;

}

+(void)animate:(HZBWaitView *)waitView
{
    waitView.hidden = NO ;
//    waitView.backgroundColor = [UIColor redColor];

    [UIView animateWithDuration:2 animations:^{
        
        waitView.alpha = 0.99 ;
        
    } completion:^(BOOL finished) {

        waitView.alpha = 1.0 ;
        waitView.showingText = NO ;
        waitView.hidden = YES ;
    }];

}

@end


