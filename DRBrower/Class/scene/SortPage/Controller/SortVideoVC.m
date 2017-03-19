//
//  SortVideoVC.m
//  DRBrower
//
//  Created by apple on 2017/3/1.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "SortVideoVC.h"
#import "SortModel.h"
#define VIDEOLIST @"videoList"

@interface SortVideoVC ()
@property (nonatomic,assign) NSInteger page;
@end

@implementation SortVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sortListArray = [NSMutableArray array];
    self.page = 1;
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.sortTagModel.name image:nil tag:0];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"sortType" object:nil];
    
    self.sortListArray = [SortModel realmSelectAllSortFromRealm:VIDEOLIST];
    if (self.sortListArray.count > 0) {
//        [self.tableView reloadData];
    }else {
        [self getSortListByModel:self.sortTagModel type:nil sort:nil];
    }
}
- (void) tongzhi:(NSNotification *)notification{
    NSString *sortType = notification.object;
    [self getSortListByModel:self.sortTagModel type:DOWN_LOAD sort:sortType];
}

- (void)loadMoreData {
    //1.请求数据\2.刷新表格\3.拿到当前的下拉刷新控件，结束刷新状态
    [self getSortListByModel:self.sortTagModel type:UP_LOAD sort:nil];
    [self.tableView.mj_footer endRefreshing];
    self.page += 1;
    NSLog(@"上拉刷新");
}

//获取排行列表
- (void)getSortListByModel:(SortTagModel *)model type:(NSString *)type sort:(NSString *)sort{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (sort == nil || [sort integerValue] ==0) {
        sort = @"visit_num";
    }else if ([sort integerValue] ==1) {
        sort = @"love_num";
    }else if ([sort integerValue] ==2) {
        sort = @"updatetime";
    }
    
    if (self.page <1) {
        self.page = 1;
    }
    [SortModel deleteAllSortFromRealm:VIDEOLIST];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&page_num=%@&site_type=%@&sort=%@",PHP_BASE_URL,URL_SORTLIST,TOKEN,[NSString stringWithFormat:@"%ld",(long)self.page],model.site_type,sort];
    [SortModel getSortListUrl:urlString parameters:@{} block:^(SortListModel *newsList, NSError *error) {
        if ([type isEqualToString:DOWN_LOAD]) {
            [self.sortListArray insertObjects:newsList.list
                                    atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newsList.list count])]];
            
        }else {
            [self.sortListArray addObjectsFromArray:newsList.list];
        }
        //保存到Realm
        for (SortModel *sortModel in self.sortListArray) {
            [sortModel addSortToRealm:VIDEOLIST];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
    }];

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
