//
//  IBTMapLocationViewController.m
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

@import MapKit;

#import "IBTMapLocationViewController.h"

static NSString *IBTLocationCellID = @"LocationCell";

@interface IBTMapLocationViewController ()
<
    MKMapViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>
{
    BOOL _shouldShowMyLocation;
}
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation IBTMapLocationViewController

#pragma mark - Life Cycle
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
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)setupSubviews {
    _shouldShowMyLocation = YES;
    
    CGRect rect = self.view.bounds;
    rect.size.height = 205;
    
    self.mapView = [[MKMapView alloc] initWithFrame:rect];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    CGFloat btnWidth = 46;
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = (CGRect){
        .origin.x = 10,
        .origin.y = CGRectGetHeight(_mapView.bounds) - 20 - btnWidth,
        .size.width = btnWidth,
        .size.height = btnWidth
    };
    [locationBtn setImage:[UIImage imageNamed:@"location_back_icon"] forState:UIControlStateNormal];
    [locationBtn setImage:[UIImage imageNamed:@"location_blue_icon"] forState:UIControlStateSelected];
    [locationBtn setImage:[UIImage imageNamed:@"location_blue_icon"] forState:UIControlStateSelected];
    [locationBtn addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat dy = CGRectGetMaxY(_mapView.frame);
    rect = (CGRect){
        .origin.x = 0,
        .origin.y = dy,
        .size.width = CGRectGetWidth(self.view.bounds),
        .size.height = CGRectGetHeight(self.view.bounds) - dy
    };
    self.tableView =
    [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.rowHeight = 50;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IBTLocationCellID];
    
    [self.view addSubview:_mapView];
    [self.view addSubview:_tableView];
}

#pragma mark - Actions
- (void)locationButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (_shouldShowMyLocation) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
        CLLocationCoordinate2D location;
        location.latitude = userLocation.coordinate.latitude;
        location.longitude = userLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [mapView setRegion:region animated:YES];
        
        _shouldShowMyLocation = NO;
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IBTLocationCellID forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
