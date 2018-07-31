#import "AMapController.h"
#import "APIKey.h"

static const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
static const NSInteger RoutePlanningPaddingEdge                    = 20;

@interface AMapController ()<MAMapViewDelegate, AMapLocationManagerDelegate>

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;


/* 路径规划类型 */
//@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapRoute *route;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;

@property (nonatomic, strong) UIBarButtonItem *previousItem;
@property (nonatomic, strong) UIBarButtonItem *nextItem;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@end

static AMapController * SharedInstance;

@implementation AMapController

+ (AMapController *)sharedInstance {
    if (SharedInstance == nil)
        SharedInstance = [[AMapController alloc] init];
    return SharedInstance;
}

- (void)configureAPIKey
{
    if ([APIKey length] == 0)
    {
        NSString *reason = [NSString stringWithFormat:@"apiKey为空，请检查key是否正确设置。"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    [AMapServices sharedServices].apiKey = (NSString *)APIKey;
}

//初始化AMapLocationManager对象，设置代理
- (void)locateInit
{
    [AMapController.sharedInstance configureAPIKey];
    
    //self.locationManager = [[AMapLocationManager alloc] init];
    SharedInstance.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager = SharedInstance.locationManager;
    
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
        
        self.location = location;
        
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
}

//自 V2.2.0 版本起amapLocationManager:didUpdateLocation:reGeocode:方法可以在回调位置的同时回调逆地理编码信息。请注意，如果实现了amapLocationManager:didUpdateLocation:reGeocode: 回调，将不会再回调amapLocationManager:didUpdateLocation: 方法。
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    //NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    self.location = location;
    
    NSString *json = [NSString stringWithFormat:@"{\"lat\":\"%f\",\"lon\":\"%f\",\"alt\":\"%f\",\"accuracy\":\"%f\",\"speed\":\"%f\"}",location.coordinate.latitude,location.coordinate.longitude,location.altitude,location.horizontalAccuracy,location.speed];
    
    NSLog(@"%@", json);
    
    UnitySendMessage("LocationManager", "IOSGPSUpdate", [json UTF8String]);
    
    if (reGeocode)
    {
        //NSLog(@"reGeocode:%@", reGeocode);
    }
}

//结束定位
- (void)locateStop
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - do search
- (void)searchRoutePlanningWalk:(double)lon0 from:(double)lat0 toLon:(double)lon1 toLat:(double)lat1
{
    //self.startCoordinate        = CLLocationCoordinate2DMake(30.910267, 120.370888);
    //self.destinationCoordinate  = CLLocationCoordinate2DMake(30.989872, 120.481956);
    self.startCoordinate        = CLLocationCoordinate2DMake(lat0, lon0);
    self.destinationCoordinate  = CLLocationCoordinate2DMake(lat1, lon1);
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    NSLog(@"步行路径规划");
    
    [self addDefaultAnnotations];
    
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    
    // 出发点.
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    // 目的地.
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapWalkingRouteSearch:navi];
}

- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}

- (void)updateTotal
{
    self.totalCourse = self.route.paths.count;
}

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    
    self.route = response.route;
    [self updateTotal];
    self.currentCourse = 0;
    
    if (response.count > 0)
    {
        AMapPath * path = response.route.paths[0];
        MAPolyline * _polyline = [self polylinesForPath:path];
    }
}

// 路线解析
- (MAPolyline *)polylinesForPath:(AMapPath *)path{
    if (path == nil || path.steps.count == 0){
        return nil;
    }
    NSMutableString *polylineMutableString = [@"" mutableCopy];
    for (AMapStep *step in path.steps) {
        [polylineMutableString appendFormat:@"%@;",step.polyline];
    }
    
    NSUInteger count = 0;
    CLLocationCoordinate2D *coordinates = [self coordinatesForString:polylineMutableString
                                                     coordinateCount:&count
                                                          parseToken:@";"];
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
    
    free(coordinates), coordinates = NULL;
    return polyline;
}

// 解析经纬度
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token{
    if (string == nil){
        return NULL;
    }
    
    if (token == nil){
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","]){
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }else{
        str = [NSString stringWithString:string];
    }
    //NSLog(@"json >>> %@",str);
    
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL){
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    NSMutableArray * array = [[NSMutableArray alloc]initWithArray:@[]];
    for (int i = 0; i < count; i++) {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
        
        NSString *lat = [NSString stringWithFormat:@"%f", coordinates[i].latitude];
        NSString *lon = [NSString stringWithFormat:@"%f", coordinates[i].longitude];
        NSDictionary * dic = @{@"lat":lat, @"lon":lon};
        [array addObject:dic];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    if ([jsonData length] && error== nil) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"jsonString = %@", jsonString);
        UnitySendMessage("LocationManager", "IOSRoute", [jsonString UTF8String]);
    }
    
    return coordinates;
}

UIView * unityView = nil; //内存指针

// 显示地图
- (void)showMapView
{
    // 需要引用GLKit.framework
    
    /*创建地图并添加到父view上*/
    //self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds]; //全屏
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0,0,480,360)]; //指定尺寸
    self.mapView.delegate = self;
    //[self.view addSubview:self.mapView];
    
    unityView = UnityGetGLView();
    [unityView addSubview:self.mapView];
}

// 关闭地图
- (void)hideMapView
{
    [self.mapView removeFromSuperview];
}

@end

#ifdef __cplusplus
extern "C" {
#endif
    
    void ConfigureAPIKey()
    {
        [AMapController.sharedInstance configureAPIKey];
    }
    
    void LocateInit()
    {
        NSLog(@"==>> 初始化定位");
        [AMapController.sharedInstance locateInit];
    }
    
    void LocateOnce()
    {
        NSLog(@"==>> 单次定位");
        [AMapController.sharedInstance locateOnce];
    }
    
    void LocateUpdate()
    {
        NSLog(@"==>> 持续定位");
        [AMapController.sharedInstance locateUpdate];
    }
    
    void LocateStop()
    {
        NSLog(@"==>> 结束定位");
        [AMapController.sharedInstance locateStop];
    }
    
    void WalkRoute(double lon0, double lat0, double lon1, double lat1)
    {
        NSLog(@"==>> 路径规划:(%f,%f)->(%f,%f)", lon0, lat0, lon1, lat1);
        [AMapController.sharedInstance searchRoutePlanningWalk:lon0 from:lat0 toLon:lon1 toLat:lat1];
    }
    
    void ShowMapView()
    {
        NSLog(@"==>> 显示地图");
        [AMapController.sharedInstance showMapView];
    }

    void HideMapView()
    {
        NSLog(@"==>> 关闭地图");
        [AMapController.sharedInstance hideMapView];
    }

#ifdef __cplusplus
}
#endif

