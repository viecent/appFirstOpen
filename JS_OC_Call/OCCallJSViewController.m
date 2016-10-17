//
//  OCCallJSViewController.m
//  JS_OC_Call
//  ios大师群：150245203，欢迎您的加入
//  Created by 亮亮 on 16/9/7.
//  Copyright © 2016年 钱袋宝. All rights reserved.
//

#import "OCCallJSViewController.h"

@interface OCCallJSViewController ()

@end

@implementation OCCallJSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _web = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _web.delegate = self;
    NSURL * url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    [_web loadRequest:req];
    [self.view addSubview:_web];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    JSContext *content = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString * runJS = @"alert('OC成功调用了JavaScript的alert()方法!')";
    [content evaluateScript:runJS];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
