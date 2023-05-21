//
//  ScheduleCollectionViewLayout.m
//  CyxbsMobile2019_iOS
//
//  Created by SSR on 2022/9/4.
//  Copyright © 2022 Redrock. All rights reserved.
//

#import "ScheduleCollectionViewLayout.h"

#pragma mark - ScheduleCollectionViewLayout ()

@interface ScheduleCollectionViewLayout ()

/// 获取section的值
@property (nonatomic) NSInteger sections;

/// 正常视图布局
@property (nonatomic, strong) NSMutableDictionary <NSIndexPath *, ScheduleCollectionViewLayoutAttributes *> *itemAttributes;

/// 补充视图布局
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableDictionary <NSIndexPath *, UICollectionViewLayoutAttributes *> *> *supplementaryAttributes;

@end

#pragma mark - ScheduleCollectionViewLayout

@implementation ScheduleCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemAttributes = NSMutableDictionary.dictionary;
        _supplementaryAttributes = @{
            UICollectionElementKindSectionHeader : NSMutableDictionary.dictionary,
            UICollectionElementKindSectionLeading : NSMutableDictionary.dictionary,
            UICollectionElementKindSectionPlaceholder : NSMutableDictionary.dictionary,
            UICollectionElementKindSectionHolder : NSMutableDictionary.dictionary
        }.mutableCopy;
    }
    return self;
}

#pragma mark - Ask LayoutAttributes

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *result = NSMutableArray.array;
    for (NSInteger section = 0; section < _sections; section++) {
        
        // SupplementaryView attributes
        for (NSString *elementKind in _supplementaryAttributes.allKeys) {
            id <ScheduleCollectionViewDataSource> dataSource = (id <ScheduleCollectionViewDataSource>)self.collectionView.dataSource;
            NSInteger supplementaryCount = ![dataSource respondsToSelector:@selector(collectionView:numberOfSupplementaryOfKind:inSection:)] ? 0 :
                [dataSource collectionView:self.collectionView numberOfSupplementaryOfKind:elementKind inSection:section];
            for (NSInteger item = 0; item < supplementaryCount; item++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
                if (CGRectIntersectsRect(rect, attributes.frame)) {
                    [result addObject:attributes];
                }
            }
        }
        
        // Cell attributes
        NSUInteger itemCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [result addObject:attributes];
            }
        }
    }
    
    return result;
}

// --------------- Item ---------------

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    
    ScheduleCollectionViewLayoutAttributes *attributes = _itemAttributes[indexPath];
    if (attributes) {
        return attributes;
    }

    attributes = [self.class.layoutAttributesClass layoutAttributesForCellWithIndexPath:indexPath];
    _itemAttributes[indexPath] = attributes;
    
    [self _transformItemWithAttributes:attributes];
    
    return attributes;
}

- (void)_transformItemWithAttributes:(ScheduleCollectionViewLayoutAttributes *)attributes {
    if (attributes.representedElementKind != UICollectionElementCategoryCell) {
        return;
    }
    
    if (self.dataSource) {
        NSIndexPath *locationIndexPath = [self.dataSource collectionView:self.collectionView layout:self locationAtIndexPath:attributes.indexPath];
        NSInteger lenth = [self.dataSource collectionView:self.collectionView layout:self lenthForLocationIndexPath:locationIndexPath];
        attributes.pointIndexPath = locationIndexPath;
        attributes.lenth = lenth;
    }
    
    CGFloat x = attributes.pointIndexPath.section * self.collectionView.frame.size.width + self.widthForLeadingSupplementaryView + (attributes.pointIndexPath.week - 1) * (_itemSize.width + self.columnSpacing);
    CGFloat y = self.heightForHeaderSupplementaryView + (attributes.pointIndexPath.location - 1) * (_itemSize.height + self.lineSpacing) + self.lineSpacing;
    CGFloat height = attributes.lenth * _itemSize.height + (attributes.lenth - 1) * self.columnSpacing;

    CGRect frame = CGRectMake(x, y, _itemSize.width, height);
    
    attributes.frame = frame;
}

