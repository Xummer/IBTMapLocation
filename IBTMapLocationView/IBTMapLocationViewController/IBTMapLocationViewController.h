//
//  IBTMapLocationViewController.h
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBTLocationEntity.h"

@class IBTMapLocationViewController;
@protocol IBTMapLocationDelegate <NSObject>

@optional
- (void)locationViewCtrlCancleButtonTapped:(IBTMapLocationViewController *)locationVCtrl;
- (void)locationViewCtrl:(IBTMapLocationViewController *)locationVCtrl didSelectLocation:(IBTLocationEntity *)location;

@end

@interface IBTMapLocationViewController : UIViewController

@property (weak, nonatomic) id <IBTMapLocationDelegate> delegate;

@end
