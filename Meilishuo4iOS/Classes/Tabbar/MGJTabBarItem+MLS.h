//
//  MGJTabBarItem+MLS.h
//  Meilishuo4iOS
//
//  Created by 凯文马 on 16/6/17.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import <MGJTabBarController/MGJTabBarController.h>

@interface MGJTabBarItem (MLS)

/**
 *  功能：没有title的图标居中操作
 *  理由：由于这个控件在其他APP中也用到，所以不能在其中做修改
 */

- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor selectedTitleColor:(UIColor *)selectedTitleColor icon:(UIImage *)icon selectedIcon:(UIImage *)selectedIcon centerWhenTitleEmpty:(BOOL)center;

@end
