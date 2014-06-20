//
//  IBTLocationPinView.m
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import "IBTLocationPinView.h"

@interface IBTLocationPinView ()
@property (strong, nonatomic) UIImageView *pingImgView;
@property (strong, nonatomic) UIImageView *leftShadowView;
@property (strong, nonatomic) UIImageView *bottomShadowView;

@end

@implementation IBTLocationPinView

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = _bottomShadowView.frame;
    rect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)) * .5f;
    _bottomShadowView.frame = rect;
    _leftShadowView.frame = rect;
    _pingImgView.frame = rect;
}

#pragma mark - Private Method
- (void)_init {
    self.pingImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_1_ios7"]];
    self.leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located2"]];
    self.bottomShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located3"]];
    
    [self addSubview:_bottomShadowView];
    [self addSubview:_leftShadowView];
    [self addSubview:_pingImgView];
}

@end
