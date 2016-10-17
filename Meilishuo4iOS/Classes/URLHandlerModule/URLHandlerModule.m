//
//  URLHandlerModule.m
//  Meilishuo4iOS
//
//  Created by 独嘉 on 16/5/23.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "URLHandlerModule.h"
#import <ModuleManager/ModuleManager.h>
#import <MGJAnalytics/MGJAnalytics.h>
#import <MGJStorage/MGJStorageService.h>
#import <URLHelper/URLHelper.h>
#import <MLSUIKit/MLSUIMacros.h>
#import <MGJAnalytics/MGJAnalytics.h>
#import <AppPredefinedEvent-MLS/AppMLSPredefinedEvent.h>
#import <MLSPopupController/MLSPopupController.h>

@interface URLHandlerModule ()
@property NSDictionary *remoteInfo;


@end

@implementation URLHandlerModule
+ (instancetype)shareInstance {
    static URLHandlerModule *g_urlHandlerModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_urlHandlerModule = [[URLHandlerModule alloc] init];
    });
    return g_urlHandlerModule;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[launchOptions allKeys] containsObject:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        self.remoteInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if ([[self.remoteInfo allKeys] containsObject:@"info"]) {
            NSString *url = [NSString stringWithFormat:@"%@",[self.remoteInfo objectForKey:@"info"]];
            [MGJAnalytics trackEvent:[AppMLSPredefinedEvent MLS_OPEN_APP_EVENT] parameters:@{@"url" : url}];
        }
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
     [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self handleRemoteInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state != UIApplicationStateActive) {
        self.remoteInfo = userInfo;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url {
    [[NSNotificationCenter defaultCenter]postNotificationName:POPUP_CLOSE_NOTIFACTION object:nil];
    URLHelper *urlEntity = [URLHelper URLWithString:url.absoluteString];
    if ( [@"meilishuo" isEqualToString:url.scheme] || [@"mls" isEqualToString:url.scheme])
    {
        if([@"openURL.meilishuo" isEqualToString:url.host]){
            NSString *jsonParamsString = urlEntity.params[@"json_params"];
            NSData* jsonParamsData = [jsonParamsString dataUsingEncoding:NSUTF8StringEncoding];
            if (!jsonParamsData) {
                return YES;
            }
            NSDictionary* jsonParams = [NSJSONSerialization JSONObjectWithData:jsonParamsData options:0 error:nil];
            NSString *targetUrl = jsonParams[@"url"];
            if (targetUrl.length > 0) {
                [MGJRouter openURL:@"mls://closePopup"];
                [MGJRouter openURL:targetUrl];
            }
            [MGJAnalytics trackEvent:[AppMLSPredefinedEvent MLS_OPEN_APP_EVENT] parameters:@{@"url" : [url absoluteString]}];
        }
    }
    else if (!MGJ_IS_EMPTY(url.scheme)){
        [MGJRouter openURL:urlEntity.absoluteString];
    }
    return YES;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    [self handleOpenURL:url.absoluteString];
//    // 供外部测试 PageURL 使用，这个值会在 DebugVC 里被设置
////    if ([MGJStorageService objectFromMemoryForKey:@"enablePageURLTest"]) {
////        URLHelper *urlEntity = [URLHelper URLWithString:[url absoluteString]];
////        if (urlEntity.params[@"redirect_url"]) {
////            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlEntity.params[@"redirect_url"]]];
////            });
////        }
////    }
//    
//    return YES;
//}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
//        [MGJAnalytics trackEvent:EVENT_LAUNCH_FROM_UNIERSALLINK parameters:@{@"url":userActivity.webpageURL.absoluteString}];
        
        URLHelper *targetUrlEntity = [URLHelper URLWithString:userActivity.webpageURL.absoluteString];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:targetUrlEntity.params];
        parameters[@"url"] = userActivity.webpageURL.absoluteString;
//        [MGJAnalytics trackEvent:EVENT_LAUNCHAPP_EXTERNAL parameters:parameters];
        
        [self handleOpenURL:userActivity.webpageURL.absoluteString];
        return YES;
    }
//    else if ([userActivity.activityType isEqualToString:MGJAppSearchContentTypeGoods]) {
////        [MGJAnalytics trackEvent:EVENT_LAUNCH_FROM_USEARACTIVITY parameters:@{@"url":userActivity.webpageURL.absoluteString}];
//        [self handleOpenURL:[NSString mgj_combineURLWithBaseURL:userActivity.webpageURL.absoluteString parameters:@{@"launch":@"useractivity"}]];
//        return YES;
//    }
    return NO;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter mgj_setObject:shortcutItem.userInfo[@"url"] forKeyIfNotNil:@"url"];
//    [MGJAnalytics trackEvent:EVENT_LAUNCH_SHORTCUT parameters:parameter];
    [MGJRouter openURL:(NSString *)shortcutItem.userInfo[@"url"]];
    completionHandler(YES);
}

#pragma mark - handle url

- (void)handleRemoteInfo
{
    if (self.remoteInfo && [[self.remoteInfo allKeys] containsObject:@"info"]) {
        NSString *url = [NSString stringWithFormat:@"%@",[self.remoteInfo objectForKey:@"info"]];
        [self handleOpenURL:url];
    }
    self.remoteInfo = nil;
}

/**
 *  处理打开URL
 *
 *  @param aUrl NSURL
 */
- (void)handleOpenURL:(NSString *)aUrl{
    URLHelper *url = [URLHelper URLWithString:aUrl];
    
    if ( [@"mogujie" isEqualToString:url.scheme]) {
        
        if([@"open" isEqualToString:url.host]){
            NSString *targetUrl = url.params[@"url"];
            if (targetUrl.length > 0) {
                URLHelper *targetUrlEntity = [URLHelper URLWithString:targetUrl];
                NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:targetUrlEntity.params];
                parameters[@"url"] = targetUrl;
                
//                [MGJAnalytics trackEvent:EVENT_LAUNCHAPP_EXTERNAL parameters:parameters];
                [MGJRouter openURL:targetUrl];
            }
        }
    } else if (!IsEmptyString(url.scheme)){
        [MGJRouter openURL:aUrl];
    }
}

@end
