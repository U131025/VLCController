//
//  BaseViewController.h
//  VLCController
//
//  Created by mojingyu on 16/1/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LightController+Fetch.h"

#define DefaultCellIdentifier @"DefaultCell"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isBackButton;
@property (nonatomic, assign) BOOL useDefaultTableView;
@property (nonatomic, strong) LightController *light;   //
@property (nonatomic, strong) UIImageView *backgroundImageView;

- (void)setupTableViewWithFrame:(CGRect)frame;

- (void)btnBackClicked:(UIButton *)sender;
- (void)loadBackBtn;

- (void)loadRightButton:(UIImage *)image title:(NSString *)title;
- (void)btnRightClicked:(UIButton *)sender;

- (void)startScanBluetooth;

- (void)returnViewController:(Class)returnVCClass;

- (UIButton *)createDropDownButtonWithView:(UIView *)view withFrame:(CGRect)frame withTitle:(NSString *)title useArrow:(BOOL)useArrow;

- (void)showTipWithMessage:(NSString *)message withTitle:(NSString *)title useCancel:(BOOL)useCancel onOKBlock:(void (^)())onOKBlock;

@end
