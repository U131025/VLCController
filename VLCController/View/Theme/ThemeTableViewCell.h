//
//  ThemeTableViewCell.h
//  VLCController
//
//  Created by Mojy on 2016/11/29.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelModel.h"

@interface ThemeTableViewCell : UITableViewCell

@property (nonatomic, strong) ChannelModel *model;
@property (nonatomic, strong) UIButton *primaryColorButton;
@property (nonatomic, strong) UIButton *fadeToColorButton;

@property (nonatomic, copy) void (^buttonHandel)(BOOL isPrimaryColor);

@end
