//
//  RecordRootVC.m
//  DRBrower
//
//  Created by QiQi on 2017/2/23.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "RecordRootVC.h"

#import "HistoryVC.h"
#import "CollectVC.h"

@interface RecordRootVC ()

@property (nonatomic, strong)CollectVC *collectVC;
@property (nonatomic, strong)HistoryVC *historyVC;
@property (nonatomic, strong)UIBarButtonItem *emptyButton;

@end

@implementation RecordRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Menu" bundle:[NSBundle mainBundle]];
    self.collectVC = (CollectVC *)[storyboard instantiateViewControllerWithIdentifier:@"CollectVC"];
    self.collectVC.rootVCType = CollectVCRootVCTypeRecord;
    self.collectVC.recordRootVC = self;
    
    self.historyVC = (HistoryVC *)[storyboard instantiateViewControllerWithIdentifier:@"HistoryVC"];
    self.historyVC.recordRootVC = self;
    
    NSArray *viewControllers = @[self.collectVC, self.historyVC];
    self.viewControllers = viewControllers;
    
    self.emptyButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_btn_trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(emptyButtonAction:)];
    
    if ([self.collectVC.collectArray count] > 10) {
        self.navigationItem.rightBarButtonItem = self.emptyButton;
    }else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.title = NSLocalizedString(@"收藏/历史", nil);
    
    // Do any additional setup after loading the view.
}

- (void)emptyInCollectButtonClick:(CollectRelaodTabelBlock)block {
    _collectReloadBlock = [block copy];
}

- (void)emptyInHistoryButtonClick:(HistoryRelaodTabelBlock)block {
    _historyReloadBlock = [block copy];
}

- (void)backButtonAction:(UIBarButtonItem *)barButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)emptyButtonAction:(UIBarButtonItem *)barButton {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定清楚所有记录？"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                         self.navigationItem.rightBarButtonItem = nil;
                                                         if (self.selectedIndex == 0) {
                                                             if (_collectReloadBlock) {
                                                                 _collectReloadBlock();
                                                             }
                                                         }else {
                                                             if (_historyReloadBlock) {
                                                                 _historyReloadBlock();
                                                             }
                                                         }
                                                     }];
    [alertController addAction:OKAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
  
}

- (void)tabBar:(AXTabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [super tabBar:tabBar didSelectItem:item];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    switch (self.selectedIndex) {
        case 0:
            if ([self.collectVC.collectArray count] > 10) {
                self.navigationItem.rightBarButtonItem = self.emptyButton;
            }else {
                self.navigationItem.rightBarButtonItem = nil;
            }
            break;
        case 1:
            if ([self.historyVC.historyArray count] > 10) {
                self.navigationItem.rightBarButtonItem = self.emptyButton;
            }else {
                self.navigationItem.rightBarButtonItem = nil;
            }
            break;
            
        default:
            break;
    }

    
    
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
