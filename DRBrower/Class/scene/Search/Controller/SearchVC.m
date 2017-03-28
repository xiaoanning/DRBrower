//
//  SearchVC.m
//  DRBrower
//
//  Created by QiQi on 2017/1/4.
//  Copyright © 2017年 QiQi. All rights reserved.
//
#import <WebKit/WebKit.h>

#import "SearchVC.h"
#import "MenuVC.h"
#import "ShareVC.h"
#import "RecordRootVC.h"

#import "HomeToolBar.h"

#import "RecordModel.h"
#import "ShareModel.h"
#import "MoreVC.h"
#import "AdviceVC.h"
#import "LoginVC.h"
#import "LoginModel.h"


#import "HZBWaitView.h"

#import "CSBVideoAd.h"


@interface SearchVC ()<HomeToolBarDelegate,UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,MenuVCDelegate,UIScrollViewDelegate, PYSearchViewControllerDelegate ,CSBVideoAdDelegate>
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet HomeToolBar *homeToolBar;
@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (strong, nonatomic) WKWebView *searchWV;
@property (strong, nonatomic) UIButton *exitFullScreenButton;
@property (strong, nonatomic) RecordModel *record;
@property (strong, nonatomic) ShareModel *shareModel;
@property (strong, nonatomic) NSMutableArray *historyArray;
@property (strong, nonatomic) NSString *currentUrl;
@property (strong, nonatomic) MZFormSheetPresentationViewController *formSheetController;
@property (strong, nonatomic) MZFormSheetPresentationViewController *shareFormSheetController;
@property (assign, nonatomic) CGPoint centerPoint;
@end

@implementation SearchVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.centerPoint = CGPointMake(SCREEN_WIDTH-80+25, SCREEN_HEIGHT-150+25);
    [self setupSubviews];
    
    if (self.newsModel != nil||self.recordModel != nil) {
        self.searchText = self.newsModel.url?self.newsModel.url:self.recordModel.url;
    }else if (self.sortModel.url != nil){
        self.searchText = self.sortModel.url;
    }else if (self.urlString != nil) {
        self.searchText = self.urlString;
    }
    [self webViewData];

    self.historyArray = [NSMutableArray arrayWithCapacity:5];
    
    
    
    
    
    
    [CSBVideoAd sharedInstance].delegate = self;
    [[CSBVideoAd sharedInstance] loadVideoAdWithOrientation:YES];



}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.searchWV reload];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    

}

- (void)isFullScreen {
    BOOL isFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kFullScreen];
    if (isFullScreen == NO) {
        
        self.searchWV.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-44);
    }else {
        [self setupExitFullScreenButton];
        self.searchWV.frame = self.view.bounds;
    }
    
}

- (void)setupSubviews {
    self.homeToolBar.delegate = self;
    [self.homeToolBar setBarButton:HomeToolBarRootVCTypeSearch];
    self.searchWV = [WKWebView new];
    self.searchWV.backgroundColor = [UIColor whiteColor];
    self.searchWV.navigationDelegate = self;
    self.searchWV.UIDelegate = self;
    self.searchWV.scrollView.delegate = self;
    [self isFullScreen];
    [self.view addSubview:self.searchWV];
    
}

- (void)setupExitFullScreenButton {
    self.exitFullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exitFullScreenButton setImage:[UIImage imageNamed:@"btn_exit_full_screen"] forState:UIControlStateNormal];
//    [self.exitFullScreenButton addTarget:self action:@selector(exitFullScreenButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    self.exitFullScreenButton.frame = CGRectMake(SCREEN_WIDTH-80, SCREEN_HEIGHT-150, 50, 50);
    [self.searchWV addSubview:self.exitFullScreenButton];
    
    self.exitFullScreenButton.center = self.centerPoint;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap:)];
    [self.exitFullScreenButton addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    [self.exitFullScreenButton addGestureRecognizer:pan];
}
-(void)handelTap:(UITapGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.2//动画持续时间
                     animations:^{
                         //执行的动画
                         self.navBar.center = CGPointMake(SCREEN_WIDTH*0.5, 32);
                         self.homeToolBar.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-22);
                         self.searchWV.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-44);
                     }completion:^(BOOL finished){
                         //动画执行完毕后的操作
                         [self.exitFullScreenButton removeFromSuperview];
                         
                     }];
}
-(void)handelPan:(UIPanGestureRecognizer *)gestureRecognizer{
    self.centerPoint = [gestureRecognizer locationInView:self.view];
    [self.exitFullScreenButton setCenter:self.centerPoint];
}
- (void)exitFullScreenButtonAciton:(UIButton *)button {
    [UIView animateWithDuration:0.2//动画持续时间
                    animations:^{
                        //执行的动画
                        self.navBar.center = CGPointMake(SCREEN_WIDTH*0.5, 32);
                        self.homeToolBar.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-22);
                        self.searchWV.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-44);
                    }completion:^(BOOL finished){
                        //动画执行完毕后的操作
                        [self.exitFullScreenButton removeFromSuperview];

                    }];
}

