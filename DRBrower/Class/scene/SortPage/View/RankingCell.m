//
//  RankingCell.m
//  DRBrower
//
//  Created by apple on 2017/2/20.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "RankingCell.h"

@implementation RankingCell {
    NSInteger currentIndex;//当前cell下标
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)rankingCell:(RankingCell *)cell model:(SortModel *)model index:(NSInteger)index{
    currentIndex = index;
    self.titleLabel.text = model.name;
    
    self.adressLabel.text = model.location;
    self.adressLabel.adjustsFontSizeToFitWidth =YES;
    self.timeLabel.text = [Tools getDateString:model.updatetime];
    
    [self.zanButton setImage:[UIImage imageNamed:@"sort_zan"] forState:UIControlStateNormal];
    self.zanButton.userInteractionEnabled = YES;
    self.zanLabel.text = [NSString stringWithFormat:@"%@",model.love_num];
    
    self.zanLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapZanLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZanLabel:)];
    [self.zanLabel addGestureRecognizer:tapZanLabel];
   
    self.informLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapInformLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInformLabel:)];
    [self.informLabel addGestureRecognizer:tapInformLabel];
    
    
    [self.commentCountButton setTitle:[NSString stringWithFormat:@"%@",model.comment_num] forState:UIControlStateNormal];
    self.commentCountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.commentCountButton.titleLabel.textColor = [UIColor whiteColor];
    self.commentCountButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    self.commentCountButton.titleEdgeInsets = UIEdgeInsetsMake(0, -self.commentCountButton.imageView.frame.size.width, 0, 0);
    self.commentCountButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -self.commentCountButton.titleLabel.intrinsicContentSize.width);
    if ([model.comment_num integerValue] == 0) {
        self.commentCountButton.hidden = YES;
    }else {
        self.commentCountButton.hidden = NO;
    }
    
}
-(void)layoutSubviews {
    [super layoutSubviews];
}
#pragma mark --------RankingButtonDelegate
- (IBAction)touchUpZanButton:(id)sender {
    UIButton *button = sender;
    float duration = 0.3f;
    float max = 1.3f;
    [UIView animateWithDuration:duration animations:^{
        button.transform=CGAffineTransformMakeScale(max, max);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            button.transform=CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(touchUpZanButtonWithIndex:)]) {
        [_delegate touchUpZanButtonWithIndex:button.tag];
    }
}
-(void)tapZanLabel:(UITapGestureRecognizer *)tap {
    float duration = 0.3f;
    float max = 1.3f;
    [UIView animateWithDuration:duration animations:^{
        self.zanButton.transform=CGAffineTransformMakeScale(max, max);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.zanButton.transform=CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(touchUpZanButtonWithIndex:)]) {
        [_delegate touchUpZanButtonWithIndex:[tap view].tag-10];
    }
}
-(void)tapInformLabel:(UITapGestureRecognizer *)tap {
    if (_delegate &&[_delegate respondsToSelector:@selector(touchUpInformButtonWithIndex:)]) {
        [_delegate touchUpInformButtonWithIndex:[tap view].tag-1000];
    }
}
- (IBAction)touchUpinformButton:(id)sender {
    UIButton *button = sender;
    if (_delegate &&[_delegate respondsToSelector:@selector(touchUpInformButtonWithIndex:)]) {
        [_delegate touchUpInformButtonWithIndex:button.tag-100];
    }
}
- (IBAction)touchUpCommentButton:(id)sender {
    UIButton *button = sender;
    if (_delegate &&[_delegate respondsToSelector:@selector(touchUpInformButtonWithIndex:)]) {
        [_delegate touchUpCommentButtonWithIndex:button.tag-200];
    }
}
- (IBAction)touchUpCommentCountButton:(id)sender {
    UIButton *button = sender;
    if (_delegate &&[_delegate respondsToSelector:@selector(touchUpCommentButtonWithIndex:)]) {
        [_delegate touchUpCommentButtonWithIndex:button.tag-300];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
