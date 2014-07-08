//
//  ViewController.m
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#define IBT_IOS7_OR_LATER            ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)

#import "ViewController.h"
#import "IBTMapLocationViewController.h"

@interface ViewController ()
<
    IBTMapLocationDelegate
>
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IBT_IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = NSLocalizedString(@"Home", nil);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = (CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width = 180,
        .size.height = 44
    };
    
    btn.center = self.view.center;
    
    [btn setTitle:NSLocalizedString(@"Show Location", nil)
         forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [btn setTintColor:[UIColor colorWithRed:7/255.0f green:175/255.0f blue:252/255.0f alpha:255/255.0f]];
    [btn addTarget:self
            action:@selector(showBtnAction:)
  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBtnAction:(id)sender {
    IBTMapLocationViewController *lVC = [[IBTMapLocationViewController alloc] init];
    lVC.delegate = self;
    lVC.title = NSLocalizedString(@"Location", nil);
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:lVC];
    [self presentViewController:navCtrl animated:YES completion:NULL];
}

#pragma mark - IBTMapLocationDelegate
- (void)locationViewCtrlCancleButtonTapped:(IBTMapLocationViewController *)locationVCtrl {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)locationViewCtrl:(IBTMapLocationViewController *)locationVCtrl didSelectLocation:(IBTLocationEntity *)location
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
