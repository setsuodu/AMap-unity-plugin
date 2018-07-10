#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface POIController : UIViewController

@property (nonatomic, strong) AMapSearchAPI *search;

//- (void)searchPoiByKeyword;
//- (void)searchPoiByAround;

@end
