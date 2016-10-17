//
//  MLSTabbarManager.m
//  Meilishuo4iOS
//
//  Created by kongkong on 16/5/19.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "MLSTabbarManager.h"
#import <MGJ-Categories/NSObject+MGJSingleton.h>
#import <ConfigCenter/MGJConfigCenter.h>
#import "TabbarItemEntity.h"
#import <MGJMacros/MGJMacros.h>
#import <SDWebImage/SDWebImageManager.h>
#import <MGJStorage/MGJStorageService.h>
#import <MLSRootViewController.h>
#import <MLSUIMacros.h>
#import <MLSCommonMacro.h>
#import "MGJTabBarItem+MLS.h"
#import <SDImageCache.h>
#import <MGJRouter.h>
#import <MGJNavigationController/MGJNavigationController.h>
extern NSInteger MLSUserGuidViewTag;




#define TABBAR_STORAGE  @"com.meilishuo.tabbar.storage"
//#define BARNAMES @[@"首页",@"好物",@"分类",@"消息",@"我"]


@interface MLSTabbarManager()<Singleton>

@property (nonatomic,weak) MGJTabBarController* tabbarVC;
@property (nonatomic,strong) NSArray* tabbarData;
@property (nonatomic,strong) NSArray* tabbarNames;
@property (atomic,assign) NSInteger pendingToShow;

+ (NSString*)cacheDictionary;
@end

@implementation MLSTabbarManager

/**
 *  获取默认配置
 */
+ (NSArray*)defaultDatas{
    static dispatch_once_t onceToken;
    static NSArray* defaultDatas = nil;
    
    dispatch_once(&onceToken, ^{
        NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabbar" ofType:@"json"]];
        NSAssert(fileData, @"fail to get tabbar.json");
        NSArray* obj = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableContainers error:nil];
        NSAssert(fileData, @"fail to load tabbar.json to array");
        NSMutableArray<TabbarItemEntity *>* datas = [NSMutableArray array];
        [obj enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TabbarItemEntity* entity = [TabbarItemEntity entityWithDictionary:obj];
            [datas addObject:entity];
        }];
        defaultDatas = datas;
    });
    
    return defaultDatas;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tabbarNames = @[@"home",@"goods",@"category",@"message",@"mine"];
        self.pendingToShow = 0;
    }
    return self;
}

/**
 *  @brief 配置 Tabbar 管理
 */
+ (void)loadInfoWithTabbarController:(MGJTabBarController*)tabbarController{
    MLSTabbarManager* tabbarManager = [MLSTabbarManager mgj_sharedInstance];
    tabbarManager.tabbarVC = tabbarController;
    [tabbarManager loadData];
}

/**
 *  @brief 加载数据
 */
- (void)loadData{
    self.tabbarData = [MLSTabbarManager defaultDatas];
    [self applyTabbarDatas];
    
    @weakify(self)
    [MGJConfigCenter configAddObserver:self changeBlock:^(NSString *keyPath, id val) {
        @strongify(self)
        if ([val isKindOfClass:[NSArray class]]) {
            [self loadTabbarDataWithArray:val];
        }
        else{
            [self loadTabbarDataWithArray:nil];
        }
    } forKeyPath:@"newTabbar"];
    
    //启动后加载landingPage页，这个如果参数加载太慢，就放弃加载，如果启动已经加载了其他页面 也放弃加载。
    [MGJConfigCenter configAddObserver:self changeBlock:^(NSString *keyPath, id val) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSDate *launchTime = [MGJStorageService objectFromMemoryForKey:@"mgj_launchtime"];
            NSDate *now = [NSDate date];
            NSInteger offset = (now.timeIntervalSince1970 - launchTime.timeIntervalSince1970) ;
            CGFloat shouldLaunchTime = 0;
            if (SCREEN_HEIGHT < 481) {
                shouldLaunchTime = 4.5;
            }
            else if (SCREEN_WIDTH < 321)
            {
#if TARGET_CPU_ARM64
                shouldLaunchTime = 2.5;
#else
                shouldLaunchTime = 3.5;
#endif
            }
            else shouldLaunchTime = 2;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (offset < shouldLaunchTime) {
                    if (!IsEmptyString(val)) {
                        if ([MGJNavigationController currentNavigationController].topViewController == [MGJNavigationController currentNavigationController].rootViewController) {
                            UIWindow * window = [[UIApplication sharedApplication].delegate window];
                            if (![window viewWithTag:MLSUserGuidViewTag]) {
                                [MGJRouter openURL:val];
                            }
                        }
                    }
                }
            });
        });
    } forKeyPath:@"landingPage"];
}



+ (NSComparisonResult)barNameCompareWithOne:(NSString*)one another:(NSString*)another{
    MLSTabbarManager* mgr = [MLSTabbarManager mgj_sharedInstance];
    for (NSString* name in mgr.tabbarNames) {
        if ([name isEqualToString:one]) {
            return NSOrderedAscending;
        }
        else if ([name isEqualToString:another]){
            return NSOrderedDescending;
        }
    }
    return NSOrderedSame;
}

