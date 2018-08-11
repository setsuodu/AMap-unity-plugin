#import "POIController.h"
#import "POIAnnotation.h"
#import "AMapController.h"

@interface POIController ()<AMapSearchDelegate>

@property (nonatomic, strong) NSArray *forecastArray;

@end

@implementation POIController

/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword
{
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    
    request.keywords            = @"世纪联华";
    request.city                = @"杭州";
    request.types               = @"超市";
    request.requireExtension    = YES;
    
    /*  搜索服务 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit           = YES;
    request.requireSubPOIs      = YES;
    
    [self.search AMapPOIKeywordsSearch:request];
}

/* 检索周边POI. */
- (void)searchPoiByAround:(NSString *)keyword
{
    NSLog(@"当前位置 ==>> (%f,%f)", AMapController.sharedInstance.location.coordinate.longitude, AMapController.sharedInstance.location.coordinate.latitude);
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:30.316176 longitude:120.170779];
    //request.keywords            = @"电影院";
    request.keywords            = keyword;
    
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    //NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
    NSLog(@"Error:%@", error);
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    //NSLog(@"%zd",poiAnnotations.count); //20
    for(int i=0; i<response.pois.count; i++)
    {
        NSLog(@"%d ==>> %@, %@", i, response.pois[i].name, response.pois[i].address);
    }

    /* 将结果以annotation的形式加载到地图上. */
    //[self.mapView addAnnotations:poiAnnotations];
}

- (void)onQueryWeather
{
    if(self.search == nil){
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }

    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = @"110000"; //城市代码
    request.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气

    [self.search AMapWeatherSearch:request];
}

// 天气查询回调
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //解析response获取天气信息，具体解析见 Demo
    
    //NSLog(@"天气查询回调");
    
    if (response.lives.count == 0)
    {
        return;
    }
    
    AMapLocalWeatherLive *liveWeather = [response.lives firstObject];
    if (liveWeather != nil)
    {
        NSLog(@"city:%@,weather:%@",liveWeather.city,liveWeather.weather);
    }
}

@end

#ifdef __cplusplus
extern "C" {
#endif
    
    POIController * poictr = nil;
    
    void SearchKeyword()
    {
        //NSLog(@"搜索关键词");
        if(poictr == nil) {
            poictr = [[POIController alloc] init];
        }
        [poictr searchPoiByKeyword];
    }
    
    void SearchAround(const char * keyword)
    {
        //NSLog(@"搜索周围");
        if(poictr == nil) {
            poictr = [[POIController alloc] init];
        }
        
        NSString * str = [NSString stringWithUTF8String:keyword];
        [poictr searchPoiByAround:str];
    }
    
    void QueryWeather()
    {
        //NSLog(@"查询天气");
        if(poictr == nil) {
            poictr = [[POIController alloc] init];
        }
        [poictr onQueryWeather];
    }
    
#ifdef __cplusplus
}
#endif




