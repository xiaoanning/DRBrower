//
//  MoreVC.m
//  DRBrower
//
//  Created by apple on 2017/2/28.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "MoreVC.h"
#import "BrightnessVC.h"
#import "SearchVC.h"
#import "SettingCell.h"
#import "AboutUsVC.h"

static NSString *const settingCellIdentifier = @"SettingCell";


@interface MoreVC ()
@property (weak, nonatomic) IBOutlet UILabel *cacheLbl;
@property (weak, nonatomic) IBOutlet UILabel *fontLbl;
@property (nonatomic,strong) NSMutableArray *switchStatusArray;
@property (nonatomic,assign) double cacheSize;
@end

@implementation MoreVC

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"更多";
    self.fontLbl.text = [self getWebViewFont];
    self.switchStatusArray = [NSMutableArray array];
    
    [self getCache];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
}
-(void)getCache{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.cacheSize = [self getCacheSize];
        if (self.cacheSize >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cacheLbl.text = [NSString stringWithFormat:@"%.2f M",self.cacheSize];
                [self.tableView reloadData];
            });
        }
    });
}

- (void)backButtonAction:(UIBarButtonItem *)barButton {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0: //清理缓存
                    if (self.cacheSize == 0) {
                        [Tools showView:@"无需清理"];
                    }else {
                        [self cleanCacheAlert];
                    }
                    break;
                case 1: //字体大小
                    [self changeWebViewFontSize];
                    break;
                case 2: //调整亮度
                    [self createBrightnessView];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (NSString *)getWebViewFont {
    NSString *fontStr = [[NSUserDefaults standardUserDefaults] objectForKey:WEBVIEW_FONT_KEY];
    if (fontStr == nil) {
        fontStr = @"正常";
    }
    return fontStr;
}

- (void)changeWebViewFontSize {
    
    UIAlertController *fontSizeAlert = [UIAlertController alertControllerWithTitle:@"设置字体大小"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"取消"
                                             style:UIAlertActionStyleCancel
                                           handler:nil];
    
    
    UIAlertAction *maxAction = [UIAlertAction
                                actionWithTitle:@"大号字体"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * _Nonnull action) {
                                          [[NSUserDefaults standardUserDefaults] setObject:@"120%"
                                                                                    forKey:WEBVIEW_FONT];
                                          [[NSUserDefaults standardUserDefaults] setObject:@"大"
                                                                                    forKey:WEBVIEW_FONT_KEY];
                                            self.fontLbl.text = [self getWebViewFont];
                                          [self.tableView reloadData];

                                      }];
    UIAlertAction *defaultAction = [UIAlertAction
                                    actionWithTitle:@"正常字体"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                              [[NSUserDefaults standardUserDefaults] setObject:@"100%"
                                                                                        forKey:WEBVIEW_FONT];
                                              [[NSUserDefaults standardUserDefaults] setObject:@"正常"
                                                                                        forKey:WEBVIEW_FONT_KEY];
                                                self.fontLbl.text = [self getWebViewFont];
                                              [self.tableView reloadData];

                                          }];
    UIAlertAction *smallAction = [UIAlertAction
                                  actionWithTitle:@"小号字体"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
                                              [[NSUserDefaults standardUserDefaults] setObject:@"80%"
                                                                                        forKey:WEBVIEW_FONT];
                                              [[NSUserDefaults standardUserDefaults] setObject:@"小"
                                                                                        forKey:WEBVIEW_FONT_KEY];
                                              self.fontLbl.text = [self getWebViewFont];
                                              [self.tableView reloadData];
                                        }];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:WEBVIEW_FONT_KEY] isEqualToString:@"小"]) {
        if (![smallAction valueForKey:@"titleTextColor"]) {
            [smallAction setValue:colorWithvalue(@"999999") forKey:@"titleTextColor"];
        }
    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:WEBVIEW_FONT_KEY] isEqualToString:@"大"]) {
        if (![maxAction valueForKey:@"titleTextColor"]) {
            [maxAction setValue:colorWithvalue(@"999999") forKey:@"titleTextColor"];
        }
    }else {
        if (![defaultAction valueForKey:@"titleTextColor"]) {
            [defaultAction setValue:colorWithvalue(@"999999") forKey:@"titleTextColor"];
        }
    }
   

    [fontSizeAlert addAction:maxAction];
    [fontSizeAlert addAction:defaultAction];
    [fontSizeAlert addAction:smallAction];
    [fontSizeAlert addAction:cancelAction];
    
    [self presentViewController:fontSizeAlert animated:YES completion:nil];
}


