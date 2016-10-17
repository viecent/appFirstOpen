//
//  PushManager.h
//  Meilishuo4iOS
//
//  Created by 独嘉 on 16/5/17.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MLS_PUSH_DEVICE_TOKEN                   @"mls_push_device_token"

@interface PushManager : NSObject
+ (instancetype)shareInstance;
+ (void)registerPush;
- (void)saveToken:(NSData *)token;
@end
