//
//  DownloadProgressView.m
//  VLCController
//
//  Created by mojingyu on 2017/6/15.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "DownloadProgressView.h"

@interface DownloadProgressView()



@end

@implementation DownloadProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = RGBAlphaColor(0, 0, 0, 0.6);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
        
        UIView *bodyView = [[UIView alloc] init];
        bodyView.layer.cornerRadius = 5;
        bodyView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bodyView];
        [bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(100);
        }];

        self.tipLabel = [[UILabel alloc] init];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.textColor = [UIColor blackColor];
        self.tipLabel.font = Font(13);
        self.tipLabel.numberOfLines = 0;
        [bodyView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bodyView);
            make.left.equalTo(bodyView).offset(20);
            make.right.equalTo(bodyView).offset(-20);
            make.height.equalTo(bodyView).multipliedBy(2.0/3.0);
        }];
        
        UIView *bottomView = [[UIView alloc] init];
        [bodyView addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipLabel.mas_bottom);
            make.left.right.bottom.equalTo(bodyView);
        }];
        
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.backgroundColor = [UIColor clearColor]; // 设置背景色
        self.progressView.alpha = 1.0; // 设置透明度 范围在0.0-1.0之间 0.0为全透明
        
        self.progressView.progressTintColor = [UIColor greenColor]; // 设置已过进度部分的颜色
        self.progressView.trackTintColor = [UIColor grayColor]; // 设置未过进度部分的颜色
        self.progressView.progress = 0.0; // 设置初始值，范围在0.0-1.0之间，默认是0.0
        // [oneProgressView setProgress:0.8 animated:YES]; // 设置初始值，可以看到动画效果
        
        [self.progressView setProgressViewStyle:UIProgressViewStyleDefault]; // 设置显示的样式
        [bottomView addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(bottomView);
            make.left.equalTo(bottomView).offset(20);
            make.right.equalTo(bottomView).offset(-20);
            make.height.mas_equalTo(5);
        }];
        
        
    }
    return self;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
    self.frame = window.bounds;
}

- (void)hide
{
    [self removeFromSuperview];
}

@end
