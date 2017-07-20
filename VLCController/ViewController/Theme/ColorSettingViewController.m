//
//  ColorSettingViewController.m
//  VLCController
//
//  Created by mojingyu on 16/9/11.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ColorSettingViewController.h"
#import "UIColor+extension.h"
#import "ColorDefine.h"

typedef NS_ENUM(NSInteger, CurrentColorUpdateType) {
    UpdateTypeNormal = 0,
    UpdateTypeStepper,
    UPdateTypeSlider,
};

@interface ColorSettingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *templateColorButton;
@property (weak, nonatomic) IBOutlet UIButton *currentColorButton;

@property (weak, nonatomic) IBOutlet UIStepper *rValueStepper;
@property (weak, nonatomic) IBOutlet UIStepper *gValueStepper;
@property (weak, nonatomic) IBOutlet UIStepper *bValueStepper;

@property (weak, nonatomic) IBOutlet UITextField *rValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *gValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *bValueTextField;

@property (weak, nonatomic) IBOutlet UISlider *rValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *gValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *bValueSlider;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@end

@implementation ColorSettingViewController

- (instancetype)initWithColor:(UIColor *)color withSettingColor:(UIColor *)settingColor
{
    self = [super init];
    if (self) {
        _currentColor = settingColor;
        _templateColor = color;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.useDefaultTableView = NO;
    [super viewDidLoad];
    
//    [self.backgroundImageView ba]
    // Do any additional setup after loading the view from its nib.
    self.templateColorButton.layer.cornerRadius = self.templateColorButton.width / 2;
    self.templateColorButton.layer.borderColor = WhiteColor.CGColor;
    self.templateColorButton.layer.borderWidth = 1;
    
    self.currentColorButton.layer.cornerRadius = self.currentColorButton.width / 2;
    self.currentColorButton.layer.borderWidth = 1;
    self.currentColorButton.layer.borderColor = WhiteColor.CGColor;
    
    self.doneButton.layer.cornerRadius = 15;
    self.doneButton.layer.borderColor = WhiteColor.CGColor;
    self.doneButton.layer.borderWidth = 1;
    
    self.navigationItem.title = @"Color Setting";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_currentColor) {
        self.currentColor = _currentColor;
        
        //样本颜色
        self.templateColorButton.backgroundColor = _templateColor;
        
        [self upateColorTextField];
        [self updateCurrentColorByUpdateType:UPdateTypeSlider];
        [self updateCurrentColorByUpdateType:UpdateTypeStepper];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)stepperValueChange:(UIStepper *)sender
{
    [self changeColorValueByTag:sender.tag value:sender.value];
    [self updateCurrentColorByUpdateType:UPdateTypeSlider];
}

- (IBAction)sliderValueChange:(UISlider *)sender
{
    [self changeColorValueByTag:sender.tag value:sender.value];
    [self updateCurrentColorByUpdateType:UpdateTypeStepper];
    
    NSLog(@"slider Value: %.0f", sender.value);
}

- (void)changeColorValueByTag:(NSInteger)tag value:(CGFloat)value
{
    switch (tag) {
        case 1:
            //R
            self.rValueTextField.text = [NSString stringWithFormat:@"%.0f", value];
            break;
        case 2:
            //G
            self.gValueTextField.text = [NSString stringWithFormat:@"%0.f", value];
            break;
        case 3:
            //B
            self.bValueTextField.text = [NSString stringWithFormat:@"%.0f", value];
            break;
        default:
            break;
    }
}

- (void)upateColorTextField
{
    [self changeColorValueByTag:1 value:[UIColor redValueFromUIColor:self.currentColor]];
    [self changeColorValueByTag:2 value:[UIColor greenValueFromUIColor:self.currentColor]];
    [self changeColorValueByTag:3 value:[UIColor blueValueFromUIColor:self.currentColor]];
}

- (void)updateCurrentColorByUpdateType:(CurrentColorUpdateType)type
{
    NSInteger rValue = 0, gValue = 0, bValue = 0;
   
    if (self.rValueTextField.text.length != 0) {
        rValue = [self.rValueTextField.text integerValue];
    }
    
    if (self.gValueTextField.text.length != 0) {
        gValue = [self.gValueTextField.text integerValue];
    }
    
    if (self.bValueTextField.text.length != 0) {
        bValue = [self.bValueTextField.text integerValue];
    }
    
    self.currentColor = OpaqueRGBColor(rValue, gValue, bValue);
    
    if (type == UpdateTypeStepper) {
        self.rValueStepper.value = rValue;
        self.gValueStepper.value = gValue;
        self.bValueStepper.value = bValue;
    }
    else if (type == UPdateTypeSlider) {
        self.rValueSlider.value = rValue;
        self.gValueSlider.value = gValue;
        self.bValueSlider.value = bValue;
    }
    
}

- (IBAction)okAction:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    if (self.onSelecteColorBlock) {
        self.onSelecteColorBlock(self.currentColor, @"0x00");
    }
}

#pragma mark - Setter
- (void)setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;
    self.currentColorButton.backgroundColor = currentColor;
}

@end
