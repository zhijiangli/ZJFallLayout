//
//  ZJFallLayout.m
//  OC_Project
//
//  Created by 小黎 on 2018/12/20.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import "ZJFallLayout.h"

@interface ZJFallLayout()

///< 所有的cell的布局
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> * attrsArray;
///<  key列 value maxY值
@property (nonatomic, strong) NSMutableDictionary * columnMaxY;

@end

static const CGFloat ZJDefaultColumnCount  = 3;                         ///< 默认列数
static const CGFloat ZJDefaultColumnMargin = 10;                        ///< 默认列边距
static const CGFloat ZJDefaultlineMargin   = 10;                        ///< 默认行边距
static const UIEdgeInsets ZJDefaultInsets  = {10, 10, 10, 10};          ///< 默认collectionView边距

@implementation ZJFallLayout


- (void)prepareLayout
{
    // 重写必须调用super方法
    [super prepareLayout];

    NSInteger columnCount   = [self columnCountWithIndexPath:0];
    UIEdgeInsets edgeInsets = [self edgeInsetsWithIndexPath:0];
    for(int i=0;i<columnCount;i++){
        NSString * columKey = [NSString stringWithFormat:@"%d",i];
        [[self columnMaxY] setValue:@(edgeInsets.top) forKey:columKey];
    }

    // 遍历所有的cell，计算所有cell的布局
    [[self attrsArray] removeAllObjects];
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 计算布局属性并将结果添加到布局属性数组中
        @autoreleasepool{
            [self.attrsArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    //NSLog(@" > > > > > > > ");
}
// 返回布局属性，一个UICollectionViewLayoutAttributes对象数组
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrsArray;
}
//设置collectionView滚动区域
-(CGSize)collectionViewContentSize
{
    //假设最长的那一列为第0列
    __block NSString *maxColumn = @"0";
    
    //遍历字典,找出最长的那一列
    [self.columnMaxY enumerateKeysAndObjectsUsingBlock:^(NSString *column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue] > [self.columnMaxY[maxColumn] floatValue])
        {
            maxColumn = column;
        }
    }];
    return CGSizeMake(0, [self.columnMaxY[maxColumn]floatValue]);
}
//允许每一次重新布局
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewLayoutAttributes * attLayout = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    // 取出Y值最小的列
    NSString * minYColumKey = @"0";
    for(NSString * columKey in [[self columnMaxY] allKeys]){
        CGFloat maxY = [[[self columnMaxY] objectForKey:columKey] doubleValue];
        if([[[self columnMaxY] objectForKey:minYColumKey] doubleValue] > maxY){
            minYColumKey = columKey;
        }
    }
    CGSize itemSize = [self itemSizeWithIndexPath:indexPath];
    UIEdgeInsets edgeInsets = [self edgeInsetsWithIndexPath:indexPath];
    CGFloat columnSpacing   = [self columnSpacingWithIndexPath:indexPath];
    CGFloat lineSpacing     = [self lineSpacingWithIndexPath:indexPath];
    
    CGFloat x = edgeInsets.left+(itemSize.width+columnSpacing)*[minYColumKey intValue];
    CGFloat y = [[[self columnMaxY] objectForKey:minYColumKey] doubleValue];
    [[self columnMaxY] setValue:@(y+lineSpacing+itemSize.height) forKey:minYColumKey];
    CGRect newFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
    [attLayout setFrame:newFrame];
    return attLayout;
}
-(NSMutableArray<UICollectionViewLayoutAttributes *> *)attrsArray{
    if(!_attrsArray){
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}
- (NSMutableDictionary *)columnMaxY{
    if(!_columnMaxY){
        _columnMaxY = [NSMutableDictionary dictionary];
    }
    return _columnMaxY;
}
- (CGFloat)columnCountWithIndexPath:(NSIndexPath*)indexPath
{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(collectionView:layout:columnCountForSectionAtIndex:)]){
        return [[self delegate] collectionView:[self collectionView] layout:self columnCountForSectionAtIndex:indexPath.section];
    }else{
        
        return ZJDefaultColumnCount;
    }
}
- (CGFloat)lineSpacingWithIndexPath:(NSIndexPath*)indexPath
{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)]){
        return [[self delegate] collectionView:[self collectionView] layout:self lineSpacingForSectionAtIndex:indexPath.section];
    }else{
        return ZJDefaultlineMargin;
    }
}

- (CGFloat)columnSpacingWithIndexPath:(NSIndexPath*)indexPath
{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(collectionView:layout:columnSpacingForSectionAtIndex:)])
    {
        return [[self delegate] collectionView:[self collectionView] layout:self columnSpacingForSectionAtIndex:indexPath.section];
    }else{
        
        return ZJDefaultColumnMargin;
    }
}
- (UIEdgeInsets)edgeInsetsWithIndexPath:(NSIndexPath*)indexPath
{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
        return [[self delegate] collectionView:[self collectionView] layout:self insetForSectionAtIndex:indexPath.section];
    }else{
        
        return ZJDefaultInsets;
    }
}
-(CGSize)itemSizeWithIndexPath:(NSIndexPath*)indexPath{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]){
        return [[self delegate] collectionView:[self collectionView] layout:self sizeForItemAtIndexPath:indexPath];
    }else{
        CGFloat width = CGRectGetWidth([[self collectionView] frame]);
        
        UIEdgeInsets edgeInsets = [self edgeInsetsWithIndexPath:indexPath];
        CGFloat columnSpacing   = [self columnSpacingWithIndexPath:indexPath];
        NSInteger columnCount   = [self columnCountWithIndexPath:indexPath];
        CGFloat cellW = (width - edgeInsets.left - edgeInsets.right -
                         columnSpacing * (columnCount - 1)) / columnCount;
        return CGSizeMake(cellW, cellW);
    }
}
@end
