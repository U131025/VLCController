//
//  ColorSelectorViewController.m
//  VLCController
//
//  Created by mojingyu on 16/9/11.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ColorSelectorViewController.h"
#import "ColorButton.h"
#import "ColorSettingViewController.h"
#import "UIColor+extension.h"
#import "EditThemeViewController.h"

@interface ColorSelectorViewController ()<ColorButtonDelegate>

@property (nonatomic, copy) NSArray *colors;
@property (nonatomic, copy) NSDictionary *colorsDic;
@property (nonatomic, copy) NSDictionary *showColorsDic;

@end

@implementation ColorSelectorViewController

- (void)viewDidLoad
{
    
    self.useDefaultTableView = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    self.backgroundImageView.image = [UIImage imageNamed:@"backgroundNoIcon"];
    self.navigationItem.title = @"Color Options";
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load UI
- (void)setupUI
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, ScreenWidth, 30)];
    titleLabel.textColor = WhiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Please select a color";
    titleLabel.font = FontBold(16);
    [self.view addSubview:titleLabel];
    
    [self loadColorButtons];
}

- (void)loadColorButtons
{
    CGFloat buttonWidth = 60;
    CGFloat interval = (ScreenWidth - buttonWidth * 4.0) / 5.0;
    CGFloat offsetX = interval;
    CGFloat offsetY = 120;
    NSInteger index = 0;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, offsetY, ScreenWidth, ScreenHeight)];
    [self.view addSubview:scrollView];
    
    //获取默认颜色值
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in self.colors) {
        
        UIColor *colorValue = [self.showColorsDic objectForKey:key];
        
        ColorButton *colorButton = [[ColorButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, buttonWidth, buttonWidth)];
        colorButton.backgroundColor = colorValue;
        colorButton.text = key;
        
        if ([key isEqualToString:@"╳"]) {
            colorButton.font = Font(40);
            colorButton.textColor = WhiteColor;
        }
        
        if (![key isEqualToString:@"╳"]
           && ![key isEqualToString:@"Warm Clear"]
        //           && ![key isEqualToString:@"Winter White"]
           && ![key isEqualToString:@"Red"]
           && ![key isEqualToString:@"Green"]
           && ![key isEqualToString:@"Blue"]) {
           colorButton.delegate = self;
        }
        
        [colorButton addTarget:self action:@selector(colorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:colorButton];

        index++;
        offsetX += interval + buttonWidth;
        if (index != 0 && index % 4 == 0) {
        offsetX = interval;
        offsetY += interval + buttonWidth;
        }
    }
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, (buttonWidth + 10)*5);
    
}

- (void)colorButtonClick:(ColorButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self selectColorHandle:sender];
}

- (void)selectColorHandle:(ColorButton *)sender
{
    if (self.onSelecteColorBlock) {
        
        UIColor *selColor, *showColor;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([UIColor getColor:[userDefaults objectForKey:sender.text]]) {
            selColor = [UIColor getColor:[userDefaults objectForKey:sender.text]];
        }
        else {
            selColor = [self.colorsDic objectForKey:sender.text];
        }
        
        showColor = sender.backgroundColor;
        
        if ([sender.text isEqualToString:@"Warm Clear"]
            //            || [sender.text isEqualToString:@"Winter White"]
            || [sender.text isEqualToString:@"Red"]
            || [sender.text isEqualToString:@"Green"]
            || [sender.text isEqualToString:@"Blue"]) {
            
            selColor = [self.colorsDic objectForKey:sender.text];
        }
        else if (selColor == [UIColor clearColor]) {
            selColor = nil;
            showColor = nil;
        }
        
        self.onSelecteColorBlock(selColor, showColor, sender.text);
    }
}

#pragma mark - ColorButtonDelegate
- (void)colorButtonLongPressAction:(ColorButton *)sender
{
    UIColor *settingColor;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([UIColor getColor:[userDefaults objectForKey:sender.text]]) {
        settingColor = [UIColor getColor:[userDefaults objectForKey:sender.text]];
    }
    else {
        settingColor = [self.colorsDic objectForKey:sender.text];
    }
    
    
    
    ColorSettingViewController *viewController = [[ColorSettingViewController alloc] initWithColor:sender.backgroundColor withSettingColor:settingColor];
    [self.navigationController pushViewController:viewController animated:YES];
    
    //获取选中的颜色
    viewController.onSelecteColorBlock = ^ (UIColor *selColor, NSString *warmValue) {
//        sender.backgroundColor = selColor;
        
        //将颜色保存到UserDefaults中
        [[NSUserDefaults standardUserDefaults] setObject:[UIColor hexFromUIColor:selColor] forKey:sender.text];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self popToViewControllerClass:[EditThemeViewController class] animated:YES];
        [self selectColorHandle:sender];
    };
}

