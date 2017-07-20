//
//  TipViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/8.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "TipViewController.h"
#import "NSString+Extension.h"

@interface TipViewController ()

@property (nonatomic, strong) UITextView *detailTextView ;
@property (nonatomic, strong) UIButton *okButotn;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation TipViewController



- (id)init
{
    self = [super init];
    if (self) {
        //
        self.isCancelIcon = YES;
    }
    return self;
}

- (void)setHeadTitleText:(NSString *)headTitleText
{
    self.navigationItem.title = headTitleText;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.navigationItem.title = @"Test";
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    CGSize detailSize = [_tipDetailText sizeWithFont:Font(14) maxSize:CGSizeMake(ScreenWidth-100, MAXFLOAT)];
    
   UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)-detailSize.height-20, ScreenWidth-100, detailSize.height+10)];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = _tipDetailText;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.font = Font(14);
    detailTextView.textColor = WhiteColor;
    detailTextView.userInteractionEnabled = NO;
    [self.view addSubview:detailTextView];
    
    //title
    UILabel *tipTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(detailTextView.frame)-50, ScreenWidth-100, 50)];
    tipTitleLabel.backgroundColor = [UIColor clearColor];
    tipTitleLabel.text = _tiptilteText;
    tipTitleLabel.textAlignment = NSTextAlignmentCenter;
    tipTitleLabel.font = Font(20);
    tipTitleLabel.textColor = WhiteColor;
    [self.view addSubview:tipTitleLabel];
    
    //button
    if (_okButtonContent) {
        _okButotn = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMidY(self.view.frame)+20, ScreenWidth-100, 50)];
        _okButotn.layer.borderColor = WhiteColor.CGColor;
        _okButotn.layer.borderWidth = 1;
        [_okButotn setTitle:_okButtonContent forState:UIControlStateNormal];
        [_okButotn addTarget:self action:@selector(okButotnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_okButotn];
    }
    
    if (_cancelButtonContent) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_okButotn.frame)+20, CGRectGetWidth(_okButotn.frame), CGRectGetHeight(_okButotn.frame))];
        _cancelButton.layer.borderWidth = 1;
        _cancelButton.layer.borderColor = WhiteColor.CGColor;
        [_cancelButton setTitle:_cancelButtonContent forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelButton];
        
        if (self.isCancelIcon) {
            UIButton *cancelIcon = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(_cancelButton.frame), 60, CGRectGetHeight(_cancelButton.frame))];
            [cancelIcon setTitle:@"✕" forState:UIControlStateNormal];
            cancelIcon.titleLabel.font = Font(30);
            [cancelIcon setTitleColor:WhiteColor forState:UIControlStateNormal];
            [cancelIcon addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:cancelIcon];
            
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelIcon.frame), CGRectGetMinY(cancelIcon.frame), 1, CGRectGetHeight(cancelIcon.frame))];
            line.backgroundColor = WhiteColor;
            [self.view addSubview:line];
        }        
    }
}

- (void)okButotnClick:(UIButton *)button
{ 
    if (_okActionBlock) {
        _okActionBlock();
    }
}

- (void)cancelButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (_cancelActionBlock) {
        _cancelActionBlock();
    }   
}

- (void)loadBackBtn
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    btn.contentHorizontalAlignment = 1;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:buttonItem animated:YES];
}

@end
