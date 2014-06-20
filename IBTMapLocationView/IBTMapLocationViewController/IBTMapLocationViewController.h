//
//  IBTMapLocationViewController.h
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBTMapLocationViewController;
@protocol IBTMapLocationDelegate <NSObject>

- (void)locationViewCtrlCancleButtonTapped:(IBTMapLocationViewController *)locationVCtrl;
- (void)locationViewCtrl:(IBTMapLocationViewController *)locationVCtrl didSelectLocation:(id)location;

@end

@interface IBTMapLocationViewController : UIViewController

@property (weak, nonatomic) id <IBTMapLocationDelegate> delegate;

@end
