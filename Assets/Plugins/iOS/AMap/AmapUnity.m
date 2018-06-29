#import "AmapUnity.h"
#import "AmapGaoDe.h"

@implementation AmapUnity

//Unity to  ios  dayin
AmapGaoDe *iapAmap =nil;

void LocateInit()
{
    NSLog(@"Msg ==========初始化定位");
    iapAmap = [[AmapGaoDe alloc] init];
    [iapAmap locateInit];
}

void LocateOnce()
{
    NSLog(@"Msg ===========单次定位");
    [iapAmap locateOnce];
}

void LocateUpdate()
{
    NSLog(@"Msg ===========持续定位");
    [iapAmap locateUpdate];
}

void LocateStop()
{
    NSLog(@"Msg ===========结束定位");
    [iapAmap locateStop];
}

@end