////创建右侧switch
//-(void)createSwitchOnCell:(UITableViewCell *)cell index:(NSInteger)index{
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
//    aSwitch.tag = index+100;
//    [cell addSubview:aSwitch];
//    if ([[DRLocaldData achieveSwitchData] containsObject:[NSString stringWithFormat:@"%ld",(long)index+100]]) {
//        aSwitch.on = YES;
//    }else {
//        aSwitch.on = NO;
//    }
//    [aSwitch addTarget:self action:@selector(touchUpSwitch:) forControlEvents:UIControlEventTouchUpInside];
//    [aSwitch mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(cell.mas_top).with.offset(10);
//        make.bottom.equalTo(cell.mas_bottom).with.offset(10);
//        make.right.equalTo(cell.mas_right).with.offset(-10);
//    }];
//}
//-(void)touchUpSwitch:(UISwitch *)aSwitch {
//    NSString *aSwitchTag = [NSString stringWithFormat:@"%ld",(long)aSwitch.tag];
//    if ([[DRLocaldData achieveSwitchData] containsObject:aSwitchTag]) { //开--->关
//        aSwitch.on = NO;
//        [self.switchStatusArray removeObject:aSwitchTag];
//        
//    }else {//关--->开
//        aSwitch.on = YES;
//        [self.switchStatusArray addObject:aSwitchTag];
//        
//    }
//    [DRLocaldData saveSwitchData:self.switchStatusArray];
//}

-(void)cleanCacheAlert {
    UIAlertController *cacheAlert = [UIAlertController alertControllerWithTitle:@"是否清理文件缓存" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cacheAlert addAction:cancelAction];

    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearCache];
        [self.tableView reloadData];
    }];;
    [cacheAlert addAction:OKAction];
    
    [self presentViewController:cacheAlert animated:YES completion:nil];
}

- (double)getCacheSize {
    //清除缓存
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    //image 缓存
    NSUInteger fileSize = [imageCache getSize];
    
    //本地下载缓存
    NSString *myCache = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/MyCaches"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSDictionary *dict = [fm attributesOfItemAtPath:myCache error:nil];
    //sdwebimage缓存+ 本地下载缓存
    fileSize += dict.fileSize;
    double size = fileSize/1024.0/1024.0;
    return size;
}

-(void)clearCache{
    //清理sd 的内存
    [[SDImageCache sharedImageCache] clearMemory];
    //清理sd 缓存
    [[SDImageCache sharedImageCache] clearDisk];
    //清除 本地其他缓存
    //本地下载缓存
    NSString *myCache = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/MyCaches"];
    [[NSFileManager defaultManager] removeItemAtPath:myCache error:nil];
    
    [Tools showView:@"清理完成"];
    [self getCache];
}
//亮度
-(void)createBrightnessView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brightness" bundle:[NSBundle mainBundle]];
    BrightnessVC *brightnessVC = (BrightnessVC *)[storyboard instantiateViewControllerWithIdentifier:@"BrightnessVC"];
    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:brightnessVC];
    formSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
    formSheetController.presentationController.portraitTopInset = [UIScreen mainScreen].bounds.size.height - 160;
    formSheetController.presentationController.contentViewSize = [UIScreen mainScreen].bounds.size;
    formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyleSlideAndBounceFromBottom;
    //    brightnessVC.delegate = self;
    [self presentViewController:formSheetController animated:YES completion:nil];
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
