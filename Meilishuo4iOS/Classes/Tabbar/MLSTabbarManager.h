//
//  MLSTabbarManager.h
//  Meilishuo4iOS
//
//  Created by kongkong on 16/5/19.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MGJTabbarController.h>

extern NSInteger UserGuideTag;

@interface MLSTabbarManager : NSObject

+ (void)loadInfoWithTabbarController:(MGJTabBarController*)tabbarController;

@end
