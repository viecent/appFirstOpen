//
//  MLSAppEntrance.m
//  Meilishuo4iOS
//
//  Created by kongkong on 16/5/11.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

@import UIKit;
#import "MLSAppEntrance.h"
#import <MGJBaseComponent/MGJComponentManager.h>
#import <MLSUIKit/MLSCommonMacro.h>
#import <MLSUIKit/MLSUIMacros.h>
#import <MLSMe/MLSMeComponent.h>
#import <MLSHomePage/MLSHomePageComponent.h>
#import <MGJNavigationController/MGJNavigationController.h>
#import <MLSHWHome/MLSHWComponent.h>
#import <MLSUser.h>
#import <LOGINLoginAnalyticsUtil.h>
#import <MLSIM/MLSIMComponent.h>
#import <UIControl+BlocksKit.h>
#import <URLHelper.h>
#import "MLSTabbarManager.h"
#import <MGJUIComponent/MGJStyleManager.h>
#import "MLSActivityLoading.h"
#import <MGJConfigCenter.h>
#import "MLSPublishHelper.h"

@interface MLSAppEntrance()<MGJTabBarControllerDelegate>{
    NSTimeInterval _lastDebugClick;
    NSInteger _clickCount ;
}
@property (nonatomic, strong) MGJNavigationController* rootVC;
@property (nonatomic, weak) MGJTabBarController*    tabBarVC;
@property (nonatomic, strong) UIWindow* windows;
@end

@implementation MLSAppEntrance

- (void)appStart{
    [self entrance];
}

- (UIWindow *)windows{
    if (!_windows) {
        _windows = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    }
    return _windows;
}

- (void)entrance{
    
    MGJTabBarController *tabbarController = [[MGJTabBarController alloc] initWithViewControllers:
                                             @[[[MLSHomePageComponent sharedInstance]rootViewController],
                                               [[MLSHWComponent sharedInstance]rootViewController],
                                               //                                               [[MLSClassificationComponent sharedInstance]rootViewController],
                                               [[MLSRootViewController alloc] init], // 833 为中间按钮创建的空控制器
                                               [[MLSIMComponent sharedInstance]rootViewController],
                                               [[MLSMeComponent sharedInstance]rootViewController]
                                               ] selectedIndex:0];
    
    tabbarController.titleColor = MGJ_TextGray51;
    tabbarController.selectedTitleColor = MGJ_TextPink;
    tabbarController.mgjTabBarControllerDelegate = self;
    [MLSTabbarManager loadInfoWithTabbarController:tabbarController];

    MGJNavigationController *navigationController = [[MGJNavigationController alloc] initWithRootViewController:tabbarController];
    
    self.windows.rootViewController = navigationController;
    [self.windows makeKeyAndVisible];
    [[[UIApplication sharedApplication] delegate] setWindow:self.windows];

    self.rootVC = navigationController;
    self.tabBarVC = tabbarController;
    
    
    if ([[MGJConfigCenter configItemforKeyPath:@"enableDebug"]boolValue]) {
        [[NSNotificationCenter defaultCenter]mgj_observeNotification:@"mls_click_on_statusbar" handler:^(NSNotification *notification) {
            [self enterDebug];
        }];
    }
    
    
    @weakify(self)
    [[NSNotificationCenter defaultCenter] mgj_observeNotification:MGJUserDidLogoutNotification handler:^(NSNotification *notification) {
        @strongify(self)
        [self handleURL:@"mls://index" withUserInfo:nil completion:nil];
    }];
}

- (void)enterDebug{
    NSTimeInterval cur = [[NSDate date]timeIntervalSince1970]*1000.0;
    if (cur - _lastDebugClick < 300) {
        _clickCount ++;
    }
    _lastDebugClick = cur;
    
    if (4 == _clickCount) {
        _clickCount = 0;
        [MGJRouter openURL:@"mgj://debug"];
    }
}

#pragma mark - MGJTabBarDelegate
- (BOOL)tabBarController:(MGJTabBarController *)tabBarController shouldSelectViewController:(MLSRootViewController *)viewController atIndex:(NSInteger)index
{
    if (index == 4 && ![[MGJUser shareInstance] isLogin]) {
        [[LOGINLoginAnalyticsUtil sharedInstance] trackLoginInfoWithSource:@"login_mypage_tab"];
        [MGJUser loginWithBlock:^(BOOL isLogin) {
            [tabBarController selectAtIndex:4];
        }];
        return NO;
    }
    else if (index == 3 && ![[MGJUser shareInstance] isLogin]) {
        [[LOGINLoginAnalyticsUtil sharedInstance] trackLoginInfoWithSource:@"login_message_tab"];
        [MGJUser loginWithBlock:^(BOOL isLogin) {
            [tabBarController selectAtIndex:3];
        }];
        return NO;
    }
    else if (index == 2) {
        UIView *view = [MLSPublishHelper showPublishViewWithView:tabBarController.view Complete:^(MLSPublishType type, BOOL success) {
            if (tabBarController.selectIndex != 0) {
                [tabBarController selectAtIndex:0];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MLSPublishSuccessOnTarbarNotification" object:nil userInfo:@{@"type":@(type)}];
        }];
        view.tag = MLSPublishTypeFromTabbar;
        return NO;
    }
    return YES;
}

#pragma -mark MGJBaseComponent
- (NSArray *)registeredURLs{
    return @[@"mls://mehome",
             @"mls://index",
             @"mls://imContacts",
             @"mls://indexcategory",
             @"mls://nicegoods"];
}

- (void)handleURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(void (^)(id))completion{
    URLHelper* helper = [URLHelper URLWithString:URL];
    
    if ([helper.host isEqualToString:@"index"]) {
        if (self.rootVC.topViewController != self.rootVC.rootViewController) {
            [self.rootVC popToRootViewControllerAnimated:YES completed:nil];
        }
        [self.tabBarVC selectAtIndex:0];
    }
    else if ([helper.host isEqualToString:@"indexcategory"]) {
        if (self.rootVC.topViewController != self.rootVC.rootViewController) {
            [self.rootVC popToRootViewControllerAnimated:YES completed:nil];
        }
        [self.tabBarVC selectAtIndex:2];
    }
    else if ([helper.host isEqualToString:@"imContacts"]) {
        if (self.rootVC.topViewController != self.rootVC.rootViewController) {
            [self.rootVC popToRootViewControllerAnimated:YES completed:nil];
        }
        [self.tabBarVC selectAtIndex:3];
    }
    else if ([helper.host isEqualToString:@"mehome"]) {
        if (self.rootVC.topViewController != self.rootVC.rootViewController) {
            [self.rootVC popToRootViewControllerAnimated:YES completed:nil];
        }
        [self.tabBarVC selectAtIndex:4];
    }
    else if ([helper.host isEqualToString:@"nicegoods"]) {
        if (self.rootVC.topViewController != self.rootVC.rootViewController) {
            [self.rootVC popToRootViewControllerAnimated:YES completed:nil];
        }
        [self.tabBarVC selectAtIndex:1];
    }
}

- (BOOL)applicationDidFinishLaunchingWithOptions:(UIApplication *)application{
    [[MGJStyleManager currentManager]applyStyle:@{@"_registerList":@{
                                                          @"LoadingView":NSStringFromClass([MLSActivityLoading class])
                                                          }
                                                  }];
    return YES;
}
@end