- (void)webViewData {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)[Tools urlValidation:self.searchText],(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
    
//    NSURL *url = [NSURL URLWithString:[[Tools urlValidation:self.searchText] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [self.searchWV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]]];
    
    
}

- (IBAction)didClickTitleButtonAction:(id)sender {
    if (self.isSearch == YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.navigationController.navigationBarHidden= NO;
    }else {
        // 1.创建热门搜索
        //    NSArray *hotSeaches = nil;
        // 2. 创建控制器
        PYSearchViewController *searchViewController = [PYSearchViewController searchViewControllerWithHotSearches:nil searchBarPlaceholder:@"搜索或输入网址" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
            // 开始搜索执行以下代码
            // 如：跳转到指定控制器
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
            SearchVC *searchVC = (SearchVC *)[storyboard instantiateViewControllerWithIdentifier:@"SearchVC"];
            searchVC.isSearch = YES;
            //        [searchViewController.navigationController pushViewController:searchVC animated:YES];
            [searchViewController.navigationController popViewControllerAnimated:YES];
        }];
        // 3. 设置风格
        searchViewController.searchHistoryStyle = PYHotSearchStyleDefault; // 搜索历史风格为default
        //    searchViewController.hotSearchStyle = PYHotSearchStyleDefault; // 热门搜索风格为默认
        // 4. 设置代理
        searchViewController.delegate = self;
        searchViewController.searchBar.text = self.currentUrl;
        // 5. 跳转到搜索控制器
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        [self presentViewController:nav animated:NO completion:nil];
    }
    
}

- (IBAction)didClickReloadButtonAction:(id)sender {
    [self.searchWV reload];
}

