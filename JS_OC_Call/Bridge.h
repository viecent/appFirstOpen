//
//  Bridge.h
//  JS_OC_Call
//
//  Created by 亮亮 on 16/9/7.
//  Copyright © 2016年 钱袋宝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
@protocol JSProtocol <JSExport>
-(void)methodNOParameter;
-(void)methodOneParameter:(NSString *)message;
-(void)methodTwoParameter:(NSString *)message1 SecondParameter:(NSString *)message2;
@end
@interface Bridge : NSObject<JSProtocol>

@end