/**
 *  @brief 获取配置
 */
- (void)loadTabbarDataWithArray:(NSArray*)origData{
    if (origData.count != self.tabbarNames.count) {
        return;
    }
    NSMutableArray<TabbarItemEntity*>* datas = [NSMutableArray array];
    [origData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TabbarItemEntity* item = nil;
        NSString* barName = nil;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            barName = obj[@"barName"];
            item = [TabbarItemEntity entityWithDictionary:obj];
            if ([barName isEqualToString:@"category"]) {
                item.text = @"";
            }
        }
        if (item && item.icon && barName) {
            [datas addObject:item];
        }
    }];
    
    self.pendingToShow = self.tabbarNames.count * 2;
    if(datas.count == self.tabbarNames.count){
        [datas sortUsingComparator:^NSComparisonResult(TabbarItemEntity* obj1, TabbarItemEntity* obj2) {
            return [MLSTabbarManager barNameCompareWithOne:obj1.barName another:obj2.barName];
        }];
        self.tabbarData = datas;
    }
    
    [self applyTabbarDatas];
}

/**
 * 下载了图片
 */
- (void)loadImageWithEntity:(TabbarItemEntity*)entity{
    if (!entity || ![entity.icon hasPrefix:@"http"] ||
        ![entity.selIcon hasPrefix:@"http"] ) {
        return ;
    }
    
    if (![[SDImageCache sharedImageCache]diskImageExistsWithKey:entity.icon]){
        @weakify(self);
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:entity.icon]
                                                             options:0
                                                            progress:nil
                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (data) {
                 [[SDImageCache sharedImageCache]storeImageDataToDisk:data forKey:entity.icon];
                 @strongify(self)
                 self.pendingToShow--;
                 [self updateBars];
             }
         }];
    }
    else{
        self.pendingToShow--;
        [self updateBars];
    }
    
    if (![[SDImageCache sharedImageCache]diskImageExistsWithKey:entity.selIcon]){
        @weakify(self)
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:entity.selIcon]
                                                             options:0
                                                            progress:nil
                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (data) {
                 [[SDImageCache sharedImageCache]storeImageDataToDisk:data forKey:entity.selIcon];
                 @strongify(self)
                 self.pendingToShow--;
                 [self updateBars];
             }
         }];
    }
    else{
        self.pendingToShow--;
        [self updateBars];
    }
}

- (void)updateBars{
    if (0 != self.pendingToShow) {
        return;
    }
    @weakify(self)
    [self.tabbarVC.viewControllers enumerateObjectsUsingBlock:^(__kindof MLSRootViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        [self setUpTabbarItemWithVC:obj entity:self.tabbarData[idx] index:idx];
    }];
}

- (void)setUpTabbarItemWithVC:(MLSRootViewController*)vc entity:(TabbarItemEntity*)entity index:(NSInteger)index{
    if (!vc || !entity) {
        return;
    }
    
    NSString* title = entity.text;
    if (IsEmptyString(entity.color)) {
        entity.color = @"#999999";
    }
    UIColor *color = [self colorWithString:entity.color];
    
    if (IsEmptyString(entity.selColor)) {
        entity.selColor = @"#FF5777";
    }
    UIColor *selectColor = [self colorWithString:entity.selColor];
    UIImage* image = nil;
    UIImage* selectedImage = nil;
    
    if ([entity.icon hasPrefix:@"http"]) {
        
        image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:entity.icon];
        selectedImage = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:entity.selIcon];
        if (!image || !selectedImage) {
            //            TabbarItemEntity* defaultEntity =
            image = [UIImage imageNamed:[NSString stringWithFormat:@"tab_%@_normal",entity.barName]];
            selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"tab_%@_highlight",entity.barName]];
        }
    }
    else{
        TabbarItemEntity* item = [[MLSTabbarManager defaultDatas]objectAtIndex:index];
        if (item) {
            title = item.text;
            color = [self colorWithString:item.color];
            selectColor = [self colorWithString:item.selColor];
            image = [UIImage imageNamed:item.icon];
            selectedImage = [UIImage imageNamed:item.selIcon];
        }
    }
    
    if (vc.mgjTabBarItem) {
        [vc.mgjTabBarItem resetItemWithTitle:title color:color selectedColor:selectColor icon:image selectedIcon:selectedImage];
    }
    else{
        vc.mgjTabBarItem = [[MGJTabBarItem alloc]initWithTitle:title titleColor:color selectedTitleColor:selectColor icon:image selectedIcon:selectedImage centerWhenTitleEmpty:YES];
    }
}

- (UIColor*)colorWithString:(NSString*)hexString{
    if (IsEmptyString(hexString) ||
        ![hexString isKindOfClass:[NSString class]] ||
        hexString.length < 2) {
        return [UIColor whiteColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF) / 255.0 alpha:1.0];
}

/**
 *  @brief 应用配置
 */
- (void)applyTabbarDatas{
    [self.tabbarData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        [self iconImageWithEntity:obj];
        [self loadImageWithEntity:obj];
    }];
    
    [self updateBars];
}

@end
