//
//  WKWebView+LoadCookies.h
//  YiDianQian
//
//  Created by Mojy on 2016/12/6.
//  Copyright © 2016年 YiDianQian. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (LoadCookies)

@property (nonatomic, readonly, copy) NSString *cookieString;

- (void)loadRequestWithUrlString:(NSString *)urlString;

@end