// --------------- Supplementary ---------------

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    
    UICollectionViewLayoutAttributes *attributes = _supplementaryAttributes[elementKind][indexPath];

    if (!attributes) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
        _supplementaryAttributes[elementKind][indexPath] = attributes;
    }
    
    [self _transformSupplementaryAttributes:attributes];
    
    return attributes;
}

- (void)_transformSupplementaryAttributes:(UICollectionViewLayoutAttributes *)attributes {
    NSIndexPath *indexPath = attributes.indexPath;
    NSString *elementKind = attributes.representedElementKind;
    
    // Header Element
    if (elementKind == UICollectionElementKindSectionHeader) {
        if (indexPath.item == 0) {
            CGFloat x = indexPath.section * self.collectionView.frame.size.width;
            CGFloat y = self.collectionView.contentOffset.y;
            CGRect frame = CGRectMake(x, y, self.widthForLeadingSupplementaryView, self.heightForHeaderSupplementaryView);
            
            attributes.frame = frame;
            attributes.zIndex = 10;
            
            return;
        }
        CGFloat x = indexPath.section * self.collectionView.frame.size.width + self.widthForLeadingSupplementaryView + (indexPath.item - 1) * (self.columnSpacing + _itemSize.width);
        CGFloat y = self.collectionView.contentOffset.y;
        
        CGRect frame = CGRectMake(x, y, _itemSize.width, self.heightForHeaderSupplementaryView);
        
        attributes.frame = frame;
        attributes.zIndex = 10;
        
        return;
    }
    
    // Leading Element
    if (elementKind == UICollectionElementKindSectionLeading) {
        CGFloat x = indexPath.section * self.collectionView.frame.size.width;
        CGFloat y = self.heightForHeaderSupplementaryView + indexPath.item * (self.lineSpacing + _itemSize.height);
        
        CGRect frame = CGRectMake(x, y, self.widthForLeadingSupplementaryView, _itemSize.height);
        
        attributes.frame = frame;
        
        return;
    }
    
    // Placeholder Element
    if (elementKind == UICollectionElementKindSectionPlaceholder) {
        CGFloat x = indexPath.section * self.collectionView.frame.size.width + self.widthForLeadingSupplementaryView;
        CGFloat y = self.collectionView.contentOffset.y;// + self.heightForHeaderSupplementaryView;
        CGFloat width = self.collectionView.frame.size.width - self.widthForLeadingSupplementaryView;
        CGFloat height = self.collectionView.frame.size.height - self.heightForHeaderSupplementaryView;
        
        CGRect frame = CGRectMake(x, y, width, height);
        
        attributes.frame = frame;
        
        return;
    }
    
    // Holder Element
    if (elementKind == UICollectionElementKindSectionHolder) {
        CGFloat x = indexPath.section * self.collectionView.frame.size.height;
        CGFloat persent = [self.dataSource collectionView:self.collectionView layout:self persentAtSupIndexPath:indexPath];
        CGFloat y = (persent - 1) * (self.itemSize.height + self.lineSpacing) + self.heightForHeaderSupplementaryView;
        
        CGSize size = CGSizeZero;
        if (indexPath.item == 0) {
            CGFloat width = self.widthForLeadingSupplementaryView;
            size = CGSizeMake(width, width / 28 * 6);
        }
        
        CGRect frame = {{x, y - size.height / 2}, size};
        
        attributes.frame = frame;
        attributes.zIndex = 5;
        
        return;
    }
}

#pragma mark - Method

- (NSIndexPath *)indexPathAtPoint:(CGPoint)point {
    NSInteger section = point.x / self.collectionView.frame.size.width;
    NSInteger week = (point.x - section * self.collectionView.frame.size.width - self.widthForLeadingSupplementaryView) / (self.itemSize.width + self.columnSpacing) + 1;
    NSInteger location = (point.y + self.collectionView.contentOffset.y) / (self.itemSize.height + self.lineSpacing);
    
    return [NSIndexPath indexPathForLocation:location inWeek:week inSection:section];
}

