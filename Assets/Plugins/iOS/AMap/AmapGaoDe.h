#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface AmapGaoDe : UIViewController
@property (nonatomic, strong) AMapLocationManager *locationManager;

- (void)locateInit;
- (void)locateOnce;
- (void)locateUpdate;
- (void)locateStop;
- (void)showMapView;

@end  
