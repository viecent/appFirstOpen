//
//  AppDelegate.m
//  Bacchus
//
//  Created by kongkong on 16/4/21.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "AppDelegate.h"
#import <MGJNavigationController/MGJNavigationController.h>
#import <MGJBaseComponent/MGJComponentManager.h>
#import "MLSAppComponent.h"
#import "MLSAppEntrance.h"
#import "MLSRootViewController.h"
#import "MLSWebComponent.h"
#import <MGJRouter/MGJRouter.h>
#import <MLSLogin/MLSLoginComponent.h>
#import <ConfigCenter/MGJConfigCenter.h>
#import "MLSDetailComponent.h"
#import "MLSPopupController.h"
#import <MGJShareComponent.h>
#import "PushManager.h"
#import <URLHelper.h>
#import <MGJAnalytics.h>
#import "URLHandlerModule.h"
#import <MGJStorageService.h>
#import <PredefinedEvent-MGJ/MGJPredefinedEvent.h>

#define CLICK_ON_TABBAR @"mls_click_on_statusbar"
#define kLaunchTime                 @"mgj_launchtime"


@interface AppDelegate()
@property (nonatomic,strong) MLSAppEntrance* appEntrance;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MGJComponentManager registerComponentsFromCustomizedPlist:@"mls_component"];
    
    self.appEntrance = [MLSAppEntrance sharedInstance];
    [self.appEntrance appStart];
    [[MGJShareComponent mgj_sharedInstance] register];
    
#if DEBUG
    [MGJNavigationController currentNavigationController].enableDebug = YES;
#endif
    [PushManager registerPush];
    
    [[URLHandlerModule shareInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [self trackLaunchTime];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[URLHandlerModule shareInstance] applicationDidBecomeActive:application];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    return [[URLHandlerModule shareInstance] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)aUrl sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[URLHandlerModule shareInstance] application:application openURL:aUrl];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [[URLHandlerModule shareInstance] application:app openURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushManager shareInstance] saveToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"RegistFail %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[URLHandlerModule shareInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [[URLHandlerModule shareInstance] application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [touches.anyObject locationInView:self.window];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CLICK_ON_TABBAR object:nil];
    }
}


#pragma marks -
- (void)trackLaunchTime
{
    NSDate *launchTime = [MGJStorageService objectFromMemoryForKey:kLaunchTime];
    NSDate *now = [NSDate date];
    NSInteger offset = (now.timeIntervalSince1970 - launchTime.timeIntervalSince1970) * 1000;
    [MGJAnalytics trackEvent:EVENT_LAUNCH_STEP1 parameters:@{@"time":@(offset)}];
//    DBG(@"launch time :%ld ms", (long)offset);
}

@end
