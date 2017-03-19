//
//  CollectVC.m
//  DRBrower
//
//  Created by QiQi on 2017/2/8.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "CollectVC.h"
#import "SearchVC.h"
#import "RecordRootVC.h"
#import "RecordCell.h"
#import "RecordModel.h"
#import "WebsiteRecommendCell.h"

static NSString *const recordCellIdentifier = @"RecordCell";
static NSString *const websiteRecommendCellIdentifier = @"WebsiteRecommendCell";

@interface CollectVC ()<SWTableViewCellDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>


@end

@implementation CollectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"收藏" image:nil tag:0];
    [self setupTableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.collectArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveCollectData]];
        if (self.collectArray.count>0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    });

//    self.collectArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveCollectData]];
    
    [self setupEmptyView];
    if ([self.collectArray count] == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.recordRootVC emptyInCollectButtonClick:^{
        [DRLocaldData deleteAllCollectData];
        [self.collectArray removeAllObjects];
        [self.tableView reloadData];
        [Tools showView:@"清除成功"];
    }];
    
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:recordCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"WebsiteRecommendCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:websiteRecommendCellIdentifier];

}

- (IBAction)backBarButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:DISMISS_VIEW object:nil];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.collectArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecordModel *model = self.collectArray[indexPath.row];

    if (self.rootVCType == CollectVCRootVCTypeRecord) {
        RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:recordCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.rightUtilityButtons = [self rightButtons];
        [cell recordCell:cell model:model];
        return cell;

    }else {
        
        WebsiteRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:websiteRecommendCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WebsiteModel *website = [self changeToWebsiteWithRecord:model];
        [cell websiteRecommendCell:cell model:website];
        return cell;
    }
}

- (WebsiteModel *)changeToWebsiteWithRecord:(RecordModel *)record {
    WebsiteModel *website = [[WebsiteModel alloc] init];
    website.name = record.title;
    website.url = record.url;
    website.icon = @"icon";
    website.isAdd = YES;
    if (![[DRLocaldData achieveWebsiteData] containsObject:website]) {
        website.isAdd = NO;
    }

    return website;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.rootVCType == CollectVCRootVCTypeWebsite) {
        
        RecordModel *record = self.collectArray[indexPath.row];
        WebsiteModel *website = [self changeToWebsiteWithRecord:record];
        website.isAdd = YES;
        NSMutableArray *array = [NSMutableArray arrayWithArray:[DRLocaldData achieveWebsiteData]];
        
        if ([array containsObject:website] == NO) {
            
            [array addObject:website];
            [DRLocaldData saveWebsiteData:array];
            [Tools showView:@"已添加到主页"];
            [self.tableView reloadData];
//            [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
        SearchVC *searchVC = (SearchVC *)[storyboard instantiateViewControllerWithIdentifier:@"SearchVC"];
        searchVC.recordModel = self.collectArray[indexPath.row];
        [self.navigationController pushViewController:searchVC animated:YES];
    }

}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell
didTriggerRightUtilityButtonWithIndex:(NSInteger)index {

    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    RecordModel *model = self.collectArray[cellIndexPath.row];
    [DRLocaldData deleteOneCollectData:model];
    [self.collectArray removeObjectAtIndex:(NSUInteger)index];
    [self.tableView deleteRowsAtIndexPaths:@[ cellIndexPath ]
                          withRowAnimation:UITableViewRowAnimationLeft];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    // allow just one cell's utility button to be open at once
    return YES;
}

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor grayColor]
                                                title:@"取消收藏"];
    return rightUtilityButtons;
}

#pragma mark - Stretchable Sub View Controller View Source

- (UIScrollView *)stretchableSubViewInSubViewController:(id)subViewController
{
    return self.tableView;
}

#pragma mark - 空白页
- (void)setupEmptyView {
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无收藏记录";
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName : [UIColor darkGrayColor]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName : paragraph
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
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
