//
//  MoreNewsCell.m
//  DRBrower
//
//  Created by QiQi on 2017/3/10.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "MoreNewsCell.h"

@implementation MoreNewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)didclickReloadButtonAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(moreCellReloadButton)]){
        [_delegate moreCellReloadButton];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
