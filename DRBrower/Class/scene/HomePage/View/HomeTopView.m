//
//  HomeTopView.m
//  DRBrower
//
//  Created by QiQi on 2016/12/20.
//  Copyright © 2016年 QiQi. All rights reserved.
//

#import "HomeTopView.h"
#include "CSStickyHeaderFlowLayout.h"
#import "WebsiteCell.h"
#import "WebsiteModel.h"
#import "HomeTopViewLayout.h"
#import "WeatherModel.h"

static NSString *const websiteCellIdentifier = @"WebsiteCell";
@interface HomeTopView()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>{
    
}
@end
@implementation HomeTopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)weatherHeader:(HomeTopView *)header model:(WeatherModel *)model {
    self.weatherLabel.text = model.weather;
    self.temperatureLabel.text = model.temperature;
    self.pmLabel.text = model.pm25;
    self.placeLabel.text = model.currentCity;
    self.airQualityLabel.text = model.airQuality;
    self.pmLabel.backgroundColor = colorWithvalue(model.colorValue);
    self.weatherImage.image = [UIImage imageNamed:model.weatherImage];
    
    if (model.pm25 == nil) {
        self.airQualityLabel.text = @"";
    }
}

- (void)hotwordHeader:(HomeTopView *)header hotWordArray:(NSArray *)array {
    for (int i = 0; i<5; i++) {
        [self.hotWordButton[i] setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)websiteHeader:(HomeTopView *)header websiteArray:(NSArray *)array {
    self.websiteCollectionView.dataSource = self;
    self.websiteCollectionView.delegate = self;
    self.websiteArray = array;
    [self.websiteCollectionView registerNib:[UINib nibWithNibName:@"WebsiteCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:websiteCellIdentifier];
    [(HomeTopViewLayout *)self.websiteCollectionView.collectionViewLayout setDefectListModel:self.websiteArray] ;
    [self reloadPageControl];
    [self reloadCollectViewHeight];
    [self.websiteCollectionView reloadData];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.websiteCollectionView.dataSource = self;
    self.websiteCollectionView.delegate = self;
    
    [self.websiteCollectionView registerNib:[UINib nibWithNibName:@"WebsiteCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:websiteCellIdentifier];
    [self data];
    [self reloadPageControl];
    [self reloadCollectViewHeight];
}

- (void)data {
    self.websiteArray = [DRLocaldData achieveWebsiteData];
    
    [self reloadPageControl];
    
}

- (void)reloadPageControl {
    
    NSInteger pageCount = [Tools pageCount:self.websiteArray];
    
    if ([self.websiteArray count] <= 15 || pageCount == 0) {
        self.websitePageControlHeight.constant = 0;
        self.websitePageControl.hidden = YES;
    }else {
        self.websitePageControl.numberOfPages = pageCount;
        self.websitePageControlHeight.constant = 35;
        self.websitePageControl.hidden = NO;
    }
}

- (void)reloadCollectViewHeight {
    NSInteger itemHeight = (SCREEN_WIDTH - 5 - 5 - 10 * (5 - 1 ) ) / 5;
    NSInteger collectionViewHeight = itemHeight*2+10;

    if ([self.websiteArray count] > 10) {
        self.websiteCollectionViewHeight.constant = collectionViewHeight+itemHeight+15;
    }else {
        self.websiteCollectionViewHeight.constant = collectionViewHeight+10;
    }
}

#pragma mark UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        return self.websiteArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WebsiteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:websiteCellIdentifier forIndexPath:indexPath];
    WebsiteModel *website = self.websiteArray[indexPath.row];
    cell.model = website;
    cell.delegate = self;
    [cell websiteCell:cell model:website];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    WebsiteModel *website = self.websiteArray[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(websiteViewSelectWithWebsite:)]) {
        [_delegate websiteViewSelectWithWebsite:website];
    }
}

#pragma  mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH)/4.0, self.websiteCollectionViewHeight.constant/3);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    self.websitePageControl.currentPage=(NSInteger)(offsetX/SCREEN_WIDTH);
}

- (IBAction)didclickSearchButtonAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(touchUpSearchButtonAction)]){
        [_delegate touchUpSearchButtonAction];
    }
}

- (IBAction)didClickQRcodeButtonAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(touchUpQRcodeButtonAction)]){
        [_delegate touchUpQRcodeButtonAction];
    }
}

- (void)longPressGesture:(WebsiteModel *)model {

    if(_delegate && [_delegate respondsToSelector:@selector(homeTopViewPresentView:)]){
        [_delegate homeTopViewPresentView:model];
    }

}

- (IBAction)didClickHotWordButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if(_delegate && [_delegate respondsToSelector:@selector(touchUpHotWordButtonAction:)]){
        [_delegate touchUpHotWordButtonAction:button.tag];
    }
}



@end
