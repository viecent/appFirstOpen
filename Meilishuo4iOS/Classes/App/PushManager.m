//
//  PushManager.m
//  Meilishuo4iOS
//
//  Created by 独嘉 on 16/5/17.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "PushManager.h"
#import <MWP-SDK-iOS/MWPRemote.h>
#import <MLSUIKit/MLSUIMacros.h>
@interface PushManager ()
@property (nonatomic,copy)NSString *deviceToken;

@end

@implementation PushManager
+ (instancetype)shareInstance {
    static PushManager *g_pushManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_pushManager = [[PushManager alloc] init];
    });
    return g_pushManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerNotification];
    }
    return self;
}

+ (void)registerPush {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
    }
    else {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

- (void)saveToken:(NSData *)token {
    NSString * tokenString = [[[NSString stringWithFormat:@"%@",token]
                                                   stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (IsEmptyString(tokenString)) {
        return;
    }
    [self saveTokenString:tokenString];
}

- (void)saveTokenString:(NSString *)tokenString {
    if (IsEmptyString(tokenString)) {
        return;
    }
    self.deviceToken = tokenString;
    NSDictionary *params = @{@"tid":tokenString,@"appType":@6,@"channelType":@2};
    [[MWPRemote defaultRemote] buildMethod:R_METHOD_POST
                                       api:@"mwp.imcenter.appSaveDevice"
                                   version:@"1"
                                    params:params
                                onCallback:^(id<RemoteResponse> response) {
                                    if ([response isApiSuccess]) {
                                        [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:MLS_PUSH_DEVICE_TOKEN];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                    }
                                }];
}

#pragma mark -
#pragma makr - PrivateAPI
- (void)registerNotification {
    @weakify(self);
    [self mgj_observeNotification:MGJUserDidLoginNotification handler:^(NSNotification *notification) {
        @strongify(self);
        [self saveTokenString:self.deviceToken];
    }];
    
    [self mgj_observeNotification:MGJUserDidLogoutNotification handler:^(NSNotification *notification) {
        @strongify(self);
        [self saveTokenString:self.deviceToken];
    }];
    
}

@end
