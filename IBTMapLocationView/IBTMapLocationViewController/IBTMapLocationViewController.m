//
//  IBTMapLocationViewController.m
//  IBTMapLocationView
//
//  Created by Xummer on 14-6-20.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#define IBT_IOS7_OR_LATER           ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
#define FOURSQUARE_CLIENT_ID        @"YG32GB4BSOPK0MRN0EA01VGKZPPDN2TXUVEG4Y4SSNSLDMWY"
#define FOURSQUARE_CLIENT_SECRET    @"T2OL3GFMT1XH3CMNW2KWCUQBUJZXMLL40ZOIKS2OPXPPEBGD"

@import MapKit;

#import "IBTMapLocationViewController.h"
#import "IBTLocationPinView.h"
#import "AFNetworking.h"

static NSString *IBTLocationCellID = @"LocationCell";

// ====== IBTLocationOptionsCell ======
@interface IBTLocationOptionsCell : UITableViewCell

@end

@implementation IBTLocationOptionsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.backgroundColor = highlighted ? [UIColor colorWithWhite:217/255.0f alpha:1] : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end

// ====== IBTMapLocationViewController ======

@interface IBTMapLocationViewController ()
<
    MKMapViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>
{
    BOOL _shouldShowMyLocation;
    BOOL _selectedOtherLocation;
}
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) IBTLocationPinView *locationPin;

@property (strong, nonatomic) NSArray *venues;

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
    
    if (IBT_IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initialData];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_selectedOtherLocation) {
        [self selectCurrentLocation];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat dy = CGRectGetMaxY(_mapView.frame);
    _tableView.frame = (CGRect){
        .origin.x = 0,
        .origin.y = dy,
        .size.width = CGRectGetWidth(self.view.bounds),
        .size.height = CGRectGetHeight(self.view.bounds) - dy
    };
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)initialData {
    _selectedOtherLocation = NO;
}

- (void)setupSubviews {
    
    BOOL isModal = ([self.navigationController.viewControllers count] == 1) && [self isModal];
    if (isModal) {
        UIBarButtonItem *leftBtnItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(leftCancelButtonAction:)];
        self.navigationItem.leftBarButtonItem = leftBtnItem;
    }
    
    UIBarButtonItem *rightBtnItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(sendButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
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
    [locationBtn setImage:[UIImage imageNamed:@"location_blue_icon"] forState:UIControlStateHighlighted];
    [locationBtn addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.locationButton = locationBtn;
    
    self.locationPin = [[IBTLocationPinView alloc] init];
    _locationPin.frame = (CGRect){
        .origin.x = (CGRectGetWidth(_mapView.bounds) - IBT_LOCATION_PIN_DEFAULT_WIDTH) * .5f,
        .origin.y = CGRectGetHeight(_mapView.bounds) * .5f - IBT_LOCATION_PIN_DEFAULT_HEIGHT + CGRectGetMinY(_mapView.frame),
        .size.width = IBT_LOCATION_PIN_DEFAULT_WIDTH,
        .size.height = IBT_LOCATION_PIN_DEFAULT_HEIGHT
    };
    
    CGFloat dy = CGRectGetMaxY(_mapView.frame);
    rect = (CGRect){
        .origin.x = 0,
        .origin.y = dy,
        .size.width = CGRectGetWidth(self.view.bounds),
        .size.height = CGRectGetHeight(self.view.bounds) - dy
    };
    self.tableView =
    [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.rowHeight = 50;
    [_tableView registerClass:[IBTLocationOptionsCell class]
       forCellReuseIdentifier:IBTLocationCellID];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_mapView];
    [self.view addSubview:_tableView];
    [self.view addSubview:_locationButton];
    [self.view addSubview:_locationPin];
}

- (void)selectCurrentLocation {
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView selectRowAtIndexPath:indexP
                            animated:YES
                      scrollPosition:UITableViewScrollPositionNone];
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

#pragma mark - Actions
- (void)leftCancelButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(locationViewCtrlCancleButtonTapped:)]) {
        [self.delegate locationViewCtrlCancleButtonTapped:self];
    }
}

