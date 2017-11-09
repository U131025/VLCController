//
//  BaseViewController.h
//  VLCController
//
//  Created by mojingyu on 16/1/7.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LightController+Fetch.h"
#import "MBProgressHUD.h"

#define DefaultCellIdentifier @"DefaultCell"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isBackButton;
@property (nonatomic, assign) BOOL useDefaultTableView;
@property (nonatomic, strong) LightController *light;   //
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)setupTableViewWithFrame:(CGRect)frame;

- (void)btnBackClicked:(UIButton *)sender;
- (void)loadBackBtn;

- (void)loadRightButton:(UIImage *)image title:(NSString *)title;
- (void)btnRightClicked:(UIButton *)sender;

- (void)startScanBluetooth;

- (void)returnViewController:(Class)returnVCClass;

- (UIButton *)createDropDownButtonWithView:(UIView *)view withFrame:(CGRect)frame withTitle:(NSString *)title useArrow:(BOOL)useArrow;

- (void)showTipWithMessage:(NSString *)message withTitle:(NSString *)title useCancel:(BOOL)useCancel onOKBlock:(void (^)())onOKBlock;

- (void)showMessage:(NSString *)message withTitle:(NSString *)title cancleTitle:(NSString *)cancelTitle cancel:(void (^)())cancel okTitle:(NSString *)okTitle onOKBlock:(void (^)())onOKBlock;

- (void)showInputView:(void (^)(NSString *password))confire cancel:(void (^)())cancel;

- (UIView *)creteaViewWithTitle:(NSString *)title detail:(NSString *)detail;
- (void)goBack;

- (BOOL)popToViewControllerClass:(Class)viewCotrollerClass animated:(BOOL)animated;

@end
