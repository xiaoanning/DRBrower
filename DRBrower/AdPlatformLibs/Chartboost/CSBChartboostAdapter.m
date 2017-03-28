//
//  CSBChartboostAdapter.m
//  BundleADSDK
//
//  Created by Chance_yangjh on 16/3/4.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CSBChartboostAdapter.h"
#import <Chartboost/Chartboost.h>

#define Class_Chartboost  NSClassFromString(@"Chartboost")

@interface CSBChartboostAdapter () <ChartboostDelegate>
@property (nonatomic, copy) NSString *publisherID;
@property (nonatomic, copy) NSString *appSignature;
@end

@implementation CSBChartboostAdapter

+ (void)load
{
    NSString *version = [Class_Chartboost getSDKVersion];
    if (version.length > 0) {
        NSLog(@"当前Chartboost SDK版本：%@", version);
    }
}

+ (instancetype)sharedInstance
{
    static CSBChartboostAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CSBChartboostAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// Banner是否可用
- (BOOL)bannerEnabled
{
    return NO;
}
// Interstitial是否可用
- (BOOL)interstitialEnabled
{
    return Class_Chartboost != nil;
}
// 视频广告是否可用
- (BOOL)videoEnabled
{
    return Class_Chartboost != nil;
}

- (BOOL)interstitialLoadFinished
{
    if (self.publisherID.length < 1 ||
        self.appSignature.length < 1) {
        return YES;
    }
    // 准备好了，肯定是加载完成了
    if (self.interstitialIsReady) {
        return YES;
    }
    return super.interstitialLoadFinished;
}
- (BOOL)interstitialIsReady
{
    if (self.publisherID.length > 0 && self.appSignature.length > 0) {
        [Class_Chartboost startWithAppId:self.publisherID appSignature:self.appSignature delegate:self];
        return [Class_Chartboost hasInterstitial:CBLocationHomeScreen];
    }
    return NO;
}

- (BOOL)videoAdLoadFinished
{
    if (self.publisherID.length < 1 ||
        self.appSignature.length < 1) {
        return YES;
    }
    // 准备好了，肯定是加载完成了
    if (self.videoAdIsReady) {
        return YES;
    }
    return super.videoAdLoadFinished;
}
- (BOOL)videoAdIsReady
{
    if (self.publisherID.length > 0 && self.appSignature.length > 0) {
        [Class_Chartboost startWithAppId:self.publisherID appSignature:self.appSignature delegate:self];
        return [Class_Chartboost hasRewardedVideo:CBLocationStartup];
    }
    return NO;
}

// 获取广告平台类型
- (CSBADPlatform)platformType
{
    return CSBADPlatform_Chartboost;
}

// 设置广告平台插屏广告参数
- (void)setParamsOfInterstitial:(NSDictionary *)dicParam
{
    NSString *publisherId = dicParam[@"AppId"];
    NSString *appSignature = dicParam[@"AppSignature"];
    if ([publisherId isKindOfClass:NSString.class] && publisherId.length > 0 &&
        [appSignature isKindOfClass:NSString.class] && appSignature.length > 0) {
        self.publisherID = publisherId;
        self.appSignature = appSignature;
    }
}

// 设置广告平台视频广告参数
- (void)setParamsOfVideo:(NSDictionary *)dicParam
{
    NSString *publisherId = dicParam[@"AppId"];
    NSString *appSignature = dicParam[@"AppSignature"];
    if ([publisherId isKindOfClass:NSString.class] && publisherId.length > 0 &&
        [appSignature isKindOfClass:NSString.class] && appSignature.length > 0) {
        self.publisherID = publisherId;
        self.appSignature = appSignature;
    }
}

// 加载插屏广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadInterstitial:(BOOL)ispre withPlacementID:(NSString *)placementID
{
    [super loadInterstitial:ispre withPlacementID:placementID];
    
    [Class_Chartboost setAutoCacheAds:NO];
    if (self.publisherID.length > 0 && self.appSignature.length > 0) {
        // 加载广告
        self.interstitialLoadFinished = NO;
        [Class_Chartboost startWithAppId:self.publisherID appSignature:self.appSignature delegate:self];
        [Class_Chartboost cacheInterstitial:CBLocationHomeScreen];
        [self.interstitialDelegate csbAdapterInterstitialRequest:CSBAdOwner_Chartboost];
        return YES;
    }
    else {
        // 没配置算加载完成
        self.interstitialLoadFinished = YES;
    }
    return NO;
}

// 打开插屏广告
- (BOOL)showInterstitialWithPlacementID:(NSString *)placementID
{
    [super showInterstitialWithPlacementID:placementID];
    
    if (self.interstitialIsReady) {
        [Class_Chartboost startWithAppId:self.publisherID appSignature:self.appSignature delegate:self];
        [Class_Chartboost showInterstitial:CBLocationHomeScreen];
        return YES;
    }
    return NO;
}

// 加载视频广告
// 返回值为YES表示发出了广告请求，NO表示未发出广告请求
- (BOOL)loadVideoAd:(BOOL)ispre withOrientation:(BOOL)portrait
     andPlacementId:(NSString *)placementId
{
    [super loadVideoAd:ispre withOrientation:portrait andPlacementId:placementId];
    
    [Class_Chartboost setAutoCacheAds:NO];
    if (self.publisherID.length > 0 && self.appSignature.length > 0) {
        // 加载广告
        self.videoAdLoadFinished = NO;
        [Class_Chartboost startWithAppId:self.publisherID appSignature:self.appSignature delegate:self];
        [Class_Chartboost cacheRewardedVideo:CBLocationStartup];
        [self.videoAdDelegate csbAdapterVideoRequest:CSBAdOwner_Chartboost];
        // 启动超时监测
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
        [self performSelector:@selector(loadVideoTimeout) withObject:nil afterDelay:self.timeoutOfLoadVideo];
        return YES;
    }
    else {
        // 没配置算加载完成
        self.videoAdLoadFinished = YES;
    }
    return NO;
}

// 打开视频广告
- (BOOL)showVideoAdWithOrientation:(BOOL)portrait
                    andPlacementId:(NSString *)placementId
{
    [super showVideoAdWithOrientation:portrait andPlacementId:placementId];
    
    if (self.videoAdIsReady) {
        [Class_Chartboost startWithAppId:self.publisherID appSignature:self.appSignature delegate:self];
        [Class_Chartboost showRewardedVideo:CBLocationStartup];
        return YES;
    }
    return NO;
}


#pragma mark - Private

- (void)loadVideoTimeout
{
    NSLog(@"%@ 视频广告加载超时", self.platformName);
    self.videoAdLoadFinished = YES;
    __weak id delegate = self.videoAdDelegate;
    self.videoAdDelegate = nil;
    [delegate csbAdapter:CSBAdOwner_Chartboost loadVideoAdFailure:@"Timeout"];
}


#pragma mark - ChartboostDelegate

#pragma mark Interstitial Delegate

/*!
 @abstract
 Called before requesting an interstitial via the Chartboost API server.
 
 @param location The location for the Chartboost impression type.
 
 @return YES if execution should proceed, NO if not.
 
 @discussion Implement to control if the Charboost SDK should fetch data from
 the Chartboost API servers for the given CBLocation.  This is evaluated
 if the showInterstitial:(CBLocation) or cacheInterstitial:(CBLocation)location
 are called.  If YES is returned the operation will proceed, if NO, then the
 operation is treated as a no-op.
 
 Default return is YES.
 */
- (BOOL)shouldRequestInterstitial:(CBLocation)location
{
    return YES;
}

/*!
 @abstract
 Called before an interstitial will be displayed on the screen.
 
 @param location The location for the Chartboost impression type.
 
 @return YES if execution should proceed, NO if not.
 
 @discussion Implement to control if the Charboost SDK should display an interstitial
 for the given CBLocation.  This is evaluated if the showInterstitial:(CBLocation)
 is called.  If YES is returned the operation will proceed, if NO, then the
 operation is treated as a no-op and nothing is displayed.
 
 Default return is YES.
 */
- (BOOL)shouldDisplayInterstitial:(CBLocation)location
{
    return self.needShowInterstitial;
}

/*!
 @abstract
 Called after an interstitial has been displayed on the screen.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an interstitial has
 been displayed on the screen for a given CBLocation.
 */
- (void)didDisplayInterstitial:(CBLocation)location
{
}

/*!
 @abstract
 Called after an interstitial has been loaded from the Chartboost API
 servers and cached locally.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an interstitial has been loaded from the Chartboost API
 servers and cached locally for a given CBLocation.
 */
- (void)didCacheInterstitial:(CBLocation)location
{
    self.interstitialLoadFinished = YES;
    NSLog(@"加载Interstitial成功");
    [self.interstitialDelegate csbAdapterInterstitialLoadSuccess:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after an interstitial has attempted to load from the Chartboost API
 servers but failed.
 
 @param location The location for the Chartboost impression type.
 
 @param error The reason for the error defined via a CBLoadError.
 
 @discussion Implement to be notified of when an interstitial has attempted to load from the Chartboost API
 servers but failed for a given CBLocation.
 */
- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error
{
    self.interstitialLoadFinished = YES;
    NSError *cbError = [self parseCBLoadError:error];
    NSLog(@"加载Interstitial失败：%@", cbError.localizedDescription);
    [self.interstitialDelegate csbAdapter:CSBAdOwner_Chartboost interstitialLoadFailure:cbError.localizedDescription];
}

/*!
 @abstract
 Called after a click is registered, but the user is not fowrwarded to the IOS App Store.
 
 @param location The location for the Chartboost impression type.
 
 @param error The reason for the error defined via a CBLoadError.
 
 @discussion Implement to be notified of when a click is registered, but the user is not fowrwarded
 to the IOS App Store for a given CBLocation.
 */
- (void)didFailToRecordClick:(CBLocation)location withError:(CBClickError)error
{
    
}

/*!
 @abstract
 Called after an interstitial has been dismissed.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an interstitial has been dismissed for a given CBLocation.
 "Dismissal" is defined as any action that removed the interstitial UI such as a click or close.
 */
- (void)didDismissInterstitial:(CBLocation)location
{
    [self.interstitialDelegate csbAdapterInterstitialShowSuccess:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after an interstitial has been closed.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an interstitial has been closed for a given CBLocation.
 "Closed" is defined as clicking the close interface for the interstitial.
 */
- (void)didCloseInterstitial:(CBLocation)location
{
    __weak id delegate = self.interstitialDelegate;
    self.interstitialDelegate = nil;
    [delegate csbAdapterInterstitialDidDismiss:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after an interstitial has been clicked.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an interstitial has been click for a given CBLocation.
 "Clicked" is defined as clicking the creative interface for the interstitial.
 */
- (void)didClickInterstitial:(CBLocation)location
{
    [self.interstitialDelegate csbAdapterInterstitialClicked:CSBAdOwner_Chartboost];
}


#pragma mark Rewarded Video Delegate

/*!
 @abstract
 Called before a rewarded video will be displayed on the screen.
 
 @param location The location for the Chartboost impression type.
 
 @return YES if execution should proceed, NO if not.
 
 @discussion Implement to control if the Charboost SDK should display a rewarded video
 for the given CBLocation.  This is evaluated if the showRewardedVideo:(CBLocation)
 is called.  If YES is returned the operation will proceed, if NO, then the
 operation is treated as a no-op and nothing is displayed.
 
 Default return is YES.
 */
- (BOOL)shouldDisplayRewardedVideo:(CBLocation)location
{
    return self.needShowVideoAd;
}

/*!
 @abstract
 Called after a rewarded video has been displayed on the screen.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a rewarded video has
 been displayed on the screen for a given CBLocation.
 */
- (void)didDisplayRewardedVideo:(CBLocation)location
{
    NSLog(@"视频广告开始播放");
    [self.videoAdDelegate csbAdapterStartPlayVideo:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after a rewarded video has been loaded from the Chartboost API
 servers and cached locally.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a rewarded video has been loaded from the Chartboost API
 servers and cached locally for a given CBLocation.
 */
- (void)didCacheRewardedVideo:(CBLocation)location
{
    NSLog(@"加载视频广告成功");
    self.videoAdLoadFinished = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
    [self.videoAdDelegate csbAdapterLoadVideoAdSuccess:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after a rewarded video has attempted to load from the Chartboost API
 servers but failed.
 
 @param location The location for the Chartboost impression type.
 
 @param error The reason for the error defined via a CBLoadError.
 
 @discussion Implement to be notified of when an rewarded video has attempted to load from the Chartboost API
 servers but failed for a given CBLocation.
 */
- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error
{
    NSString *cbError = [self matchWithCBLoadError:error];
    NSLog(@"加载视频广告失败：%@", cbError);
    self.videoAdLoadFinished = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadVideoTimeout) object:nil];
    [self.videoAdDelegate csbAdapter:CSBAdOwner_Chartboost loadVideoAdFailure:cbError];
}

/*!
 @abstract
 Called after a rewarded video has been dismissed.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a rewarded video has been dismissed for a given CBLocation.
 "Dismissal" is defined as any action that removed the rewarded video UI such as a click or close.
 */
- (void)didDismissRewardedVideo:(CBLocation)location
{
    
}

/*!
 @abstract
 Called after a rewarded video has been closed.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a rewarded video has been closed for a given CBLocation.
 "Closed" is defined as clicking the close interface for the rewarded video.
 */
- (void)didCloseRewardedVideo:(CBLocation)location
{
    __weak id delegate = self.videoAdDelegate;
    self.videoAdDelegate = nil;
    [delegate csbAdapterVideoAdDidDismiss:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after a rewarded video has been clicked.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a rewarded video has been click for a given CBLocation.
 "Clicked" is defined as clicking the creative interface for the rewarded video.
 */
- (void)didClickRewardedVideo:(CBLocation)location
{
    [self.videoAdDelegate csbAdapterVideoAdClicked:CSBAdOwner_Chartboost];
}

/*!
 @abstract
 Called after a rewarded video has been viewed completely and user is eligible for reward.
 
 @param reward The reward for watching the video.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a rewarded video has been viewed completely and user is eligible for reward.
 */
- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward
{
    NSLog(@"视频广告播放完成");
    [self.videoAdDelegate csbAdapterPlayVideoAdFinished:CSBAdOwner_Chartboost];
}


#pragma mark General Delegate

/*!
 @abstract
 Called before a video has been displayed on the screen.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when a video will
 be displayed on the screen for a given CBLocation.  You can then do things like mute
 effects and sounds.
 */
- (void)willDisplayVideo:(CBLocation)location
{
    
}

/*!
 @abstract
 Called after the App Store sheet is dismissed, when displaying the embedded app sheet.
 
 @discussion Implement to be notified of when the App Store sheet is dismissed.
 */
- (void)didCompleteAppStoreSheetFlow
{
    
}

// 包装出错信息
- (NSError *)parseCBLoadError:(CBLoadError)error {
    NSError *err;
    return err;
}
- (NSString *)matchWithCBLoadError:(CBLoadError)error {
    NSString *errInfo = @"";
    switch(error){
        case CBLoadErrorInternetUnavailable:
        {
            errInfo = [NSString stringWithFormat:@"no Internet connection"];
        }
            break;
        case CBLoadErrorInternal:
        {
            errInfo = [NSString stringWithFormat:@"internal error"];
        }
            break;
        case CBLoadErrorNetworkFailure:
        {
            errInfo = [NSString stringWithFormat:@"network error"];
        }
            break;
        case CBLoadErrorWrongOrientation:
        {
            errInfo = [NSString stringWithFormat:@"wrong orientation"];
        }
            break;
        case CBLoadErrorTooManyConnections:
        {
            errInfo = [NSString stringWithFormat:@"too many connections"];
        }
            break;
        case CBLoadErrorFirstSessionInterstitialsDisabled:
        {
            errInfo = [NSString stringWithFormat:@"first session"];
        }
            break;
        case CBLoadErrorNoAdFound:
        {
            errInfo = [NSString stringWithFormat:@"no ad found"];
        }
            break;
        case CBLoadErrorSessionNotStarted:
        {
            errInfo = [NSString stringWithFormat:@"session not started"];
        }
            break;
        case CBLoadErrorNoLocationFound:
        {
            errInfo = [NSString stringWithFormat:@"missing location parameter"];
        }
            break;
        case CBLoadErrorImpressionAlreadyVisible:
        {
            
        }
            break;
        default:
        {
            errInfo = [NSString stringWithFormat:@"unknown error (%@)", @(error)];
        }
            break;
    }
    return errInfo;
}

@end
