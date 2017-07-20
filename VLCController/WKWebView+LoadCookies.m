//
//  WKWebView+LoadCookies.m
//  YiDianQian
//
//  Created by Mojy on 2016/12/6.
//  Copyright © 2016年 YiDianQian. All rights reserved.
//

#import "WKWebView+LoadCookies.h"

@implementation WKWebView (LoadCookies)

- (NSString *)cookieString
{
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    
    return cookieValue;    
}


- (void)loadRequestWithUrlString:(NSString *)urlString
{    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:self.cookieString forHTTPHeaderField:@"Cookie"];
    
    [self loadRequest:request];
}

@end
