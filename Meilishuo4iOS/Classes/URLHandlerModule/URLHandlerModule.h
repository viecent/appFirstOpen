//
//  URLHandlerModule.h
//  Meilishuo4iOS
//
//  Created by 独嘉 on 16/5/23.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLHandlerModule : NSObject
+ (instancetype _Nonnull)shareInstance;
- (BOOL)application:(UIApplication * _Nonnull)application didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions;
- (void)applicationDidBecomeActive:(UIApplication *_Nonnull)application;
- (void)application:(UIApplication *_Nonnull)application didReceiveRemoteNotification:(NSDictionary *_Nullable)userInfo;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url;

- (BOOL)application:(UIApplication *_Nonnull)application continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(void (^)(NSArray * _Nullable) )restorationHandler;
- (void)application:(UIApplication *_Nonnull)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL ))completionHandler;
@end