#pragma mark - WKWebView delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSString *currentURL = webView.URL.absoluteString;
    [self.titleBtn setTitle:currentURL forState:UIControlStateNormal];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSString *fontStr = [[NSUserDefaults standardUserDefaults] objectForKey:WEBVIEW_FONT];
    if (fontStr == nil) {
        fontStr = @"100%";
    }
    
    NSString *jsStr = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '%@'",fontStr];
    
    [webView evaluateJavaScript:jsStr
              completionHandler:nil];
    
    NSString *title = webView.title;
    self.currentUrl = webView.URL.absoluteString;
    [self.titleBtn setTitle:title forState:UIControlStateNormal];
    if (![title isEqualToString:@""] && ![self.currentUrl isEqualToString:@""]) {
        [self newOneRecordWithUrl:self.currentUrl title:title];
    }
    
    if (![self.searchWV canGoForward]) {
        [self.homeToolBar setBarButton:HomeToolBarRootVCTypeSearch];
    }
}
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",message);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURLRequest *currentRequest = navigationAction.request;
    NSURL *currentURL = currentRequest.URL;
    NSLog(@"url %@",currentURL);
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated){
    
        NSLog(@"%@",navigationAction.request.URL.host);
        if([currentURL.host isEqualToString:@"itunes.apple.com"]) {
            [[UIApplication sharedApplication] openURL:currentURL
                                               options:@{}
                                     completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);

        }
        else {
            [self.searchWV loadRequest:currentRequest];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        
    }
    else{
        if([currentURL.host isEqualToString:@"itunes.apple.com"]) {
            [[UIApplication sharedApplication] openURL:currentURL
                                               options:@{}
                                     completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);

        }
    
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

//接收到相应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
//    if (!navigationResponse.isForMainFrame){
//        decisionHandler(WKNavigationResponsePolicyAllow);
//    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
//    }
}

- (void)newOneRecordWithUrl:(NSString *)url title:(NSString *)title {
    self.record = [[RecordModel alloc] init];
    self.record.url = url;
    self.record.title = title;
    self.record.time = [Tools atPresentTimestamp];
    [self.record addRecordToRealm:REALM_HISTORY];

    self.shareModel = [ShareModel shareModelWithShareUrl:url
                                                   title:title
                                                    desc:[NSString stringWithFormat:@"快来看看我分享给你的网站：%@",title]
                                                 content:[NSString stringWithFormat:@"快来看看我分享给你的网站：%@",title]
                                                  image:nil];
}

#pragma mark - custom delegate

- (void)touchUpBackButtonAction {
    if ([self.searchWV canGoBack]) {
        [self.searchWV goBack];
        [self.homeToolBar setBarButton:HomeToolBarRootVCTypeUnknown];
        
    }else if(self.sortModel.url != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.urlString != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.newsModel.url != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        self.navigationController.navigationBarHidden = NO;
        [self.searchViewController dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)touchUpGoButtonActionr {
    if ([self.searchWV canGoForward]) {
        [self.searchWV goForward];
    }
}

- (void)touchUpMenuButtonAction {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Menu" bundle:[NSBundle mainBundle]];
    MenuVC *menuVC = (MenuVC *)[storyboard instantiateViewControllerWithIdentifier:@"MenuVC"];
    self.formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:menuVC];
    self.formSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
    
    self.formSheetController.presentationController.portraitTopInset = [UIScreen mainScreen].bounds.size.height - 20 - MENU_HEIGHT;
    self.formSheetController.presentationController.contentViewSize = [UIScreen mainScreen].bounds.size;
    self.formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyleSlideAndBounceFromBottom;
    
    menuVC.delegate = self;
    menuVC.rootVCType = MenuVCRootVCTypeSearch;
    
    [self presentViewController:self.formSheetController animated:YES completion:nil];
    
}
-(void)touchUpShareButtonAction {
    [self touchUpPageButtonAction];
}
- (void)touchUpPageButtonAction {
    [self snapshotScreen];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
    ShareVC *shareVC = (ShareVC *)[storyboard instantiateViewControllerWithIdentifier:@"ShareVC"];
    self.shareFormSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:shareVC];
    self.shareFormSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
    
    self.shareFormSheetController.presentationController.portraitTopInset = [UIScreen mainScreen].bounds.size.height - 240;
    self.shareFormSheetController.presentationController.contentViewSize = [UIScreen mainScreen].bounds.size;
    self.shareFormSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyleSlideAndBounceFromBottom;
    
    shareVC.shareModel = self.shareModel;
    [self presentViewController:self.shareFormSheetController animated:YES completion:nil];

}

- (void)touchUpHomeButtonAction {
    [self.searchViewController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//menu收藏
- (void)touchUpCollectButtonAction {
      self.record.time = 0;
    if (self.record) {
        if ([[DRLocaldData alloc] saveCollectData:self.record] == YES) {
            [Tools showView:COLLECT_SUCCESS];
        }else {
            [Tools showView:COLLECT_FAILED];
        }
    }else {
        [Tools showView:@"请稍后..."];
    }
}

- (void)touchUpRecordButtonAction {
    RecordRootVC *recordRootVC = [[RecordRootVC alloc] init];
    [self.navigationController showViewController:recordRootVC sender:nil];
}

- (void)touchUpFullScreenButtonAction:(BOOL)isfull {
    
    [UIView animateWithDuration:0.5//动画持续时间
                         delay:0.0//动画延迟执行的时间
                       options:UIViewAnimationOptionCurveEaseInOut//动画的过渡效果
                    animations:^{
                        if (isfull == YES) {
                            //执行的动画
                            self.navBar.center = CGPointMake(SCREEN_WIDTH*0.5, 32);
                            self.homeToolBar.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-22);
                            self.searchWV.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-44);
                        }else {
                            self.navBar.center = CGPointMake(SCREEN_WIDTH*0.5, -32);
                            self.homeToolBar.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT+22);
                            self.searchWV.frame = self.view.bounds;
                        }

                    }completion:^(BOOL finished){
                        //动画执行完毕后的操作
                        if (isfull == NO) {
                            [self setupExitFullScreenButton];

                        }

                    }];
    
}

- (void)touchUpRefreshDataButtonAction {
    [self.searchWV reload];
    
}
-(void)touchUpMoreButtonAction {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"More" bundle:[NSBundle mainBundle]];
    MoreVC *moreVC = (MoreVC *)[storyboard instantiateViewControllerWithIdentifier:@"MoreVC"];
    [self.navigationController showViewController:moreVC sender:nil];
}
-(void)touchUpSpitButtonAction {
    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Advice" bundle:[NSBundle mainBundle]];
    AdviceVC *adviceVC = (AdviceVC *)[stroyboard instantiateViewControllerWithIdentifier:@"AdviceVC"];
    [self.navigationController showViewController:adviceVC sender:nil];
}
-(void)touchUpServiceButtonAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"是否添加客服群:299032484"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Tools joinGroup:nil key:@"299032484"];
    }];;
    [alertController addAction:OKAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}
