//
//  CommentListCell.m
//  DRBrower
//
//  Created by apple on 2017/2/24.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "CommentListCell.h"

@implementation CommentListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)commentListCell:(CommentListCell *)cell model:(CommentModel *)model index:(NSInteger)index {
    UIImage *iconImage;
    if ([model.sex integerValue] == 0) {
        iconImage = [UIImage imageNamed:@"userHead_woman"];
    }else {
        iconImage = [UIImage imageNamed:@"userHead_man"];
    }
    self.iconImageView.image = iconImage;
    self.nameLabel.text = model.address;
    self.timeLabel.text = [Tools getDateString:model.createtime];
    self.contentLabel.text = model.content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
