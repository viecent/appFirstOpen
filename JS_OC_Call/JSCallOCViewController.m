//
//  JSCallOCViewController.m
//  JS_OC_Call
//  ios大师群：150245203，欢迎您的加入
//  Created by 亮亮 on 16/9/7.
//  Copyright © 2016年 钱袋宝. All rights reserved.
//

#import "JSCallOCViewController.h"
#import "Bridge.h"

@interface JSCallOCViewController ()

@end

@implementation JSCallOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"js_call_oc";
    _web = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _web.delegate = self;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Index" ofType:@"html"];
    NSURL * urll = [NSURL fileURLWithPath:path isDirectory:NO];
    //NSURL * url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest * req = [NSURLRequest requestWithURL:urll];
    [_web loadRequest:req];
    [self.view addSubview:_web];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //js代码的方法名，可以传递N多参数
    context[@"jsMethodName"] = ^(){
        NSArray * args = [JSContext currentArguments];
        [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //拿到js传递过来的参数后,可以进行一些本地操作,这里简单打印一下。
            NSLog(@"JavaScript方法的第%ld个参数:%@",(long)idx,obj);
        }];
    };
    
    Bridge *jo = [[Bridge alloc] init];
    context[@"umeng"] = jo;
    
    //同样我们也用刚才的方式模拟一下js调用方法
    //NSString *jsStr1=@"testobject.TestNOParameter()";
    //[context evaluateScript:jsStr1];
    //NSString *jsStr2=@"testobject.TestOneParameter('参数1')";
    //[context evaluateScript:jsStr2];
    //NSString *jsStr3=@"testobject.TestTowParameterSecondParameter('参数A','参数B')";
    //[context evaluateScript:jsStr3];
}

@end
