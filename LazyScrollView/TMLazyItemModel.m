//
//  TMLazyItemModel.m
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#import "TMLazyItemModel.h"

@implementation TMLazyItemModel

- (CGFloat)top
{
    return CGRectGetMinY(_absRect);
}

- (CGFloat)bottom
{
    return CGRectGetMaxY(_absRect);
}

- (CGFloat)left {
    return CGRectGetMinX(_absRect);
}

- (CGFloat)right {
    return CGRectGetMaxX(_absRect);
}

@end
