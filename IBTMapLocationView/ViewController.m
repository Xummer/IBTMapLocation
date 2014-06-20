//
//  ViewController.m
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import "ViewController.h"
#import "IBTMapLocationViewController.h"

@interface ViewController ()

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
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = (CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width = 100,
        .size.height = 44
    };
    
    [btn setTitle:@"Show Location" forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(showBtnAction:)
  forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBtnAction:(id)sender {
    IBTMapLocationViewController *lVC = [[IBTMapLocationViewController alloc] init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:lVC];
    [self presentViewController:navCtrl animated:YES completion:NULL];
}

@end
