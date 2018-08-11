#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
//#import "MANaviRoute.h"

@interface AMapController : UIViewController

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *location;

+ (AMapController *) sharedInstance;

- (void)configureAPIKey;
- (void)locateInit;
- (void)locateOnce;
- (void)locateUpdate;
- (void)locateStop;
- (void)showMapView;
- (void)hideMapView;

@end
