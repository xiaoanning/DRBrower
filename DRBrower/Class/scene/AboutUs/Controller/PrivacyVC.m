//
//  PrivacyVC.m
//  DRBrower
//
//  Created by QiQi on 2017/3/16.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "PrivacyVC.h"

@interface PrivacyVC ()
@property (weak, nonatomic) IBOutlet UIWebView *privacyWV;

@end

@implementation PrivacyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"使用协议";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self setWebViewData];
}

- (void)backButtonAction:(UIBarButtonItem *)barButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setWebViewData {
    self.privacyWV.backgroundColor = colorWithvalue(@"999999");
    NSString *htmlPath = [[[NSBundle mainBundle]bundlePath]stringByAppendingString:@"/agreement.html"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.privacyWV loadRequest:urlRequest];
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
