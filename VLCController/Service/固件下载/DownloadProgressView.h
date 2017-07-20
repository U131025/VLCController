//
//  DownloadProgressView.h
//  VLCController
//
//  Created by mojingyu on 2017/6/15.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadProgressView : UIView

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *tipLabel;

- (void)show;
- (void)hide;

@end
