//
//  ColorOptionsViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/27.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ColorOptionsViewController.h"
#import "KZColorPickerHSWheel.h"
#import "UIColor+extension.h"
#import "ColorFavorites+Fetch.h"

@interface ColorOptionsViewController ()
@property (nonatomic, retain) KZColorPickerHSWheel *colorWheel;
@property (nonatomic, strong) UIButton *colorPreviewButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *colorsScrollView;
@property (nonatomic, strong) UILabel *favoriteTitle;
@property (nonatomic, strong) UIButton *favoriteColorButton;
@property (nonatomic, copy) NSArray *quickColors;

@end

@implementation ColorOptionsViewController

@synthesize selectedColor;
@synthesize quickColors = _quickColors;

- (NSArray *)quickColors
{
    if (!_quickColors) {
        _quickColors = @[@{@"name":@"RED", @"value":[UIColor redColor]},
                         @{@"name":@"AMBER", @"value":AmberColor},
                         @{@"name":@"YELLOW", @"value":[UIColor yellowColor]},
                         @{@"name":@"GREEN", @"value":[UIColor greenColor]},
                         @{@"name":@"BLUE", @"value":[UIColor blueColor]},
                         @{@"name":@"PURPLE", @"value":[UIColor purpleColor]}];
    }
    return _quickColors;
}