#pragma mark - Getter
- (NSArray *)colors
{
    if (!_colors) {
        _colors = @[@"╳",
                    @"Warm Clear",
                    @"Champagne",
                    @"Winter White",
                    @"Red",
                    @"Amber",
                    @"Orange",
                    @"Gold",
                    @"Yellow",
                    @"Green",
                    @"Mint",
                    @"Turquoise",
                    @"Aqua",
                    @"Blue",
                    @"Royal",
//                    @"Midnight",
                    @"Purple",
                    @"Violet",
                    @"Pink",
//                    @"Crimson",
                    ];
    }
    return _colors;
}

- (NSDictionary *)colorsDic
{
    if (!_colorsDic) {
        _colorsDic = @{@"╳":[UIColor clearColor],
                       @"Warm Clear":RGBFromColor(0x000000),
                       @"Champagne":OpaqueRGBColor(234, 150, 15),
                       @"Winter White":OpaqueRGBColor(210, 175, 45),
                       @"Red":[UIColor redColor],
                       @"Amber":OpaqueRGBColor(255, 72, 0),
                       @"Orange":OpaqueRGBColor(255, 30, 0),
                       @"Gold":OpaqueRGBColor(255, 92, 0),
                       @"Yellow":OpaqueRGBColor(255, 150, 0),
                       @"Green":[UIColor greenColor],
                       @"Mint":OpaqueRGBColor(46, 139, 10),
                       @"Turquoise":OpaqueRGBColor(64, 224, 35),
                       @"Aqua":OpaqueRGBColor(0, 255, 171),
                       @"Blue":[UIColor blueColor],
                       @"Royal":OpaqueRGBColor(24, 24, 255),
                       @"Midnight":OpaqueRGBColor(42, 42, 104),
                       @"Purple":OpaqueRGBColor(85, 0, 144),
                       @"Violet":OpaqueRGBColor(255, 21, 82),
                       @"Pink":OpaqueRGBColor(255, 21, 28),
                       @"Crimson":OpaqueRGBColor(207, 50, 69),
                       };
//        _colorsDic = @{@"╳":[UIColor clearColor],
//                       @"Warm Clear":RGBFromColor(0x000000),
//                       @"Champagne":OpaqueRGBColor(229, 204, 137),
//                       @"Winter White":OpaqueRGBColor(235, 244, 251),
//                       @"Red":[UIColor redColor],
//                       @"Amber":OpaqueRGBColor(208, 121, 42),
//                       @"Orange":OpaqueRGBColor(247, 169, 58),
//                       @"Gold":OpaqueRGBColor(244, 212, 75),
//                       @"Yellow":OpaqueRGBColor(236, 235, 91),
//                       @"Green":[UIColor greenColor],
//                       @"Sea Green":OpaqueRGBColor(72, 140, 93),
//                       @"Turquoise":OpaqueRGBColor(125, 204, 198),
//                       @"Aqua":OpaqueRGBColor(146, 214, 227),
//                       @"Blue":[UIColor blueColor],
//                       @"Royal":OpaqueRGBColor(59, 87, 150),
//                       @"Midnight":OpaqueRGBColor(42, 42, 104),
//                       @"Purple":OpaqueRGBColor(93, 88, 168),
//                       @"Violet":OpaqueRGBColor(201, 141, 192),
//                       @"Pink":OpaqueRGBColor(196, 107, 171),
//                       @"Crimson":OpaqueRGBColor(207, 50, 69),
//                       };
    }
    return _colorsDic;
}

- (NSDictionary *)showColorsDic
{
    if (!_showColorsDic) {
        _showColorsDic = @{@"╳":[UIColor clearColor],
                       @"Warm Clear":RGBFromColor(0xfefe9c),
                       @"Champagne":OpaqueRGBColor(229, 204, 137),
                       @"Winter White":OpaqueRGBColor(235, 244, 251),
                       @"Red":OpaqueRGBColor(238, 36, 36),
                       @"Amber":OpaqueRGBColor(208, 121, 42),
                       @"Orange":OpaqueRGBColor(247, 169, 58),
                       @"Gold":OpaqueRGBColor(244, 212, 75),
                       @"Yellow":OpaqueRGBColor(236, 235, 91),
                       @"Green":OpaqueRGBColor(83, 189, 117),
                       @"Mint":OpaqueRGBColor(72, 140, 93),
                       @"Turquoise":OpaqueRGBColor(125, 204, 198),
                       @"Aqua":OpaqueRGBColor(146, 214, 227),
                       @"Blue":OpaqueRGBColor(72, 123, 189),
                       @"Royal":OpaqueRGBColor(59, 87, 150),
                       @"Midnight":OpaqueRGBColor(42, 42, 104),
                       @"Purple":OpaqueRGBColor(93, 88, 168),
                       @"Violet":OpaqueRGBColor(201, 141, 192),
                       @"Pink":OpaqueRGBColor(196, 107, 171),
                       @"Crimson":OpaqueRGBColor(207, 50, 69),
                       };
    }
    return _showColorsDic;
}

@end