- (void)sendButtonAction:(id)sender {
    
    IBTLocationEntity *locationE = [[IBTLocationEntity alloc] init];
    if (_selectedOtherLocation) {
        
        NSIndexPath *selectedIndexP = [self.tableView indexPathForSelectedRow];
        
        NSDictionary *venueDict = _venues[ selectedIndexP.row ];
        NSDictionary *locationDict = venueDict[ @"location" ];
        locationE.name = venueDict[ @"name" ];
        locationE.latitude = @([locationDict[ @"lat" ] doubleValue]);
        locationE.longitude = @([locationDict[ @"lng" ] doubleValue]);
    }
    else {
        locationE.name = @"";
        locationE.latitude = @(_mapView.centerCoordinate.latitude);
        locationE.longitude = @(_mapView.centerCoordinate.longitude);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationViewCtrl:didSelectLocation:)]) {
        [self.delegate locationViewCtrl:self didSelectLocation:locationE];
    }
}

- (void)locationButtonAction:(UIButton *)sender {
    _shouldShowMyLocation = YES;
    _locationButton.selected = YES;
    [_mapView showsUserLocation];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self getVenuesWith:mapView.centerCoordinate];
    [_locationPin upAndDownAnimation];
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
        _locationButton.selected = NO;
        
        _selectedOtherLocation = NO;
        
        [_tableView reloadData];
        
        [self selectCurrentLocation];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:error.localizedDescription delegate:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _selectedOtherLocation ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    
    if (_selectedOtherLocation) {
        row = [_venues count];
    }
    else {
        switch (section) {
            case 0:
                row = 1;
                break;
            case 1:
                row = [_venues count];
                break;
            default:
                break;
        }
    }
    
    return row;
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
    if (_selectedOtherLocation) {
        [self configureVenuewCell:cell forRowAtIndexPath:indexPath];
    }
    else {
        switch (indexPath.section) {
            case 0:
            {
                cell.textLabel.text = NSLocalizedString(@"[Current Location]", nil);
                cell.detailTextLabel.text = nil;
            }
                break;
            case 1:
            {
                [self configureVenuewCell:cell forRowAtIndexPath:indexPath];
            }
                break;
            default:
                break;
        }
    }
}

- (void)configureVenuewCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *venueDict = _venues[ indexPath.row ];
    cell.textLabel.text = venueDict[ @"name" ];
    
    NSDictionary *locationDict = venueDict[ @"location" ];
    //            NSArray *formattedAddress = locationDict[ @"formattedAddress" ];
    //            formattedAddress = [[formattedAddress reverseObjectEnumerator] allObjects];
    
    cell.detailTextLabel.text = locationDict[ @"address" ];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_selectedOtherLocation &&
        !(indexPath.section == 0 &&
        indexPath.row == 0) )
    {
        _selectedOtherLocation = YES;
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:0]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *newIndexP = [NSIndexPath indexPathForRow:indexPath.row
                                                    inSection:0];
        [tableView selectRowAtIndexPath:newIndexP
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - HTTP
- (void)getVenuesWith:(CLLocationCoordinate2D)coordinate {
    __weak typeof(self)weakSelf = self;
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
        
        NSIndexPath *selectedIndexP = [weakSelf.tableView indexPathForSelectedRow];
        
        weakSelf.venues = responseObject[ @"response" ][ @"venues" ];
        NSIndexSet *sections =
        [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [weakSelf numberOfSectionsInTableView:weakSelf.tableView])];
        [weakSelf.tableView reloadSections:sections
                 withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:0];
        [weakSelf.tableView scrollToRowAtIndexPath:indexP
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        
        if (!_selectedOtherLocation &&
            selectedIndexP.section == 0 &&
            selectedIndexP.row == 0)
        {
            [weakSelf selectCurrentLocation];
        }
    };
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error:%@", error);
    };
    
    /*
     https://api.foursquare.com/v2/venues/search?ll=31.210857,121.628456&client_id=YG32GB4BSOPK0MRN0EA01VGKZPPDN2TXUVEG4Y4SSNSLDMWY&client_secret=T2OL3GFMT1XH3CMNW2KWCUQBUJZXMLL40ZOIKS2OPXPPEBGD&v=20140707
     */
    
    NSString *urlStr = @"https://api.foursquare.com/v2/venues/search";
    NSDictionary *parameters =
    @{ @"ll" : [NSString stringWithFormat:@"%lf,%lf", coordinate.latitude, coordinate.longitude],
       @"client_id" : FOURSQUARE_CLIENT_ID,
       @"client_secret" : FOURSQUARE_CLIENT_SECRET,
       @"v" : @"20380101"
       };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:success failure:failure];
}


@end
