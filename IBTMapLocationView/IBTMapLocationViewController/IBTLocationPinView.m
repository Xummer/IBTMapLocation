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
    self.pingImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_1"]];
    self.leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_2"]];
    self.bottomShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_3"]];
    
    [self addSubview:_bottomShadowView];
    [self addSubview:_leftShadowView];
    [self addSubview:_pingImgView];
}

#pragma mark - Public Method
- (void)upAndDownAnimation {
    // UIViewAnimationOptionCurveEaseIn slow -> fast
    // UIViewAnimationOptionCurveEaseOut fast -> slow
    
    void(^downAnimation)(BOOL) = ^(BOOL finished) {
        [UIView animateWithDuration:.26f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _pingImgView.frame = _bottomShadowView.frame;
                             
                             _leftShadowView.alpha = 1;
                         }
                         completion:NULL];
    };
    
    [UIView animateWithDuration:.26f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect rect = _pingImgView.frame;
                         rect.origin.y -= 15;
                         _pingImgView.frame = rect;
                         
                         _leftShadowView.alpha = 0;
                     }
                     completion:downAnimation];
}

@end
