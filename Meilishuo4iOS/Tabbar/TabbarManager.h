//
//  TabbarManager.h
//  Mogujie4iPhone
//
//  Created by 皮卡 on 15/1/24.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MGJTabBarController/MGJTabBarController.h>
@import UIKit;

@interface TabbarManager : NSObject

/**
 *  单例方法
 *
 *  @return
 */
+ (instancetype)sharedInstance;


/**
 *  下载启动图
 *
 *  @param tabbarData tabBar
 *  @param background tabBar背景
 */
- (void) checkWillDownload:(NSDictionary *)tabbarData
             andBackground:(NSString *)background;

/**
 *  检验目录是否存在
 *  不存在的话创建
 *  @param dictionary 文件目录
 */
- (void)checkDirectory:(NSString *) dictionary;

/**
 *  将图片写入本地缓存文件
 *  @param image 图片
 *  @param imageName 图片名称
 *  @param imageUrl 图片URL
 */
-(void) getImageFromURLAndSaveItToLocalData:(UIImage *)image
                                  imageName:(NSString *)imageName
                                   imageURL:(NSString *)imageUrl;
/**
 *  从缓存中获取下载图片 失败的话取Images.xcassets中的图片
 *  @return UIImage
 *
 */
-(UIImage *)getImageFromCache:(NSString *)imgName;


/**
 *  获取当前的tabbarController
 *  @return NSString
 *
 */
-(void)getTabbarController:(MGJTabBarController *) tabbarController;


@end
