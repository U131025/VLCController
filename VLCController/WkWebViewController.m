//
//  WkWebViewController.m
//  zhenjiu
//
//  Created by Mojy on 2017/4/17.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import "WkWebViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebView+LoadCookies.h"

@interface WkWebViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, copy) NSString *webViewUrl;
@property (nonatomic, strong) WKWebView *wkWebview;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation WkWebViewController

- (instancetype)initWithWebViewUrl:(NSString *)url titleName:(NSString *)titleName
{
    self=[super init];
    if (self) {
        
        _webViewUrl =url;
        self.title = titleName;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI
{
//    [self setupCustomNavigationBar];
    
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    // 设置偏好设置
    webConfig.preferences = [[WKPreferences alloc] init];
    // 默认为0
    webConfig.preferences.minimumFontSize = 10;
    // 默认认为YES
    webConfig.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    webConfig.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // web内容处理池
    webConfig.processPool = [[WKProcessPool alloc] init];
    // 将所有cookie以document.cookie = 'key=value';形式进行拼接
//    NSString *cookieValue = @"document.cookie = 'fromapp=ios';document.cookie = 'channel=appstore';";
    // 在此处获取返回的cookie
    
    // 加cookie给h5识别，表明在ios端打开该地址
    WKUserContentController* userContentController = WKUserContentController.new;
    WKUserScript * cookieScript = [[WKUserScript alloc]
                                   initWithSource:self.wkWebview.cookieString
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    
    
    webConfig.userContentController = userContentController;
    
    self.wkWebview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webConfig];
    self.wkWebview.UIDelegate = self;
    self.wkWebview.navigationDelegate = self;
    [self.view addSubview:self.wkWebview];
    [self.wkWebview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(NavBarHeight);
    }];
    
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [self.indicatorView  startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.wkWebview loadRequestWithUrlString:self.webViewUrl];
        
    });
}

#pragma mark - Getter

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.color = [UIColor grayColor];
        _indicatorView.hidesWhenStopped = YES;
    }
    
    return _indicatorView;
}

#pragma mark 8.0以上采用WKWebView
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.indicatorView stopAnimating];
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [self.indicatorView stopAnimating];
}

#pragma mark捕获url视图的方法
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
    NSString *url = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
//    NSLog(@"url %@ ********",url);
    
    //其他请求的处理
    if (self.requestHandle && !self.requestHandle(self, url)) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"body:%@",message.body);
    
}

@end
