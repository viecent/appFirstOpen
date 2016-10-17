//
//  TabbarItemEntity.h
//  Meilishuo4iOS
//
//  Created by kongkong on 16/5/19.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "MGJEntity.h"

@interface TabbarItemEntity : MGJEntity
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *selIcon;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *selColor;
@property (nonatomic, strong) NSString *barName;
@end
