//
//  WkWebViewController.h
//  zhenjiu
//
//  Created by Mojy on 2017/4/17.
//  Copyright © 2017年 com.huang. All rights reserved.
//

#import "BaseViewController.h"

#define HomePageUrl @"https://villagelighting.com/pages/lstutorials"

@interface WkWebViewController : BaseViewController

- (instancetype)initWithWebViewUrl:(NSString *)url  titleName:(NSString *)titleName;

/**
 在判断到请求返回Code=XXXX时返回，由调用处进行判断URL是否正确，返回YES后页面跳转到Root，NO不跳转
 */
@property (nonatomic, copy) BOOL (^successBlock)(NSString *urlString, NSString *codeValue, WkWebViewController *controller);


/**
 其他请求的处理回调，需要截取则返回NO，否则返回YES
 */
@property (nonatomic, copy) BOOL (^requestHandle)(WkWebViewController *controller, NSString *urlString);

@end
