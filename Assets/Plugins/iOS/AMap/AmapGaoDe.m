#import "AmapGaoDe.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
//#import <MAMapKit/MAMapKit.h>

//@interface AmapGaoDe () <AMapLocationManagerDelegate, MAMapViewDelegate>
@interface AmapGaoDe () <AMapLocationManagerDelegate>
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
//@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation AmapGaoDe

//初始化AMapLocationManager对象，设置代理
- (void)locateInit
{
    [AMapServices sharedServices].apiKey = @"5731c751865c618db2afb227d4e2eec5";
    
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    // 设置单次定位
    // 带逆地理信息的一次定位（返回坐标和地址信息  高精度）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // 定位超时时间，最低2s，此处设置为10s
    [self.locationManager setLocationTimeout:10];
    
    // 逆地理请求超时时间，最低2s，此处设置为10s
    [self.locationManager setReGeocodeTimeout:10];
    
    // 设置持续定位
    [self.locationManager setDistanceFilter:1];
}

//单次定位回调
- (void)locateOnce
{
    //带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            NSString *err=@"1|1";
            
            UnitySendMessage("LocationManager", "IOSGPSUpdate",[err UTF8String]);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        //经纬度信息
        NSString *lat;
        lat = [NSString stringWithFormat:@"%f|%f",location.coordinate.longitude,location.coordinate.latitude];
        
        UnitySendMessage("LocationManager", "IOSGPSUpdate",[lat UTF8String]);
        
        //逆地理信息
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
    }];
}

//开启持续定位
- (void)locateUpdate
{
    [self.locationManager startUpdatingLocation];
    
    //如果需要持续定位返回逆地理编码信息，（自 V2.2.0版本起支持）需要做如下设置：
    [self.locationManager setLocatingWithReGeocode:YES];
}

//接收位置更新
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    //NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    //TODO: 合成Json输出
    //location.altitude;
    //location.speed;
    //location.description;
    
    //NSString *json = [NSString stringWithFormat:@"{\"lat\":\"%f\",\"lon\":\"%f\",\"alt\":\"%f\",\"accuracy\":\"%f\",\"speed\":\"%f\"}",location.coordinate.latitude,location.coordinate.longitude,location.altitude,location.horizontalAccuracy,location.speed];
    
    //NSLog(@"%@", json);
    
    //UnitySendMessage("LocationManager", "IOSGPSUpdate", [json UTF8String]);
}

//自 V2.2.0 版本起amapLocationManager:didUpdateLocation:reGeocode:方法可以在回调位置的同时回调逆地理编码信息。请注意，如果实现了amapLocationManager:didUpdateLocation:reGeocode: 回调，将不会再回调amapLocationManager:didUpdateLocation: 方法。
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    //NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    NSString *json = [NSString stringWithFormat:@"{\"lat\":\"%f\",\"lon\":\"%f\",\"alt\":\"%f\",\"accuracy\":\"%f\",\"speed\":\"%f\"}",location.coordinate.latitude,location.coordinate.longitude,location.altitude,location.horizontalAccuracy,location.speed];
    
    
    NSLog(@"%@", json);
    
    UnitySendMessage("LocationManager", "IOSGPSUpdate", [json UTF8String]);
    
    if (reGeocode)
    {
        //NSLog(@"reGeocode:%@", reGeocode);
        
        //reGeocode.formattedAddress;
        //reGeocode.country;
        //reGeocode.province;
        //reGeocode.city;
        //reGeocode.district;
        //reGeocode.street;
        //reGeocode.number;
        //reGeocode.citycode;
        //reGeocode.adcode;
        //reGeocode.description;
        //reGeocode.POIName;
        //reGeocode.AOIName;
    }
}

//结束定位
- (void)locateStop
{
    [self.locationManager stopUpdatingLocation];
}

- (void)showMapView{
    /*创建地图并添加到父view上*/
    //self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    //self.mapView.delegate = self;
    //[self.view addSubview:self.mapView];
    
    //UIView* unityView = UnityGetGLView();
    //[unityView addSubview:self.mapView];
}

@end
