//
//  Bridge.m
//  JS_OC_Call
//  ios大师群：150245203，欢迎您的加入
//  Created by 亮亮 on 16/9/7.
//  Copyright © 2016年 钱袋宝. All rights reserved.
//

#import "Bridge.h"

@implementation Bridge
//一下方法都是只是打了个log 等会看log 以及参数能对上就说明js调用了此处的iOS 原生方法
-(void)methodNOParameter
{
    NSLog(@"methodNOParameter");
}
-(void)methodOneParameter:(NSString *)message
{
    NSLog(@"%@",message);
}
-(void)methodTwoParameter:(NSString *)message1 SecondParameter:(NSString *)message2
{
    NSLog(@"%@\t%@",message1,message2);
}
@end
