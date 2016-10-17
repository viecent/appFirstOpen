//
//  SplashComponent.m
//  Meilishuo4iOS
//
//  Created by 止水 on 16/5/13.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "SplashComponent.h"
#import "SplashViewController.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "MGJConfigCenter+MCE.h"
#import "MGJStorageService.h"

NSString *SplashDidFinishedNotification = @"SplashDidFinishedNotification";

@interface SplashComponent () <SplashViewControllerDelegate>
{
    SplashViewController *_vc;
    NSDictionary *_data;
}
@end

@implementation SplashComponent

- (BOOL)applicationDidFinishLaunchingWithOptions:(UIApplication *)application
{
    _data = [MGJStorageService objectFromLocalCacheForKey:@"com.meilishuo.mlsconfig"];
    
    [MGJConfigCenter mceValueWithKeys:@"6256" callback:^(NSError *error, id value) {
        if (error) {
            
        }
        else if ([value isKindOfClass:[NSDictionary class]]){
            _data = value;
            [MGJStorageService setObjectToLocalCache:value forKey:@"com.meilishuo.mlsconfig"];
            
        }
    }];
    
    return YES;
}

- (void)show
{
    if (!_data[@"6256"]) {
        return;
    }
    
    NSArray *array = _data[@"6256"][@"list"];
    if (!array.count) {
        return;
    }
    NSDictionary *splashInfo = array[0];
    NSInteger interval = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger start = [splashInfo[@"start"] integerValue];
    NSInteger end = [splashInfo[@"end"] integerValue];
    if (interval < start || interval > end) {
        return;
    }
    NSString *imageKey = splashInfo[@"image"];
    NSString *gotoUrl = splashInfo[@"link"];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageKey];
    if (image) {
        _vc = [[SplashViewController alloc] init];
        _vc.delegate = self;
        _vc.adImage = image;
        _vc.gotoUrl = gotoUrl;
        
        UIViewController *keyVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [keyVC.view addSubview:_vc.view];
        
        [_vc beginCountDown];
        
    } else {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageKey] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
        }];
    }
}

- (void)splashDidFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SplashDidFinishedNotification object:nil];
}

@end