- (void)viewDidLoad {
    self.useDefaultTableView = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backgroundImageView.image = [UIImage imageNamed:@"backgroundNoIcon"];
    self.navigationItem.title = @"Color Options";
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NavBarHeight+5, ScreenWidth, ScreenHeight-NavBarHeight-10)];
    [self.view addSubview:_scrollView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    titleLabel.text = @"Select a color to preview.";
    titleLabel.textColor = WhiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = Font(16);
    [_scrollView addSubview:titleLabel];
    
    // HS wheel
    KZColorPickerHSWheel *wheel = [[KZColorPickerHSWheel alloc] initAtOrigin:CGPointMake((ScreenWidth-240)/2, CGRectGetMaxY(titleLabel.frame))];
    [wheel addTarget:self action:@selector(colorWheelColorChanged:) forControlEvents:UIControlEventValueChanged];
    [_scrollView addSubview:wheel];
    self.colorWheel = wheel;
    [self setWheelColor:self.selectedColor];
    
    _colorPreviewButton = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(wheel.frame)-20, 80, 80)];
    _colorPreviewButton.layer.borderColor = WhiteColor.CGColor;
    _colorPreviewButton.layer.borderWidth = 2;
    _colorPreviewButton.layer.cornerRadius = 40;
    [_colorPreviewButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    [self colorWheelColorChanged:wheel];
    [_scrollView addSubview:_colorPreviewButton];
    
    //warm clean颜色按钮
    UIButton *warmclearButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_colorWheel.frame)-70, 70, 70)];
    warmclearButton.layer.borderColor = WhiteColor.CGColor;
    warmclearButton.layer.borderWidth = 1;
    warmclearButton.layer.cornerRadius = 35;
    warmclearButton.backgroundColor = RGBFromColor(0xfefe9c);
    warmclearButton.titleLabel.font = Font(10);
    warmclearButton.titleLabel.numberOfLines = 2;
    [warmclearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [warmclearButton setTitle:@"Warm Clear" forState:UIControlStateNormal];
    [warmclearButton addTarget:self action:@selector(warmclearAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:warmclearButton];
    
//    UILabel *warmclearLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(warmclearButton.frame), CGRectGetMaxY(warmclearButton.frame), CGRectGetWidth(warmclearButton.frame), 10)];
//    warmclearLabel.font = Font(10);
//    warmclearLabel.text = @"warm clear";
//    warmclearLabel.textAlignment = NSTextAlignmentCenter;
//    warmclearLabel.textColor = WhiteColor;
//    [_scrollView addSubview:warmclearLabel];
    
    //warm white
    UIButton *warmwhiteButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-90, CGRectGetMinY(warmclearButton.frame), 70, 70)];
    warmwhiteButton.layer.borderColor = WhiteColor.CGColor;
    warmwhiteButton.layer.borderWidth = 1;
    warmwhiteButton.layer.cornerRadius = 35;
    warmwhiteButton.backgroundColor = RGBFromColor(0xFFFFFF);
    warmwhiteButton.titleLabel.font = Font(10);
    warmwhiteButton.titleLabel.numberOfLines = 2;
    [warmwhiteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [warmwhiteButton setTitle:@"Winter White" forState:UIControlStateNormal];
    [warmwhiteButton addTarget:self action:@selector(warmwhiteAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:warmwhiteButton];
    
//    UILabel *warmwhiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(warmwhiteButton.frame), CGRectGetMaxY(warmwhiteButton.frame), CGRectGetWidth(warmwhiteButton.frame), 10)];
//    warmwhiteLabel.font = Font(10);
//    warmwhiteLabel.text = @"warm white";
//    warmclearLabel.textAlignment = NSTextAlignmentCenter;
//    warmwhiteLabel.textColor = WhiteColor;
//    [_scrollView addSubview:warmwhiteLabel];
    
    //
    UIButton *selectedColorButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_colorWheel.frame)+10, ScreenWidth-100, 45)];
    [selectedColorButton setTitle:@"Select Color" forState:UIControlStateNormal];
    [selectedColorButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    selectedColorButton.layer.borderWidth = 1;
    selectedColorButton.layer.borderColor = WhiteColor.CGColor;
    selectedColorButton.titleLabel.font = Font(16);
    [selectedColorButton addTarget:self action:@selector(selectedColorAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:selectedColorButton];
    
    //favorites
    UIButton *favoritesButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(selectedColorButton.frame)+5, ScreenWidth-100, 45)];
    [favoritesButton setTitle:@"Save Color to Favorites+" forState:UIControlStateNormal];
    [favoritesButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    favoritesButton.layer.borderWidth = 1;
    favoritesButton.layer.borderColor = WhiteColor.CGColor;
    favoritesButton.titleLabel.font = Font(16);
    [favoritesButton addTarget:self action:@selector(favoritesAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:favoritesButton];
    
    //delete
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(favoritesButton.frame)+5, ScreenWidth-100, 45)];
    [deleteButton setTitle:@"Delete Color" forState:UIControlStateNormal];
    [deleteButton setTitleColor:WhiteColor forState:UIControlStateNormal];
    deleteButton.layer.borderWidth = 1;
    deleteButton.layer.borderColor = WhiteColor.CGColor;
    deleteButton.titleLabel.font = Font(16);
    [deleteButton addTarget:self action:@selector(deleteColorAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:deleteButton];
    
    //quick selected colors
    UILabel *quickColorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(deleteButton.frame)+5, ScreenWidth, 30)];
    quickColorsLabel.text = @"QUICK SELECT COLORS";
    quickColorsLabel.textColor = WhiteColor;
    quickColorsLabel.textAlignment = NSTextAlignmentCenter;
    quickColorsLabel.font = FontBold(16);
    [_scrollView addSubview:quickColorsLabel];
    
    UIScrollView *quickColorsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(45, CGRectGetMaxY(quickColorsLabel.frame), ScreenWidth-90, 40)];
    quickColorsScrollView.showsHorizontalScrollIndicator = NO;
    
    // load datas
    CGFloat offsetX = 5;
    for (int i = 0; i < self.quickColors.count; i++) {
        NSDictionary *dic = [self.quickColors objectAtIndex:i];
        if (dic) {
            //添加到scrollView 中
            UIButton *newColorButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 0, 40, 40)];
            newColorButton.layer.borderColor = WhiteColor.CGColor;
            newColorButton.layer.borderWidth = 1;
            newColorButton.layer.cornerRadius = 20;
            newColorButton.tag = i;
            newColorButton.backgroundColor = [dic objectForKey:@"value"];
            [newColorButton setTitle:[dic objectForKey:@"name"] forState:UIControlStateNormal];
            [newColorButton setTitleColor:WhiteColor forState:UIControlStateNormal];
            newColorButton.titleLabel.font = FontBold(9);
            [newColorButton addTarget:self action:@selector(selectQuickColor:) forControlEvents:UIControlEventTouchUpInside];
            
            [quickColorsScrollView addSubview:newColorButton];
            
            offsetX += 45;
        }
    }
    quickColorsScrollView.contentSize = CGSizeMake(offsetX, 45);
    [_scrollView addSubview:quickColorsScrollView];
    
    //favoriter colors
    //
    _favoriteTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(quickColorsScrollView.frame)+5, ScreenWidth, 30)];
    _favoriteTitle.text = @"FAVORITE COLORS";
    _favoriteTitle.textColor = WhiteColor;
    _favoriteTitle.textAlignment = NSTextAlignmentCenter;
    _favoriteTitle.font = FontBold(16);
    [_scrollView addSubview:_favoriteTitle];
    
    //
    _colorsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(45, CGRectGetMaxY(_favoriteTitle.frame), ScreenWidth-90, 55)];
    _colorsScrollView.showsHorizontalScrollIndicator = NO;
    [_scrollView addSubview:_colorsScrollView];
    
    [self reloadFavoriteColors];
}

