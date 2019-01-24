//
//  ZJFallLayout.h
//  OC_Project
//
//  Created by 小黎 on 2018/12/20.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJFallLayout;

@protocol ZJFallLayoutDelegate <NSObject>

@optional
// 列数
-(NSInteger)collectionView:(UICollectionView *)view layout:(ZJFallLayout *)layout columnCountForSectionAtIndex:(NSInteger)section;
// 行间距
-(CGFloat)collectionView:(UICollectionView *)view layout:(ZJFallLayout *)layout lineSpacingForSectionAtIndex:(NSInteger)section;
// 列间距
-(CGFloat)collectionView:(UICollectionView *)view layout:(ZJFallLayout *)layout columnSpacingForSectionAtIndex:(NSInteger)section;
// item大小
-(CGSize)collectionView:(UICollectionView *)view layout:(ZJFallLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
// 边距
-(UIEdgeInsets)collectionView:(UICollectionView *)view layout:(ZJFallLayout *)layout insetForSectionAtIndex:(NSInteger)section;
@end

@interface ZJFallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<ZJFallLayoutDelegate> delegate;

@end
