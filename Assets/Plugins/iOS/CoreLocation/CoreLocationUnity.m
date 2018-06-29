#import "CoreLocationUnity.h"

//1.引入头文件
#import <CoreLocation/CoreLocation.h>

//2.引入CoreLocation
@interface CoreLocationUnity : NSObject<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocation *myOldLocation;
@end

@implementation CoreLocationUnity

- (void)viewDidLoad {
    NSLog(@"==>> viewDidLoad");
}

- (void)StartGPS{
    
    // 初始化对象
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1.0; //kCLDistanceFilterNone定时更新  1:每隔一米更新一次
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //定位精度
    self.locationManager.pausesLocationUpdatesAutomatically=NO; //设置是否允许系统自动暂停定位，这里要设置为NO，刚开始我没有设置，后台定位持续20分钟左右就停止了！
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization]; //永久授权
        [self.locationManager requestWhenInUseAuthorization]; //使用中授权
        //[self.locationManager startMonitoringSignificantLocationChanges]; //
    }
    
    if(![CLLocationManager locationServicesEnabled]){
        NSLog(@"请开启定位:设置 >隐私 > 位置 >定位服务");
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=8) {
        //[_locationManager requestWhenInUseAuthorization];//⓵只在前台开启定位
        [self.locationManager requestAlwaysAuthorization];//⓶在后台也可定位
    }
    
    // 5.iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=9) {
        self.locationManager.allowsBackgroundLocationUpdates =YES;
    }
    
    [self.locationManager startUpdatingLocation];
    NSLog(@"start gps update");
}

- (void)StopGPS{
    [self.locationManager stopUpdatingLocation];
    NSLog(@"stop gps update");
}

// 实现定位代理更新位置成功回调
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    self.myOldLocation = currentLocation;
    NSString *strResult = @"didUpdateToLoation";
    
    if (currentLocation != nil) {
        NSString *lat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        NSString *lon=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];
        NSString *ele=[NSString stringWithFormat:@"%0.8f",currentLocation.altitude];
        strResult=[NSString stringWithFormat:@"{\"state\":\"UpdateGPS\",\"latitude\":\"%@\",\"longitude\":\"%@\",\"altitude\":\"%@\" }",lat,lon,ele];
        UnitySendMessage("LocationManager", "IOSGPSUpdate", [strResult UTF8String]);
    }
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address:%@",strResult);
}


@end

#ifdef __cplusplus
extern "C" {
#endif
    
    CoreLocationUnity * _instance;
    
    void StartGPSUpdate()
    {
        NSLog(@"==>> 开始定位");
        if(_instance == nil){
            _instance = [[CoreLocationUnity alloc] init];
        }
        [_instance StartGPS];
    }

    void StopGPSUpdate()
    {
        NSLog(@"==>> 结束定位");
        if(_instance != nil){
            [_instance StopGPS];
        }
    }

#ifdef __cplusplus
}
#endif
