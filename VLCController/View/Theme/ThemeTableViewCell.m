//
//  ThemeTableViewCell.m
//  VLCController
//
//  Created by Mojy on 2016/11/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ThemeTableViewCell.h"
#import "myUILabel.h"
#import "UIColor+extension.h"

@interface ThemeTableViewCell()

@property (nonatomic, strong) myUILabel *channelName;
@property (nonatomic, strong) myUILabel *primaryColorName;
@property (nonatomic, strong) myUILabel *fadeToColorName;

@end

@implementation ThemeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat columnWidth = (ScreenWidth-60) / 5;
        
        self.channelName = [[myUILabel alloc] initWithFrame:CGRectMake(30, 0, columnWidth, 40)];
        self.channelName.verticalAlignment = VerticalAlignmentMiddle;
        self.channelName.textAlignment = NSTextAlignmentLeft;
        self.channelName.font = Font(12);
        self.channelName.textColor = WhiteColor;
        [self addSubview:self.channelName];
        
        //primary color
        self.primaryColorName = [[myUILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.channelName.frame), 0, columnWidth*2 - 50, 40)];
        self.primaryColorName.verticalAlignment = VerticalAlignmentMiddle;
        self.primaryColorName.textAlignment = NSTextAlignmentRight;
        self.primaryColorName.font = Font(12);
        self.primaryColorName.textColor = WhiteColor;
        [self addSubview:self.primaryColorName];
        
        //button
        self.primaryColorButton = [self createRoundButton:CGRectMake(CGRectGetMaxX(self.primaryColorName.frame)+10, 5, 30, 30)];
        self.primaryColorButton.tag = 0;
        [self.primaryColorButton addTarget:self action:@selector(colorBurronHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.primaryColorButton];
        
        //fade to color
        self.fadeToColorName = [[myUILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.primaryColorButton.frame)+10, 0, columnWidth*2 - 40, 40)];
        self.fadeToColorName.verticalAlignment = VerticalAlignmentMiddle;
        self.fadeToColorName.textAlignment = NSTextAlignmentRight;
        self.fadeToColorName.font = Font(12);
        self.fadeToColorName.textColor = WhiteColor;
        [self addSubview:self.fadeToColorName];
        
        self.fadeToColorButton = [self createRoundButton:CGRectMake(CGRectGetMaxX(self.fadeToColorName.frame)+10, 5, 30, 30)];
        self.fadeToColorButton.tag = 1;
        [self.fadeToColorButton addTarget:self action:@selector(colorBurronHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.fadeToColorButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIButton *)createRoundButton:(CGRect)frame
{
    CGFloat radiusValue = CGRectGetHeight(frame) > CGRectGetWidth(frame) ? CGRectGetWidth(frame) : CGRectGetHeight(frame);
    
    UIButton *roundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    roundButton.layer.borderColor = WhiteColor.CGColor;
    roundButton.layer.masksToBounds = YES;
    roundButton.layer.borderWidth = 1;
    roundButton.layer.cornerRadius = radiusValue/2;
    roundButton.frame = (CGRect){frame.origin.x, frame.origin.y, radiusValue, radiusValue};
    
    return roundButton;
}

#pragma mark - Setter

- (void)setModel:(ChannelModel *)model
{
    //刷新数据
    self.channelName.text = model.name;
    
    self.primaryColorName.text = [self formatColorType:model.colorType];
    [self setButtonColor:self.primaryColorButton WithModel:model isSubColor:NO];
    
    self.fadeToColorName.text = [self formatColorType:model.subColorType];
    [self setButtonColor:self.fadeToColorButton WithModel:model isSubColor:YES];
  
}

- (NSString *)formatColorType:(NSString *)colorType
{
    if (colorType && ![colorType isEqualToString:@"╳"]) {
        
       return colorType;
    }
    
    return @"";
}

- (void)setButtonColor:(UIButton *)button WithModel:(ChannelModel *)model isSubColor:(BOOL)isSubColor
{
    NSString *colorType = isSubColor ? model.subColorType : model.colorType;
    
    if ([colorType isEqualToString:@"Warm Clear"]) {
        //Warm Clear
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Warm Clear"]) {
            button.backgroundColor = [UIColor getColor:[[NSUserDefaults standardUserDefaults] objectForKey:@"Warm Clear"]];
        }
        else {
            button.backgroundColor = RGBFromColor(0xfefe9c);
        }
    }
    else {
        button.backgroundColor = isSubColor ? model.showSubColor : model.showColor;
    }
    
    if (!button.backgroundColor) {
        [button setTitle:@"╳" forState:UIControlStateNormal];
    }
    else {
        [button setTitle:@"" forState:UIControlStateNormal];
    }

}
#pragma mark - Handle
- (void)colorBurronHandle:(UIButton *)button
{
    if (self.buttonHandel) {
        if (button.tag == 0) {
            self.buttonHandel(YES);
        }
        else {
            self.buttonHandel(NO);
        }
    }
}

@end
