//
//  SelectDateView.m
//  iTotemMinFramework
//
//  Created by xiexianhui on 14-7-21.
//
//

#import "SelectDateView.h"

@implementation SelectDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.height = ScreenHeight;
    
    _viewDateBg.center = CGPointMake(ScreenWidth/2, self.height/2);
//    [GlobalData loadView:_viewDateBg withRadius:3];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _imgViewLine.backgroundColor = RGBFromColor(0x2E98E6);

}

- (void)loadTitle:(NSString *)title
{
    _labelTimeTitle.text = title;
}

- (void)loadDate:(NSDate *)date
{
    [_datePicker setDate:date];
}

- (void)loadMaxDate:(NSDate *)date
{
    [_datePicker setMaximumDate:date];
}

- (void)loadMinDate:(NSDate *)date
{
    [_datePicker setMinimumDate:date];
}


#pragma mark 取消选择日期界面
- (IBAction)btnCancelClick:(UIButton *)sender
{
    [self removeFromSuperview];
}

#pragma mark 确认选择日期界面
- (IBAction)btnSureClick:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectDateView:withSelectDate:)]) {
        [_delegate selectDateView:self withSelectDate:_datePicker.date];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
