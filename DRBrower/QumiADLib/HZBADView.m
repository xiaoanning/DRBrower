
#import "HZBADView.h"
#import "QumiBannerAD.h"
#import "QumiPartScreen.h"

#define isPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface HZBADView ()

@property (nonatomic,retain) QumiBannerAD      * qumiBannerAD;
@property (nonatomic,retain) QumiPartScreen   *qumiInterCutView;
@property (nonatomic,retain) UIViewController   * vc;


@end

@implementation HZBADView

+(void)addSuperView:(UIView *)superView frame:(CGRect)frame rootViewController:(UIViewController *)vc
{
    HZBADView * adView = [[HZBADView alloc]init];

    adView.qumiBannerAD = [[QumiBannerAD alloc] initWithQumiBannerAD:vc];
    if (isPhone)
    {
        adView.qumiBannerAD.frame = frame;
    }
    else
    {
        adView.qumiBannerAD.frame = frame;
    }

    [adView.qumiBannerAD qmLoadBannerAd:YES];
    [superView addSubview:adView.qumiBannerAD];


}
+(void)addRootViewController:(UIViewController *)vc
{
    
    HZBADView * adView = [[HZBADView alloc]init];

    adView.vc = vc ;
    adView.qumiInterCutView = [[QumiPartScreen alloc] init];
    
    [adView performSelector:@selector(showAd) withObject:nil afterDelay:1];
}
-(void)showAd
{
    [self.qumiInterCutView displayInterCutAd:self.vc withAnimation:QMSlide];

}

@end
