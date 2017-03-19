//
//  SortCommonVC.m
//  DRBrower
//
//  Created by apple on 2017/3/1.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "SortCommonVC.h"
#import "RankingCell.h"
#import "CommentVC.h"
#import "ComplainVC.h"
#import "SearchVC.h"

@interface SortCommonVC ()<UITableViewDelegate,UITableViewDataSource,CommitComplainDelegate,RankingButtonDelegate>
//@property (nonatomic,strong) NSMutableArray *sortListArray;
@property (nonatomic,assign) NSInteger fitHeight;

@property (nonatomic,strong) NSMutableArray *localZanArray; //本地存储已点赞下标
@property (nonatomic,strong) NSMutableArray *localComplainArray; //本地存储已举报下标
@property (nonatomic,assign) NSInteger currentComplainIndex;//当前举报所在列
@property (nonatomic,strong) NSMutableArray *selectedArray;//已看列表

@end

@implementation SortCommonVC
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTableView];
    
    [self fooderRereshing];
    [self headerRereshing];
//    [self getSortListByModel:self.sortTagModel type:nil sort:nil];
}
#pragma mark - 上下拉刷新
//下拉
- (void)headerRereshing {
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header =
    [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
}

//上拉
- (void)fooderRereshing {
    
    [self headerRereshing];
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer =
    [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}

- (void)loadNewData {
    // 1.请求数据\2.刷新表格\3.拿到当前的下拉刷新控件，结束刷新状态
    
    [self getSortListByModel:self.sortTagModel type:DOWN_LOAD sort:nil];
    [self.tableView.mj_header endRefreshing];
    NSLog(@"下拉刷新");
}
-(void)getSortListByModel:(SortTagModel *)model type:(NSString *)type sort:(NSString *)sort {
    
}
- (void)loadMoreData {
    //1.请求数据\2.刷新表格\3.拿到当前的下拉刷新控件，结束刷新状态
    [self getSortListByModel:self.sortTagModel type:UP_LOAD sort:nil];
    [self.tableView.mj_footer endRefreshing];
    
    NSLog(@"上拉刷新");
}
//点赞请求
-(void)addLoveWithModel:(SortModel *)model {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.localZanArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveZanData]];
    if (![self.localZanArray containsObject:model.sort_id]) {
        [self.localZanArray addObject:model.sort_id];
        [DRLocaldData saveZanData:self.localZanArray];
    }
    
    NSString *url_md5 = model.url_md5;
    NSString *signOrigin = [NSString stringWithFormat:@"%@%@%@",[DEV_ID substringWithRange:NSMakeRange(0, 5)],[url_md5 substringWithRange:NSMakeRange(0, 5)],@"dr_love_2017"];
    NSString *sign = [[Tools md5:signOrigin] lowercaseString];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?dev_id=%@&url_md5=%@&sign=%@",BASE_URL,URL_ADDLOVE,DEV_ID,url_md5,sign];
    
    [SortModel addLoveUrl:urlString parameters:@{} block:^(NSDictionary *dic, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (dic.allKeys.count>0) {
            NSString *infoStr = [dic objectForKey:@"info"];
            [Tools showView:infoStr];
            [self.tableView reloadData];
        }
    }];
}
//举报请求
-(void)addComplainWithModel:(SortModel *)model content:(NSString *)content{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //获取本地存储数据
    self.localComplainArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveComplainData]];
    if (![self.localComplainArray containsObject:model.sort_id]) {
        [self.localComplainArray addObject:model.sort_id];
        [DRLocaldData saveComplainData:self.localComplainArray];
    }
    //   NSString *str = [content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&url_md5=%@&content=%@",BASE_URL,URL_ADDCOMPLAIN,[DEV_ID substringToIndex:8],model.url_md5,content];
    [SortModel addComplainUrl:[Tools urlEncodedString:urlString] parameters:@{} block:^(NSDictionary *dic, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (dic.allKeys.count>0) {
            NSString *infoStr = [dic objectForKey:@"info"];
            [Tools showView:infoStr];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Stretchable Sub View Controller View Source
- (UIScrollView *)stretchableSubViewInSubViewController:(id)subViewController
{
    return self.tableView;
}
#pragma mark ----------------tableView--------------
-(void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    //layout
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
    
    [_tableView registerNib:[UINib nibWithNibName:@"RankingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rankingCell"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sortListArray && self.sortListArray.count > 0) {
        return self.sortListArray.count;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankingCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SortModel *sortModel = self.sortListArray[indexPath.row];
    [cell rankingCell:cell model:sortModel index:indexPath.row];
    [self resetButtonState:cell model:sortModel]; //更改状态
    cell.delegate = self;
    cell.zanButton.tag = indexPath.row;
    cell.zanLabel.tag = 10+indexPath.row;
    cell.informButton.tag = 100+indexPath.row;
    cell.informLabel.tag = 1000+indexPath.row;
    cell.commentButton.tag = 200+indexPath.row;
    cell.commentCountButton.tag = 300+indexPath.row;
    
//    _fitHeight = [self fitToText:cell.titleLabel text:sortModel.name];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SortModel *sortModel = self.sortListArray[indexPath.row];
    
    RankingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = [UIColor grayColor];
    self.selectedArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveSelectedData]];
    if (![self.selectedArray containsObject:sortModel.sort_id]) {
        [self.selectedArray addObject:sortModel.sort_id];
        [DRLocaldData saveSelectedData:self.selectedArray];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
    SearchVC *searchVC = (SearchVC *)[storyboard instantiateViewControllerWithIdentifier:@"SearchVC"];
    searchVC.sortModel = sortModel;
    [self.navigationController pushViewController:searchVC animated:YES];
}
////自适应高度
//-(CGFloat)fitToText:(UILabel *)label text:(NSString *)text{
//    label.text = text;
//    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    CGSize size = [label sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
//    return size.height;
//}
-(void)resetButtonState:(RankingCell *)cell model:(SortModel *)model{
    //获取本地存储数据
    self.localZanArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveZanData]];
    self.localComplainArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveComplainData]];
    self.selectedArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveSelectedData]];
    
    if (self.localZanArray.count>0) {
        if ([self.localZanArray containsObject:model.sort_id] ) {
            [cell.zanButton setImage:[UIImage imageNamed:@"sort_zanSelected"] forState:UIControlStateNormal];
            cell.zanLabel.text = [NSString stringWithFormat:@"%ld",(long)[cell.zanLabel.text integerValue]+1];
            cell.zanButton.userInteractionEnabled = NO;
            cell.zanLabel.userInteractionEnabled = NO;
        }
        else {
            [cell.zanButton setImage:[UIImage imageNamed:@"sort_zan"] forState:UIControlStateNormal];
            cell.zanButton.userInteractionEnabled = YES;
            cell.zanLabel.userInteractionEnabled = YES;
        }
    }
    if (self.localComplainArray.count>0) {
        if ([self.localComplainArray containsObject:model.sort_id]) {
            [cell.informButton setImage:[UIImage imageNamed:@"sort_informed"] forState:UIControlStateNormal];
            cell.informLabel.text = @"已投诉";
            cell.informButton.userInteractionEnabled = NO;
            cell.informLabel.userInteractionEnabled = NO;
        }else {
            cell.informLabel.text = @"举报";
            [cell.informButton setImage:[UIImage imageNamed:@"sort_inform"] forState:UIControlStateNormal];
            cell.informButton.userInteractionEnabled = YES;
            cell.informLabel.userInteractionEnabled = YES;
        }
    }
    if (self.selectedArray.count>0) {
        if ([self.selectedArray containsObject:model.sort_id]) {
            cell.titleLabel.textColor = [UIColor grayColor];
        }else {
            cell.titleLabel.textColor = [UIColor blackColor];
        }
    }
}
#pragma mark-------------RankingButtonDelegate 代理方法
//点赞
-(void)touchUpZanButtonWithIndex:(NSInteger)index {
    [self addLoveWithModel:self.sortListArray[index]];
}
//举报
-(void)touchUpInformButtonWithIndex:(NSInteger)index {
    self.currentComplainIndex = index;
    CGFloat sheetWidth = SCREEN_WIDTH*0.9;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inform" bundle:[NSBundle mainBundle]];
    ComplainVC *complainVC = (ComplainVC *)[storyboard instantiateViewControllerWithIdentifier:@"InformVC"];
    complainVC.delegete = self;
    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:complainVC];
    formSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
    
    formSheetController.presentationController.contentViewSize = CGSizeMake(sheetWidth, 260);
    formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyleSlideFromTop;
    formSheetController.presentationController.portraitTopInset = [UIScreen mainScreen].bounds.size.height/2-sheetWidth/2;
    [self presentViewController:formSheetController animated:YES completion:nil];
}
//评论
-(void)touchUpCommentButtonWithIndex:(NSInteger)index {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Comment" bundle:[NSBundle mainBundle]];
    CommentVC *commentVC = [storyboard instantiateViewControllerWithIdentifier:@"commentVC"];
    commentVC.sortModel = self.sortListArray[index];
    [self.navigationController pushViewController:commentVC animated:YES];
}
//举报提交
-(void)commitComplainWithContent:(NSString *)contentStr{
    [self addComplainWithModel:self.sortListArray[self.currentComplainIndex] content:contentStr];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sortType" object:nil];
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