-(void)touchUpIconImageView {
    if ([TOKEN isEqualToString:@"brower*@forapi@*"]) {
        UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        LoginVC *loginVC = (LoginVC *)[stroyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:loginVC animated:YES];
    }else {
        [self cancleLoginAlert];
    }
}
-(void)cancleLoginAlert {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否退出当前账户？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cancleLogin];
    }];
    [alertVC addAction:OKAction];
    [alertVC addAction:cancleAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

//退出登陆
-(void)cancleLogin {
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&dev_id=%@&uid=%@",PHP_BASE_URL,URL_LOGOUT,TOKEN,DEV_ID,UID];
    [LoginModel cancleLoginUrl:urlString parameters:@{} block:^(NSDictionary *dic, NSError *error) {
        NSLog(@"%@",dic);
        [Tools showView:dic[@"msg"]];
        [KeychainTool deleteKeychainValue:LOGIN_TOKEN];
        [KeychainTool deleteKeychainValue:LOGIN_UID];
    }];
}


#pragma mark -scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    BOOL isFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kFullScreen];
    
    if (isFullScreen == YES) {
        [UIView animateWithDuration:0.5//动画持续时间
                              delay:0.0//动画延迟执行的时间
                            options:UIViewAnimationOptionCurveEaseInOut//动画的过渡效果
                         animations:^{
                        
                                 self.navBar.center = CGPointMake(SCREEN_WIDTH*0.5, -32);
                                 self.homeToolBar.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT+22);
                                 self.searchWV.frame = self.view.bounds;
                             
                         }completion:^(BOOL finished){
                             //动画执行完毕后的操作
                                 [self.exitFullScreenButton removeFromSuperview];
                                 [self setupExitFullScreenButton];
                             
                         }];
    }

}

/**
 *  截取当前屏幕的内容
 */
- (void)snapshotScreen
{
    // 判断是否为retina屏, 即retina屏绘图时有放大因子
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
    }
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.shareModel.image = image;
    // 保存到相册
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - search delegate
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText {
    if (searchText.length) { // 与搜索条件再搜索
        // 根据条件发送查询（这里模拟搜索）
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 搜索完毕
        //            // 显示建议搜索结果
        //            NSMutableArray *searchSuggestionsM = [NSMutableArray array];
        //            for (int i = 0; i < arc4random_uniform(5) + 10; i++) {
        //                NSString *searchSuggestion = [NSString stringWithFormat:@"搜索建议 %d", i];
        //                [searchSuggestionsM addObject:searchSuggestion];
        //            }
        //            // 返回
        //            searchViewController.searchSuggestions = searchSuggestionsM;
        //        });
    }
}

- (void)searchViewController:(PYSearchViewController *)searchViewController didSearchWithsearchBar:(UISearchBar *)searchBar searchText:(NSString *)searchText {
    NSLog(@"%@",searchText);
    if (searchText.length) { // 与搜索条件再搜索
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
        SearchVC *searchVC = (SearchVC *)[storyboard instantiateViewControllerWithIdentifier:@"SearchVC"];
        searchVC.searchText = searchText;
        searchVC.searchViewController = searchViewController;
        searchVC.isSearch = YES;
        [searchViewController.navigationController pushViewController:searchVC animated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id){

 // Invoked immediately prior to initiating a segue. Return NO to prevent the segue from firing. The default implementation returns YES. This method is not invoked when -performSegueWithIdentifier:sender: is used.

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - CSBVideoAdDelegate

// 视频广告加载成功
- (void)csbVideoAdLoadSuccess:(CSBVideoAd *)videoAd
{
    [HZBWaitView show:@"视频广告加载成功"];
    NSLog(@"----------%s", __PRETTY_FUNCTION__);
    
    [[CSBVideoAd sharedInstance] showVideoAdWithOrientation:YES];

}

// 视频广告加载失败
- (void)csbVideoAd:(CSBVideoAd *)videoAd loadFailure:(NSString *)errorMsg
{
    [HZBWaitView show:@"视频广告加载失败"];

    NSLog(@"----------%s（%@）", __PRETTY_FUNCTION__, errorMsg);
}

// 视频广告开始播放
- (void)csbVideoAdStartPlayVideo:(CSBVideoAd *)videoAd
{
    [HZBWaitView show:@"视频广告开始播放"];

    NSLog(@"----------%s", __PRETTY_FUNCTION__);
}

// 视频广告播放完成
- (void)csbVideoAdPlayFinished:(CSBVideoAd *)videoAd
{
    [HZBWaitView show:@"视频广告播放完成"];

    NSLog(@"----------%s", __PRETTY_FUNCTION__);
}

// 视频广告关闭完成
- (void)csbVideoAdDidDismiss:(CSBVideoAd *)videoAd
{
    [HZBWaitView show:@"视频广告关闭完成"];

    NSLog(@"----------%s", __PRETTY_FUNCTION__);
}



@end