- (void)selectQuickColor:(UIButton *)button
{
    NSInteger index = button.tag;
    self.selectedColor = [[self.quickColors objectAtIndex:index] objectForKey:@"value"];
    
    _colorPreviewButton.backgroundColor = self.selectedColor;
    [_colorPreviewButton setTitle:[NSString stringWithFormat:@"#%@", [UIColor hexFromUIColor:self.selectedColor]] forState:UIControlStateNormal];
    [self selectedColorAction];
}

- (void)reloadFavoriteColors
{
    for (UIView *subView in _colorsScrollView.subviews) {
        [subView removeFromSuperview];
    }    
    
    NSArray *favoriteColors = [ColorFavorites fetchObjectsInManagedObjectContext:APPDELEGATE.managedObjectContext];
    if (favoriteColors.count > 0) {
        [_favoriteTitle setHidden:NO];
        CGFloat offsetX = 5;
        for (int i = 0; i < favoriteColors.count; i++) {
            ColorFavorites *favoriteColor = [favoriteColors objectAtIndex:i];
            if ([favoriteColor.isCustom boolValue]) {
                //添加到scrollView 中
                UIButton *newColorButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 5, 46, 46)];
                newColorButton.layer.borderColor = WhiteColor.CGColor;
                newColorButton.layer.borderWidth = 1;
                newColorButton.layer.cornerRadius = 23;
                newColorButton.tag = i;
                newColorButton.backgroundColor = [UIColor getColor:favoriteColor.color];
                [newColorButton setTitle:[NSString stringWithFormat:@"#%@", favoriteColor.color] forState:UIControlStateNormal];
                [newColorButton setTitleColor:WhiteColor forState:UIControlStateNormal];
                newColorButton.titleLabel.font = FontBold(9);
                [newColorButton addTarget:self action:@selector(favoriteColorSelect:) forControlEvents:UIControlEventTouchUpInside];
                
                [_colorsScrollView addSubview:newColorButton];
                
                
                offsetX += 50;
            }
        }
        _colorsScrollView.contentSize = CGSizeMake(offsetX, 60);
        
        _scrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(_colorsScrollView.frame) + 10);
    } else {
        [_favoriteTitle setHidden:YES];
    }
    
    [_colorsScrollView setNeedsDisplay];
}

- (void)favoriteColorSelect:(UIButton *)button
{
    NSArray *favoriteColors = [ColorFavorites fetchObjectsInManagedObjectContext:APPDELEGATE.managedObjectContext];
    ColorFavorites *favoriteColor = [favoriteColors objectAtIndex:button.tag];
    
    self.selectedColor = [UIColor getColor:favoriteColor.color];
    [self selectFavoriteColorButton:button];
//    [self selectedColorAction];
}