#pragma mark - Others

- (void)prepareLayout {
    [self _calculateLayoutIfNeeded];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGSize)collectionViewContentSize {
    
    NSInteger itemCount = 13;
    
    CGSize contentSize = CGSizeMake(_sections * self.collectionView.bounds.size.width, self.heightForHeaderSupplementaryView + itemCount * (_itemSize.height + self.lineSpacing));
    
    return contentSize;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSInteger toTime = self.collectionView.contentOffset.y / (_itemSize.height + self.lineSpacing) + 0.5;
    CGFloat toY = (_itemSize.height + self.lineSpacing) * toTime;
        
    NSInteger index = proposedContentOffset.x / self.collectionView.bounds.size.width + 0.5;
    CGFloat remainder = proposedContentOffset.x - index * self.collectionView.bounds.size.width;
    
    if (velocity.x > 0.6 || (velocity.x > 0.3 && remainder > self.collectionView.bounds.size.width / 3)) { index += 1; }
    if (velocity.x < -0.6 || (velocity.x < -0.3 && remainder < self.collectionView.bounds.size.width / 3 * 2)) { index -= 1; }
    index = MAX(index, self.pageCalculation - 1);
    index = MIN(index, self.pageCalculation + 1);
    
    CGFloat toX = self.collectionView.bounds.size.width * index;
    
    return CGPointMake(toX, toY);
}

#pragma mark - (UISubclassingHooks)

+ (Class)layoutAttributesClass {
    return ScheduleCollectionViewLayoutAttributes.class;
}

+ (Class)invalidationContextClass {
    return ScheduleCollectionViewLayoutInvalidationContext.class;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
    
    ScheduleCollectionViewLayoutInvalidationContext *context =
    (ScheduleCollectionViewLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    
    context.invalidateHeaderSupplementaryAttributes = YES;
    
    return context;
}

- (void)invalidateLayoutWithContext:(ScheduleCollectionViewLayoutInvalidationContext *)context {
    
    // invalidate Holder Supplementary
    [_supplementaryAttributes[UICollectionElementKindSectionHolder] enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * __unused indexPath, UICollectionViewLayoutAttributes * _Nonnull attributes, BOOL * __unused stop) {
        [self _transformSupplementaryAttributes:attributes];
    }];
    
    // invalidate Header Supplementary
    if (context.invalidateHeaderSupplementaryAttributes) {
        
        [_supplementaryAttributes[UICollectionElementKindSectionHeader] enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * __unused indexPath, UICollectionViewLayoutAttributes * _Nonnull attributes, BOOL * __unused stop) {
            [self _transformSupplementaryAttributes:attributes];
        }];
    }
    
    // invalidate Leading Supplementary
    if (context.invalidateLeadingSupplementaryAttributes) {
        
        [_supplementaryAttributes[UICollectionElementKindSectionLeading] enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * __unused indexPath, UICollectionViewLayoutAttributes * _Nonnull attributes, BOOL * __unused stop) {
            [self _transformSupplementaryAttributes:attributes];
        }];
    }
    
    // invalidate All Attributes
    if (context.invalidateDataSourceCounts) {
        for (NSString *key in _supplementaryAttributes) {
            [_supplementaryAttributes[key] removeAllObjects];
        }
        [_itemAttributes removeAllObjects];
    }
    
    [super invalidateLayoutWithContext:context];
}

#pragma mark - Private API

- (void)_calculateLayoutIfNeeded {
    
    NSInteger sections = [self.collectionView.dataSource performSelector:@selector(numberOfSectionsInCollectionView:) withObject:self.collectionView]
    ? [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView]
    : [self.collectionView numberOfSections];
    
    _sections = sections;
    
    CGFloat width = (self.collectionView.bounds.size.width - self.widthForLeadingSupplementaryView) / 7 - self.columnSpacing;
    
    _itemSize = CGSizeMake(width, width / 46 * 50);
}

@end
