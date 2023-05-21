//
//  ScheduleCollectionViewLayout.h
//  CyxbsMobile2019_iOS
//
//  Created by SSR on 2022/9/4.
//  Copyright © 2022 Redrock. All rights reserved.
//

/**ScheduleCollectionViewLayout视图布局
 * 设置所有陈列出来的属性，来达到最佳的视觉效果
 * 请查看飞书云文档，查看ScheduleCollectionViewLayoutAttributes
 */

#import <UIKit/UIKit.h>

#import "ScheduleCollectionViewLayoutSupport.h"
#import "ScheduleCollectionViewDataSource.h"
#import <RyScheduleCourseOC/NSIndexPath+Schedule.h>

NS_ASSUME_NONNULL_BEGIN



#pragma mark - ScheduleCollectionViewLayoutDataSource

@class ScheduleCollectionViewLayout;

@protocol ScheduleCollectionViewLayoutDataSource <NSObject>

@required

/// 返回对应下标的布局点
/// @param collectionView 视图
/// @param layout 布局
/// @param indexPath 下标
- (NSIndexPath *)collectionView:(UICollectionView *)collectionView
                         layout:(ScheduleCollectionViewLayout *)layout
            locationAtIndexPath:(NSIndexPath *)indexPath;

/// 返回对应布局点的长度
/// @param collectionView 视图
/// @param layout 布局
/// @param indexPath 下标
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(ScheduleCollectionViewLayout *)layout
  lenthForLocationIndexPath:(NSIndexPath *)indexPath;



- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ScheduleCollectionViewLayout *)layout
    persentAtSupIndexPath:(NSIndexPath *)indexPath;


@optional


@end

#pragma mark - ScheduleCollectionViewLayout

@interface ScheduleCollectionViewLayout : UICollectionViewLayout

/// 代理
@property (nonatomic, weak) id <ScheduleCollectionViewLayoutDataSource> dataSource;

/// 行间距
@property (nonatomic) CGFloat lineSpacing;

/// 列间距
@property (nonatomic) CGFloat columnSpacing;

/// 前部装饰视图宽
@property (nonatomic) CGFloat widthForLeadingSupplementaryView;

/// 头部装饰视图高
@property (nonatomic) CGFloat heightForHeaderSupplementaryView;

/// 可能在滑动的时候计算的页码
/// 仅仅用于`-targetContentOffsetForProposedContentOffset:withScrollingVelocity:`
@property (nonatomic) NSInteger pageCalculation;

/// 正常视图每一小节课的大小
@property (nonatomic, readonly) CGSize itemSize;

- (NSIndexPath *)indexPathAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
