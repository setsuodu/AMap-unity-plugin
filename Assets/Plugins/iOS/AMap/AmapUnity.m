#import "AmapUnity.h"
#import "AmapGaoDe.h"

@implementation AmapUnity

//Unity to  ios  dayin
AmapGaoDe *iapAmap = nil;

void LocateInit()
{
    NSLog(@"==>> 初始化定位");
    if(iapAmap == nil){
        iapAmap = [[AmapGaoDe alloc] init];
    }
    [iapAmap locateInit];
}

void LocateOnce()
{
    NSLog(@"==>> 单次定位");
    [iapAmap locateOnce];
}

void LocateUpdate()
{
    NSLog(@"==>> 持续定位");
    [iapAmap locateUpdate];
}

void LocateStop()
{
    NSLog(@"==>> 结束定位");
    [iapAmap locateStop];
}

void ShowMapView()
{
    NSLog(@"==>> 显示地图");
    [iapAmap showMapView];
}

@end
