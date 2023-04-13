//
//  TMLazyModelBucket.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "TMLazyModelBucket.h"

@interface TMLazyModelBucket () {
    NSMutableArray<NSMutableSet *> *_verticalBuckets;
    NSMutableArray<NSMutableSet *> *_horizontalBuckets;
}

@end

@implementation TMLazyModelBucket

@synthesize bucketHeight = _bucketHeight;

- (instancetype)initWithBucketHeight:(CGFloat)bucketHeight
{
    if (self = [super init]) {
        _bucketHeight = bucketHeight;
        _verticalBuckets = [NSMutableArray array];
        _horizontalBuckets = [NSMutableArray array];
    }
    return self;
}

- (void)addModel:(TMLazyItemModel *)itemModel
{
    if (!itemModel) return;
    
    if (itemModel.bottom > itemModel.top) {
        NSInteger startIndex = (NSInteger)floor(itemModel.top / _bucketHeight);
        NSInteger endIndex = (NSInteger)floor((itemModel.bottom - 0.01) / _bucketHeight);
        for (NSInteger index = 0; index <= endIndex; index++) {
            if (_verticalBuckets.count <= index) {
                [_verticalBuckets addObject:[NSMutableSet set]];
            }
            if (index >= startIndex && index <= endIndex) {
                NSMutableSet *bucket = [_verticalBuckets objectAtIndex:index];
                [bucket addObject:itemModel];
            }
        }
    }
    
    if (itemModel.right > itemModel.left) {
        NSInteger startIndex = (NSInteger)floor(itemModel.left / _bucketHeight);
        NSInteger endIndex = (NSInteger)floor((itemModel.right - 0.01) / _bucketHeight);
        for (NSInteger index = 0; index <= endIndex; index++) {
            if (_horizontalBuckets.count <= index) {
                [_horizontalBuckets addObject:[NSMutableSet set]];
            }
            if (index >= startIndex && index <= endIndex) {
                NSMutableSet *bucket = [_horizontalBuckets objectAtIndex:index];
                [bucket addObject:itemModel];
            }
        }
    }
    
}

- (void)addModels:(NSSet<TMLazyItemModel *> *)itemModels
{
    if (itemModels) {
        for (TMLazyItemModel *itemModel in itemModels) {
            [self addModel:itemModel];
        }
    }
}

- (void)removeModel:(TMLazyItemModel *)itemModel
{
    if (itemModel) {
        for (NSMutableSet *bucket in _verticalBuckets) {
            [bucket removeObject:itemModel];
        }
    }
}

- (void)removeModels:(NSSet<TMLazyItemModel *> *)itemModels
{
    if (itemModels) {
        for (NSMutableSet *bucket in _verticalBuckets) {
            [bucket minusSet:itemModels];
        }
    }
}

- (void)reloadModel:(TMLazyItemModel *)itemModel
{
    [self removeModel:itemModel];
    [self addModel:itemModel];
}

- (void)reloadModels:(NSSet<TMLazyItemModel *> *)itemModels
{
    [self removeModels:itemModels];
    [self addModels:itemModels];
}

- (void)clear
{
    [_verticalBuckets removeAllObjects];
}

- (NSSet<TMLazyItemModel *> *)showingModelsFrom:(CGFloat)startY to:(CGFloat)endY
{
    NSMutableSet *result = [NSMutableSet set];
    NSInteger startIndex = (NSInteger)floor(startY / _bucketHeight);
    NSInteger endIndex = (NSInteger)floor((endY - 0.01) / _bucketHeight);
    for (NSInteger index = 0; index <= endIndex; index++) {
        if (_verticalBuckets.count > index && index >= startIndex && index <= endIndex) {
            NSSet *bucket = [_verticalBuckets objectAtIndex:index];
            [result unionSet:bucket];
        }
    }
    NSMutableSet *needToBeRemoved = [NSMutableSet set];
    for (TMLazyItemModel *itemModel in result) {
        if (itemModel.top >= endY || itemModel.bottom <= startY) {
            [needToBeRemoved addObject:itemModel];
        }
    }
    [result minusSet:needToBeRemoved];
    return [result copy];
}

- (NSSet<TMLazyItemModel *> *)visibleModelsFrom:(CGPoint)startPoint to:(CGPoint)endPoint {
    NSMutableSet<TMLazyItemModel *> *result = [NSMutableSet set];
    NSMutableSet<TMLazyItemModel *> *verticalResult = [NSMutableSet set];
    NSMutableSet<TMLazyItemModel *> *horizontalResult = [NSMutableSet set];
    NSMutableSet<TMLazyItemModel *> *needToBeRemoved = [NSMutableSet set];
    
    /// **Vertical Begin**
    NSInteger startIndex = (NSInteger)floor(startPoint.y / _bucketHeight);
    NSInteger endIndex = (NSInteger)floor((endPoint.y - 0.01) / _bucketHeight);
    for (NSInteger index = 0; index <= endIndex; index++) {
        if (_verticalBuckets.count > index && index >= startIndex && index <= endIndex) {
            NSSet *bucket = [_verticalBuckets objectAtIndex:index];
            [verticalResult unionSet:bucket];
        }
    }
    /// **Vertical End**
    
    /// **Horizontal Begin**
    startIndex = (NSInteger)floor(startPoint.x / _bucketHeight);
    endIndex = (NSInteger)floor((endPoint.x - 0.01) / _bucketHeight);
    for (NSInteger index = 0; index <= endIndex; index++) {
        if (_horizontalBuckets.count > index && index >= startIndex && index <= endIndex) {
            NSSet *bucket = [_horizontalBuckets objectAtIndex:index];
            [horizontalResult unionSet:bucket];
        }
    }
    /// **Horizontal End**
    
    [result unionSet:horizontalResult];
    [result unionSet:verticalResult];
    
    for (TMLazyItemModel *itemModel in result) {
        if (itemModel.left >= endPoint.x || itemModel.right <= startPoint.x || itemModel.top >= endPoint.y || itemModel.bottom <= startPoint.y) {
            [needToBeRemoved addObject:itemModel];
        }
    }
    
    [result minusSet:needToBeRemoved];
    
    return [result copy];
}

@end
