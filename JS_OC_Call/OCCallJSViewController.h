//
//  OCCallJSViewController.h
//  JS_OC_Call
//
//  Created by 亮亮 on 16/9/7.
//  Copyright © 2016年 钱袋宝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
/*!
 *  @author 钱袋宝, 16-09-07 15:09:27
 *
 *  @brief OC调用js代码。
 */
@interface OCCallJSViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView * web;
@end
