//
//  ShareVC.m
//  DRBrower
//
//  Created by QiQi on 2017/2/19.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "ShareVC.h"
#import "ShareView.h"

@interface ShareVC ()

@property(strong,nonatomic)ShareView *shareView;
@end

@implementation ShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.shareView = [[[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil] objectAtIndex:0];
    [self.shareView.titleLabel.superview bringSubviewToFront:self.shareView.titleLabel];
    self.shareView.frame = CGRectMake(0, 0, self.view.frame.size.width, 245);
    [self.view addSubview:self.shareView];
    [self verifyShareModel];

    [self.shareView shareButtonClick:^(SSDKPlatformType type) {
        [self shareSDK:type];
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissView) name:DISMISS_VIEW object:nil];
    
    // Do any additional setup after loading the view.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)verifyShareModel {
    if (self.shareModel == nil) {
        self.shareModel = [ShareModel shareModelWithShareUrl:URL_SHARE
                                                         title:NSLocalizedString(@"酷搜浏览器", nil)
                                                          desc:NSLocalizedString(@"下载酷搜浏览器，查看最新动态资讯，更多使用功能等你来体验", nil)
                                                       content:NSLocalizedString(@"下载酷搜浏览器，查看最新动态资讯，更多使用功能等你来体验", nil)
                                                         image:[UIImage imageNamed:@"share_logo"]];
    }
}

- (void)shareSDK:(SSDKPlatformType)shareType  {
    
    UIImage *image = [UIImage imageCompressForWidth:self.shareModel.image targetWidth:50];
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:self.shareModel.content
                                     images:image
                                        url:[NSURL URLWithString:self.shareModel.shareUrl]
                                      title:self.shareModel.title
                                       type:SSDKContentTypeAuto];
    
    [ShareSDK share:shareType
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         switch (state) {
             case SSDKResponseStateBegin:
                 break;
             case SSDKResponseStateSuccess: {
                 [self showView:@"分享成功"];
                 NSLog(@"分享成功");
                 break;
             }
             case SSDKResponseStateFail: {
                 [self showView:@"分享失败"];
                 NSLog(@"分享失败");
                 break;
             }
             case SSDKResponseStateCancel: {
                 NSLog(@"分享取消");
                 break;
             }
         }
         [[NSNotificationCenter defaultCenter]postNotificationName:DISMISS_VIEW object:nil];
     }];
}

-(void)showView:(NSString *)title{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.frame = CGRectMake(SCREEN_WIDTH*0.5-100, SCREEN_HEIGHT*0.5-50, 200, 100);
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(title, @"HUD message title");
    hud.tintColor = [UIColor whiteColor];
    [hud hideAnimated:YES afterDelay:2.f];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
