//
//  TextTableViewCell.h
//  VLCController
//
//  Created by mojingyu on 16/1/18.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TextCellIdentifer @"TextCell"

@interface TextTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *subTitleText;
@property (nonatomic, assign) BOOL isArrow;
@property (nonatomic, assign) BOOL isBottomLine;
@property (nonatomic, assign) BOOL isTopLine;

@end
