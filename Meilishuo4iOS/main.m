//
//  main.m
//  Meilishuo4iOS
//
//  Created by kongkong on 16/5/4.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MGJStorageService.h>
int main(int argc, char * argv[]) {
    @autoreleasepool {
        [MGJStorageService setObjectToMemory:[NSDate date] forKey:@"mgj_launchtime"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