- (void)selectFavoriteColorButton:(UIButton *)button
{
    
    if (self.favoriteColorButton) {
        CGRect bigFrame = _favoriteColorButton.frame;
        _favoriteColorButton.frame = (CGRect){bigFrame.origin.x+3, bigFrame.origin.y+3, 46, 46};
        _favoriteColorButton.layer.cornerRadius = 23;
    }
    
    if (![self.favoriteColorButton isEqual:button]) {
        self.favoriteColorButton = button;
        CGRect smallFrame = _favoriteColorButton.frame;
        _favoriteColorButton.frame = (CGRect){smallFrame.origin.x-3, smallFrame.origin.y-3, 52, 52};
        _favoriteColorButton.layer.cornerRadius = 26;
    } else {
        self.favoriteColorButton = nil;
    }
    
}

- (void) colorWheelColorChanged:(KZColorPickerHSWheel *)wheel
{
    HSVType hsv = wheel.currentHSV;
    UIColor * selColor = [UIColor colorWithHue:hsv.h saturation:hsv.s brightness:1.0f alpha:1.0f];
    self.selectedColor = selColor;
    _colorPreviewButton.backgroundColor = selColor;
    [_colorPreviewButton setTitle:[NSString stringWithFormat:@"#%@", [UIColor hexFromUIColor:selColor]] forState:UIControlStateNormal];
}

- (void)selectedColorAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    //调用蓝牙接口，提交颜色并保存
    if (self.onSaveColorBlock) {
        self.onSaveColorBlock(self.selectedColor);
    }
}

- (void)favoritesAction
{
    //将颜色保存到数据库中
    if (self.selectedColor) {
        NSString *colorName = [NSString stringWithFormat:@"#%@", [UIColor hexFromUIColor:self.selectedColor]];
        ColorFavorites *colorFavorites = [ColorFavorites addObject:colorName inManagedObjectContext:APPDELEGATE.managedObjectContext];
        colorFavorites.color = [UIColor hexFromUIColor:self.selectedColor];
        colorFavorites.isCustom = [[NSNumber alloc] initWithBool:YES];
        [APPDELEGATE saveContext];
        [MBProgressHUD showSuccess:@"Save Success!"];
    }
    
    [self reloadFavoriteColors];
}

- (void)deleteColorAction
{
    if (self.favoriteColorButton) {
        //删除该颜色
        NSString *name = self.favoriteColorButton.titleLabel.text;
        ColorFavorites *colorFavorites = [ColorFavorites getObjectWithName:name inManagedObjectContext:APPDELEGATE.managedObjectContext];
        if (colorFavorites) {
            [ColorFavorites removeObject:colorFavorites inManagedObjectContext:APPDELEGATE.managedObjectContext];
        }
        [APPDELEGATE saveContext];
        [self reloadFavoriteColors];
        
    } else {
        self.selectedColor = nil;
        [self selectedColorAction];
    }
    
}

//- (void)setSelectedColor:(UIColor *)selectedColor
//{
//    if (!_selectedColor) {
//        _selectedColor = [[UIColor alloc] init];
//    }
//    
//    self.selectedColor = selectedColor;
//    if (selectedColor) {
//        [self setWheelColor:selectedColor];
//    }
//}

- (void)setWheelColor:(UIColor *)color
{
    if (color) {
        if (_colorWheel) {
            _colorWheel.currentColor = color;
            [_colorWheel setNeedsDisplay];
        }
        
//        CGFloat redValue = [UIColor redValueFromUIColor:color];
//        CGFloat greenValue = [UIColor greenValueFromUIColor:color];
//        CGFloat blueValue = [UIColor blueValueFromUIColor:color];
//        
//        
//        RGBType rgb = RGBTypeMake(redValue, greenValue, blueValue);
//        
//        if (_colorWheel) {
//            _colorWheel.currentHSV = RGB_to_HSV(rgb);
//            [_colorWheel setNeedsDisplay];
//        }
    }
}

- (void)setWeelColor:(NSString *)colorStr
{
    UIColor *color = [UIColor getColor:colorStr];
    [self setWheelColor:color];
}

- (void)warmclearAction
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.onSelecteSpecialColorBlock) {
        self.onSelecteSpecialColorBlock(RGBFromColor(0x000000), @"0xff");
    }
}

- (void)warmwhiteAction
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.onSelecteSpecialColorBlock) {
        self.onSelecteSpecialColorBlock(RGBFromColor(0xFFFFFF), @"0x00");
    }
}

@end
