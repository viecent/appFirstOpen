//
//  TabbarManager.m
//  Mogujie4iPhone
//
//  Created by 皮卡 on 15/1/24.
//  Copyright (c) 2015年 juangua. All rights reserved.
//

#import "TabbarManager.h"
#import "TabbarItemEntity.h"
#import <MGJMacros/MGJMacros.h>
#import <MGJMacros/MGJEXTScope.h>
#import <MLSUIKit/MLSUIMacros.h>
#import <MGJStorage/MGJStorageService.h>
#import <SDWebImage/SDWebImageManager.h>
#import <MGJUIKit/UIColor+MGJKit.h>
#import <MLSRootViewController.h>

@interface TabbarManager()
@property(nonatomic, strong) NSString       * cacheDirectory;       //存储目录
@property(nonatomic, strong) NSArray        * tabbarNameArray;      //item数组
@property(nonatomic, strong) NSDictionary   * tabbarInfoDic;        //tabBar信息
@property(nonatomic, strong) MGJTabBarController *tabbarController;
@end

@implementation TabbarManager

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    static TabbarManager *tabbarManager = nil;
    dispatch_once(&onceToken, ^{
        tabbarManager = [[TabbarManager alloc] init];
    });
    return tabbarManager;
}

- (id) init
{
    self = [super init];
    
    if(self){
        self.tabbarInfoDic = [[NSDictionary alloc] init];
        self.tabbarNameArray = @[@"timeline", @"buy", @"post", @"im", @"mine"];
        
        self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"mogujie.tabbar.data"];
        [self checkDirectory:self.cacheDirectory];
    }
    return self;
}

-(void) checkDirectory:(NSString *)dictionary
{
    BOOL isDirectory = NO;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dictionary isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:dictionary withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
}


- (void) checkWillDownload:(NSDictionary *)tabbarData andBackground:(NSString *)background;
{
    self.tabbarInfoDic = tabbarData;
    
    //设置Item内容
    if(!MGJ_IS_EMPTY(self.tabbarInfoDic)){
        [self.tabbarInfoDic enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
            
            TabbarItemEntity *itemEntity = [[TabbarItemEntity alloc] initWithDictionary:obj parseArray:YES];
            
            if(itemEntity && itemEntity.icon){
                NSString *keyString = [NSString stringWithFormat:@"%@_icon", key];
                if(![[MGJStorageService objectFromLocalCacheForKey:keyString] isEqualToString:itemEntity.icon ]){
                    [self downloadTabbarImage:[NSString stringWithFormat:@"%@_icon", key]
                                     imageURL:itemEntity.icon];
                    [self downloadTabbarImage:[NSString stringWithFormat:@"%@_icon_selected", key]
                                     imageURL:itemEntity.selIcon];
                } else {
                    [self setTabbarImage:itemEntity
                                 withKey:[NSString stringWithFormat:@"%@", key]];
                }
            }
        }];
    }
    
    //设置TabBar背景
    if(!IsEmptyString(background)){
        [self setTabbarBackground:background];
    }
}

#pragma  mark downloadTabbarImage
-(void)downloadTabbarImage:(NSString *)imageName
                  imageURL:(NSString *)imageUrl
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl]
                                                          options:0
                                                         progress:nil
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            if(!error){
                                                                
                                                                [self getImageFromURLAndSaveItToLocalData:image
                                                                                                imageName:imageName
                                                                                                 imageURL:imageUrl];
                                                            } else {
                                                                [MGJStorageService setObjectToLocalCache:@"false"
                                                                                                  forKey:[NSString stringWithFormat:@"%@_download", imageName]];
                                                            }
                                                        }];
}

#pragma  mark getImageFromURLAndSaveItToLocalData

-(void) getImageFromURLAndSaveItToLocalData:(UIImage *)image
                                  imageName:(NSString *)imageName
                                   imageURL:(NSString *)imageUrl

