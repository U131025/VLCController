//
//  TImePickerView.m
//  VLCController
//
//  Created by mojingyu on 16/3/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "TImePickerView.h"

@interface TimePickerView()

@property (nonatomic, strong) UIView *backgroundView;


@end

@implementation TimePickerView

- (id)init
{
    self = [super init];
    if (self) {
        //
        self.frame = (CGRect){0, 0, ScreenWidth, ScreenHeight};
        //backgroundView
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = RGBAlphaColor(0, 0, 0, 0.6);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singelTapAction:)];
        tap.numberOfTapsRequired = 1;
        [_backgroundView addGestureRecognizer:tap];
        [self addSubview:_backgroundView];
        
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, ScreenWidth-100, 250)];
        borderView.backgroundColor = RGBAlphaColor(255, 255, 255, 0.9);
        borderView.center = self.center;
        borderView.layer.cornerRadius = 5;
        [self addSubview:borderView];
        
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker setDatePickerMode:UIDatePickerModeTime];
        [_datePicker addTarget:self action:@selector(dataPickValueChange:) forControlEvents:UIControlEventValueChanged];
        _datePicker.frame = (CGRect){0,0,ScreenWidth-100, 200};
        _datePicker.backgroundColor = WhiteColor;
        [borderView addSubview:_datePicker];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, (ScreenWidth-100)/2, 50)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [borderView addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelButton.frame), 200, (ScreenWidth-100)/2, 50)];
        [okButton setTitle:@"Done" forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        [borderView addSubview:okButton];
        
    }
    return self;
}

- (void)singelTapAction:(UITapGestureRecognizer *)tap
{
    [self removeFromSuperview];
}

#pragma mark Show
- (void)show
{   
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
}

- (void)dataPickValueChange:(UIDatePicker *)dataPicker
{

}

- (void)doneAction
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *resultString = [dateFormatter stringFromDate:_datePicker.date];
    
    if (self.doneActionBlock) {
        self.doneActionBlock(resultString, _datePicker.date);
    }
    
    [self removeFromSuperview];
}

- (void)cancelAction
{
    [self removeFromSuperview];
}

@end
