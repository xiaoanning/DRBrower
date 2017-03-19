//
//  ADefectListCollectionViewLayout.m
//  ZongXiong
//
//  Created by leihuai on 16/7/6.
//  Copyright © 2016年 zongxiong. All rights reserved.
//

#import "HomeTopViewLayout.h"

@interface HomeTopViewLayout ()
{
    CGFloat _width ;
}
@end

@implementation HomeTopViewLayout

- (CGSize)collectionViewContentSize
{
    
    
    return CGSizeMake(_width, 0 ) ;
}


- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self getLayoutAttributes] ;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger itemCount = 5 ;
    CGFloat itemWidth = ( SCREEN_WIDTH - 5 - 5 - 10 * (itemCount - 1 ) ) / itemCount ;
    CGFloat itemHeight = itemWidth+5;
    
    attribute.size = CGSizeMake(itemWidth, itemHeight);
    
    long count  = (indexPath.row)/itemCount ;
    
    
    _width =( count/3+1) * SCREEN_WIDTH ;
    
    
    attribute.center = CGPointMake(count/3 * SCREEN_WIDTH + 5+(itemWidth+10)*(indexPath.row%itemCount) + itemWidth/2.0 ,  count%3*itemHeight + itemHeight/2.0 + 10) ;
    
    return attribute ;
}

-(NSArray *)getLayoutAttributes
{
    
    NSMutableArray * arr = [NSMutableArray array];
    
    if (_defectListModel.count)
    {
        [_defectListModel enumerateObjectsUsingBlock:^(NSObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            [arr addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            
        }];
        
        
    }
    
    return arr ;
}

@end
