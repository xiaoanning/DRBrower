//
//  MoreNewsCell.h
//  DRBrower
//
//  Created by QiQi on 2017/3/10.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreNewsCellDelegate <NSObject>
@optional
- (void)moreCellReloadButton;

@end

@interface MoreNewsCell : UITableViewCell

@property (nonatomic, assign)id<MoreNewsCellDelegate>delegate;


@end
