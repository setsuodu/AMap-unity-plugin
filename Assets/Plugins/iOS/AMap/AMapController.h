#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface AMapController : UIViewController

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapLocationManager *locationManager;

- (void)locateInit;
- (void)locateOnce;
- (void)locateUpdate;
- (void)locateStop;
- (void)showMapView;
- (void)hideMapView;

@end  
