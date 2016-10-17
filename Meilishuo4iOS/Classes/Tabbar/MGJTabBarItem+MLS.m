//
//  MGJTabBarItem+MLS.m
//  Meilishuo4iOS
//
//  Created by 凯文马 on 16/6/17.
//  Copyright © 2016年 Kongkong. All rights reserved.
//

#import "MGJTabBarItem+MLS.h"
#import <objc/runtime.h>

@interface MGJTabBarItem ()

@end

@implementation MGJTabBarItem (MLS)

- (id)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor selectedTitleColor:(UIColor *)selectedTitleColor icon:(UIImage *)icon selectedIcon:(UIImage *)selectedIcon centerWhenTitleEmpty:(BOOL)center
{
    if (self = [self initWithTitle:title titleColor:titleColor selectedTitleColor:selectedTitleColor icon:icon selectedIcon:selectedIcon]) {
        self.mlsImageView.tag = center;
    }
    return self;
}

+ (void)load
{
    Method m1 = class_getInstanceMethod([self class], @selector(layoutSubviews));
    Method m2 = class_getInstanceMethod([self class], @selector(swizzlingLayoutSubviews));
    method_exchangeImplementations(m1, m2);
}

- (void)swizzlingLayoutSubviews
{
    [self swizzlingLayoutSubviews];
    // 获取imageView
    UIImageView *imageView = self.mlsImageView;
    if (imageView.tag == (NSInteger)YES && self.mlsLabel.text.length < 1) {
        CGSize size = imageView.image.size;
        CGFloat height = self.height - 2 * 7.5;
        imageView.bounds = CGRectMake(0, 7.5, ceil(height / (size.height / size.width)), height);
        imageView.centerY = self.centerY;
    }
}

/** 获取imageView */
- (UIImageView *)mlsImageView
{
    UIImageView *imageView = [self valueForKey:@"imageView"];
    if (imageView && [imageView isKindOfClass:[UIImageView class]]) {
        return imageView;
    }
    return nil;
}

/** 获取imageView */
- (UILabel *)mlsLabel
{
    UILabel *label = [self valueForKey:@"label"];
    if (label && [label isKindOfClass:[UILabel class]]) {
        return label;
    }
    return nil;
}

@end