{
    //缓存图片
    NSString *directoryPath = [self.cacheDirectory stringByAppendingPathComponent:imageName];
    
    NSData *data = UIImagePNGRepresentation(image);
    NSError *error = nil;
    [data writeToFile:directoryPath options:NSAtomicWrite error:&error];
    
    if (!error) {
        //存储路径
        [MGJStorageService setObjectToLocalCache:imageUrl
                                          forKey:imageName];
    }else{
        [MGJStorageService setObjectToLocalCache:@"false"
                                          forKey:[NSString stringWithFormat:@"%@_download", imageName]];
    }
}

-(void) setTabbarBackground:(NSString *)background
{
    @weakify(self);
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:background] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        @strongify(self);
        if (image && !error) {
            [self.tabbarController.mgjTabBar setBackgroundImage:image];
        }
    }];
}

-(void) setTabbarImage:(TabbarItemEntity *)itemEntity
               withKey:(NSString *)key
{
    
    [self.tabbarController.childViewControllers enumerateObjectsUsingBlock:^(MLSRootViewController *vc, NSUInteger idx, BOOL *stop) {
        if (idx == 0 && [key isEqualToString:self.tabbarNameArray[0]]) {
            [self setTabBarItem:vc.mgjTabBarItem
                           text:itemEntity.text
                       SelColor:itemEntity.selColor
                        withKey:key];
        }else if (idx == 1 && [key isEqualToString:self.tabbarNameArray[1]]) {
            [self setTabBarItem:vc.mgjTabBarItem
                           text:itemEntity.text
                       SelColor:itemEntity.selColor
                        withKey:key];
        }else if (idx == 2 && [key isEqualToString:self.tabbarNameArray[2]]) {
            [self setTabBarItem:vc.mgjTabBarItem
                           text:itemEntity.text
                       SelColor:itemEntity.selColor
                        withKey:key];
        }else if (idx == 3 && [key isEqualToString:self.tabbarNameArray[3]]) {
            [self setTabBarItem:vc.mgjTabBarItem
                           text:itemEntity.text
                       SelColor:itemEntity.selColor
                        withKey:key];
        }else if (idx == 4 && [key isEqualToString:self.tabbarNameArray[4]]) {
            [self setTabBarItem:vc.mgjTabBarItem
                           text:itemEntity.text
                       SelColor:itemEntity.selColor
                        withKey:key];
        }else if(idx == 5 && [key isEqualToString:self.tabbarNameArray[2]]){
        }
    }];
}


-(void) setTabBarItem:(MGJTabBarItem *)itemControl
                 text:(NSString *)textSring
             SelColor:(NSString *)colorString
              withKey:(NSString *)key
{
    NSString *icon = [NSString stringWithFormat:@"%@_icon_download", key];
    if(![[MGJStorageService objectFromLocalCacheForKey:icon] isEqualToString:@"false"]){
        NSString *cacheImgName = [NSString stringWithFormat:@"%@_icon", key];
        [itemControl setIcon:[self getImageFromCache:cacheImgName]];
    }
    
    if (![key isEqualToString:self.tabbarNameArray[2]]) {
        NSString *icon_selected = [NSString stringWithFormat:@"%@_icon_selected_download", key];
        if(![[MGJStorageService objectFromLocalCacheForKey:icon_selected] isEqualToString:@"false"]){
            NSString *cacheImgName = [NSString stringWithFormat:@"%@_icon_selected", key];
            [itemControl setSelectedIcon:[self getImageFromCache:cacheImgName]];
        }
    }
    
    [itemControl setTitle:textSring];
    [itemControl setSelectedTextColor:[self getTextColor:colorString]];
}

-(UIColor *) getTextColor:(NSString *)colorHax
{
    UIColor *textColor = [UIColor mgj_colorWithHexString:colorHax alpha:1.0];
    return textColor;
}


-(UIImage *)getImageFromCache:(NSString *) imgName
{
    
    NSString *file = [self.cacheDirectory stringByAppendingFormat:@"%@%@",@"/",imgName];
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    
    return image;
}

-(void)getTabbarController:(MGJTabBarController *) tabbarController
{
    self.tabbarController = tabbarController;
}

@end
