//
//  EditThemeViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/19.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "EditThemeViewController.h"
#import "ChannelModel.h"
#import "TextFieldWithBorderView.h"
#import "ColorOptionsViewController.h"
#import "Theme+Fetch.h"
#import "Channel+Fetch.h"
#import "UIColor+extension.h"
#import "DropDownListView.h"
#import "ColorModel.h"
#import "InputHelper.h"
#import "ColorFavorites+Fetch.h"
#import "MyLongPressGestureRecognizer.h"
#import "ColorSelectorViewController.h"
#import "ColorSettingViewController.h"
#import "UIColor+extension.h"

#define CustomColor @"Custom"

@interface EditThemeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *channelArray; //of ChannelModel
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) DropdownListView *popColorView;   //颜色选择
@property (nonatomic, copy) NSString *themeName;

@end

@implementation EditThemeViewController

@synthesize channelArray = _channelArray;

- (NSMutableArray *)channelArray
{
    if (!_channelArray) {
        _channelArray = [[NSMutableArray alloc] init];
        
    }
    return _channelArray;
}

- (void)setTheme:(Theme *)theme
{
    _theme = theme;
    self.navigationItem.title = [NSString stringWithFormat:@"Edit Theme:%@", theme.name];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!_theme) {
        self.navigationItem.title = @"Add Theme";
    }
    
    self.tableView.allowsSelection = NO;
    self.tableView.frame = CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight-NavBarHeight - 55);
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(50, ScreenHeight-50, ScreenWidth-100, 40)];
    saveButton.layer.borderColor = WhiteColor.CGColor;
    saveButton.layer.borderWidth = 1;
    saveButton.titleLabel.font = FontBold(16);
    [saveButton setTitle:@"Save Theme" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveTheme) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tap.numberOfTapsRequired = 1;
    [self.tableView addGestureRecognizer:tap];
    
//    [self loadRightButton:nil title:@"Save"];
    [self LoadChannelsWithTheme];

}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    //同时保存名称
    self.themeName = self.nameTextField.text;
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)LoadChannelsWithTheme
{
    [self.channelArray removeAllObjects];
    
    if (self.theme) {
        NSArray *channels = [Channel getChannelWithTheme:self.theme inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        for (Channel *curChannel in channels) {
            
            ChannelModel *model = [[ChannelModel alloc] init];
            model.index = [curChannel.index integerValue];
            model.name = curChannel.name;
            model.colorName = curChannel.colorName;
            model.color = [UIColor getColor:curChannel.firstColorValue];
            model.subColor = [UIColor getColor:curChannel.secondColorValue];
            model.warmValue = curChannel.warmValue;
            model.subWarmValue = curChannel.subWarmVlaue;
            model.isCustomColor = [curChannel.isCustom boolValue];
            
            model.showColor = [UIColor getColor:curChannel.showColor];
            model.showSubColor = [UIColor getColor:curChannel.showSubColor];
            model.colorType = curChannel.colorType;
            model.subColorType = curChannel.subColorType;
                        
            MyLog(@"firstColorValue:%@", curChannel.firstColorValue);
            MyLog(@"secondColorValue:%@", curChannel.secondColorValue);
            [self.channelArray addObject:model];
        }
        
    } else {
        //创建channel
        for (int i = 1; i < 11; i++) {
            ChannelModel *channel = [[ChannelModel alloc] init];
            channel.name = [NSString stringWithFormat:@"Ch.%d", i];
            channel.index = i;
            channel.isCustomColor = YES;
            [self.channelArray addObject:channel];
        }
    }
}

- (void)btnRightClicked:(UIButton *)sender
{
    MyLog(@"Right Click");
    [self saveTheme];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    return self.channelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }
    
    return 100;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 50; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        view.frame = (CGRect){0, 0, ScreenWidth, 100};
        
        myUILabel *titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 30)];
        titleLabel.text = @"Create a custom color theme";
        titleLabel.textColor = WhiteColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = Font(16);
        [view addSubview:titleLabel];
        
        TextFieldWithBorderView *textFieldView = [[TextFieldWithBorderView alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(titleLabel.frame)+10, ScreenWidth-100, 50)];
        textFieldView.showBorder = YES;
        textFieldView.textField.textAlignment = NSTextAlignmentCenter;
        textFieldView.textField.placeholder = @"Default Theme 1";
        textFieldView.textField.font = Font(16);
        _nameTextField = textFieldView.textField;
        [view addSubview:textFieldView];
        
#ifdef TEST_CLOSE_BLUETOOTH
        if (!self.themeName)
            self.themeName = @"Test Theme";
#endif
        
        if (self.editType == EditType_Modify) {
            _nameTextField.text = self.theme.name;
        } else if (self.themeName) {
            _nameTextField.text = self.themeName;
        }        
        
    } else if (section == 1) {
        view.frame = (CGRect){0, 0, ScreenWidth, 40};
        
        NSInteger LabelWidth = ScreenWidth / 3;
        myUILabel *channelLabel = [[myUILabel alloc] initWithFrame:CGRectMake(50, 0, LabelWidth-50, 40)];
        channelLabel.text = @"CHANNEL";
        channelLabel.textAlignment = NSTextAlignmentLeft;
        channelLabel.verticalAlignment = VerticalAlignmentMiddle;
        channelLabel.textColor = WhiteColor;
        channelLabel.font = FontBold(14);
        [view addSubview:channelLabel];
        
        myUILabel *colorLabel = [[myUILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(channelLabel.frame), 0, LabelWidth, CGRectGetHeight(channelLabel.frame))];
        colorLabel.text = @"COLOR";
        colorLabel.textAlignment = NSTextAlignmentLeft;
        colorLabel.verticalAlignment = VerticalAlignmentMiddle;
        colorLabel.textColor = WhiteColor;
        colorLabel.font = FontBold(14);
        [view addSubview:colorLabel];
        
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier];
    } else {
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    ChannelModel *channel = [self.channelArray objectAtIndex:indexPath.row];
    NSInteger gridWidth = ScreenWidth / 3;
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    cellView.backgroundColor = [UIColor clearColor];
    
    myUILabel *channelName = [[myUILabel alloc] initWithFrame:CGRectMake(50, 0, gridWidth-50, 40)];
    channelName.text = channel.name;
    channelName.verticalAlignment = VerticalAlignmentMiddle;
    channelName.textAlignment = NSTextAlignmentLeft;
    channelName.font = Font(14);
    channelName.textColor = WhiteColor;
    [cellView addSubview:channelName];
    
    MyComBoxView *colorComboxView = [[MyComBoxView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(channelName.frame), 5, gridWidth, 30)];
    colorComboxView.contentText = channel.colorName;
    colorComboxView.clickActionBlock = ^(BOOL isExpand) {
        //弹出主题颜色选择项
        [self tapClick:nil];
        self.themeName = self.nameTextField.text;
        [self showDefaultColor:channel];
    };
    
    [cellView addSubview:colorComboxView];
    
    //color button
    UIButton *colorButton1 = [self createRoundButton:CGRectMake(CGRectGetMaxX(colorComboxView.frame)+10, 5, 30, 30)];
    
//    if ([channel.warmValue isEqualToString:@"0xff"]) {
//        colorButton1.backgroundColor = RGBFromColor(0xfefe9c);
//    } else {
//        colorButton1.backgroundColor = channel.color;
//    }
    
    if ([channel.colorType isEqualToString:@"Warm Clear"]) {
        //Warm Clear
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Warm Clear"]) {
            colorButton1.backgroundColor = [UIColor getColor:[[NSUserDefaults standardUserDefaults] objectForKey:@"Warm Clear"]];
        }
        else {
            colorButton1.backgroundColor = RGBFromColor(0xfefe9c);
        }
    }
    else {
        colorButton1.backgroundColor = channel.showColor;
    }
    
    if (!colorButton1.backgroundColor) {
        [colorButton1 setTitle:@"╳" forState:UIControlStateNormal];
    }
    
    colorButton1.tag = indexPath.row;
    [colorButton1 addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
    
//    MyLongPressGestureRecognizer *longPressColor1 = [[MyLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(firstColorBtnLong:) tag:indexPath.row];
//    longPressColor1.minimumPressDuration = 0.8;
//    [colorButton1 addGestureRecognizer:longPressColor1];

    [cellView addSubview:colorButton1];
    
    UIButton *colorButton2 = [self createRoundButton:CGRectMake(CGRectGetMaxX(colorButton1.frame)+10, 5, 30, 30)];
    colorButton2.tag = indexPath.row;
    [colorButton2 addTarget:self action:@selector(selectSubColor:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!channel.isCustomColor) {
//        colorButton2.enabled = NO;
    } else {
        
        if ([channel.subColorType isEqualToString:@"Warm Clear"]) {
            //Warm Clear
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Warm Clear"]) {
                colorButton2.backgroundColor = [UIColor getColor:[[NSUserDefaults standardUserDefaults] objectForKey:@"Warm Clear"]];
            }
            else {
                colorButton2.backgroundColor = RGBFromColor(0xfefe9c);
            }
        }
//        else if ([channel.subColorType isEqualToString:@"Winter White"]) {
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Winter White"]) {
//                colorButton2.backgroundColor = [UIColor getColor:[[NSUserDefaults standardUserDefaults] objectForKey:@"Winter White"]];
//            }
//            else {
//                colorButton2.backgroundColor = OpaqueRGBColor(235, 244, 251);
//            }
//        }
        else {
            colorButton2.backgroundColor = channel.showSubColor;
        }
//        colorButton2.backgroundColor = channel.subColor;
    }
    
    if (!colorButton2.backgroundColor) {
        [colorButton2 setTitle:@"╳" forState:UIControlStateNormal];
    }
    
//    MyLongPressGestureRecognizer *longPressColor2 = [[MyLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(secondColorBtnLong:) tag:indexPath.row];
//    longPressColor2.minimumPressDuration = 0.8;
//    [colorButton2 addGestureRecognizer:longPressColor2];
    
    [cellView addSubview:colorButton2];
    
    [cell.contentView addSubview:cellView];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)firstColorBtnLong:(MyLongPressGestureRecognizer *)gestureRecognizer
{
    ChannelModel *channel = [self.channelArray objectAtIndex:gestureRecognizer.tag];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // 长按事件
        MyLog(@"channel name :%@", channel.name);
        
        //如果有颜色则删除
        if (channel.color) {
            [self showTipWithMessage:nil withTitle:@"Are you sure to delete this color?" useCancel:YES onOKBlock:^{
                //OK
                channel.color = nil;
                [self.tableView reloadData];
            }];
        } else {
            //跳转至颜色选择
            [self showColorOptionWithChanelIndex:gestureRecognizer.tag isMainColor:YES];
        }
        
    }
}

- (void)secondColorBtnLong:(MyLongPressGestureRecognizer *)gestureRecognizer
{
    ChannelModel *channel = [self.channelArray objectAtIndex:gestureRecognizer.tag];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // 长按事件
        MyLog(@"channel name :%@", channel.name);
        //如果有颜色则删除
        if (channel.subColor) {
            [self showTipWithMessage:nil withTitle:@"Are you sure to delete this color?" useCancel:YES onOKBlock:^{
                //OK
                channel.subColor = nil;
                [self.tableView reloadData];
            }];
        } else {
            //跳转至颜色选择
            [self showColorOptionWithChanelIndex:gestureRecognizer.tag isMainColor:NO];
        }
    }
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

- (void)selectColor:(UIButton *)button
{
    [self showColorOptionWithChanelIndex:button.tag isMainColor:YES];
    
}

- (void)selectSubColor:(UIButton *)button
{
    [self showColorOptionWithChanelIndex:button.tag isMainColor:NO];
 
}

- (void)showColorOptionWithChanelIndex:(NSInteger)index isMainColor:(BOOL)isMainColor
{
    [self tapClick:nil];
    ChannelModel *channel = [self.channelArray objectAtIndex:index];
    MyLog(@"mainColor:%@;\nsubColor:%@.", [UIColor hexFromUIColor:channel.color], [UIColor hexFromUIColor:channel.subColor]);
    
    //跳转至颜色选择，颜色设置
//    UIColor *currentColor;
//    if (isMainColor) {
//        currentColor = channel.color;
//    } else {
//        currentColor = channel.subColor;
//    }
    
//    ColorSettingViewController *viewController = [[ColorSettingViewController alloc] initWithColor:currentColor];
    ColorSelectorViewController *viewController = [[ColorSelectorViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    
    //获取选中的颜色
    viewController.onSelecteColorBlock = ^ (UIColor *selColor, UIColor *showColor, NSString *colorName) {
        if (isMainColor) {
            channel.color = selColor;
            channel.showColor = showColor;
            channel.colorType = colorName;
            if ([colorName isEqualToString:@"Warm Clear"]) {
                channel.warmValue = @"0xff";
            }
            else {
                channel.warmValue = @"0x00";
            }
            
        } else {
            channel.subColor = selColor;
            channel.subColorType = colorName;
            channel.showSubColor = showColor;
            
            if ([colorName isEqualToString:@"Warm Clear"]) {
                channel.subWarmValue = @"0xff";
            }
            else {
                channel.subWarmValue = @"0x00";
            }
        }

        channel.colorName = @"Custom";
        channel.isCustomColor = YES;
        self.themeName = self.nameTextField.text;
        [self.tableView reloadData];
    };
    
//    ColorOptionsViewController *colorOptionsVC = [[ColorOptionsViewController alloc] init];
//    if (isMainColor) {
//        colorOptionsVC.selectedColor = channel.color;
//    } else {
//        colorOptionsVC.selectedColor = channel.subColor;
//    }
//    
//    colorOptionsVC.onSaveColorBlock = ^ (UIColor *selColor) {
//        if (isMainColor) {
//            channel.color = selColor;
//        } else {
//            channel.subColor = selColor;
//        }
//        
//        channel.colorName = @"Custom";
//        channel.isCustomColor = YES;
//        self.themeName = self.nameTextField.text;
//        [self.tableView reloadData];
//    };
//    
//    colorOptionsVC.onSelecteSpecialColorBlock = ^ (UIColor *color, NSString *warmValue) {
//        if (isMainColor) {
//            channel.color = color;
//            channel.warmValue = warmValue;
//        } else {
//            channel.subColor = color;
//            channel.subWarmValue = warmValue;
//        }
//        
//        channel.colorName = @"Custom";
//        channel.isCustomColor = YES;
//        self.themeName = self.nameTextField.text;
//        [self.tableView reloadData];
//    };
//    
//    [self.navigationController pushViewController:colorOptionsVC animated:YES];
}

- (void)saveTheme
{
    if (_nameTextField.text.length == 0) {
        [MBProgressHUD showError:@"Please input Theme Name!"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //将主题保存至数据库
    if (self.editType == EditType_New) {
        //新增
        Theme *newTheme = [Theme addThemeWithName:_nameTextField.text withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        newTheme.isDefualt = [[NSNumber alloc] initWithBool:NO];
        
        //添加通道
        [self updateChannelOfTheme:newTheme];
        
    } else {
        MyLog(@"theme : %@", self.theme);
        Theme *modifyTheme = [Theme getThemeWithWithName:self.theme.name withLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        MyLog(@"theme:%@", modifyTheme);
        modifyTheme.name = _nameTextField.text;
        
        //更新通道数据
        [self updateChannelOfTheme:modifyTheme];
    }
    
    [APPDELEGATE saveContext];
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showSuccess:@"Save Theme Complete."];
}

- (void)updateChannelOfTheme:(Theme *)theme
{
    //删除原来的通道数据
    NSArray *oldChannels = [Channel getChannelWithTheme:theme inManageObjectContext:APPDELEGATE.managedObjectContext];
    for (Channel *delChannel in oldChannels) {
        [Channel removeChannel:delChannel inManageObjectContext:APPDELEGATE.managedObjectContext];
    }
    [APPDELEGATE saveContext];
    
    MyLog(@"theme:%@", theme);
    
    for (ChannelModel *model in self.channelArray) {
        Channel *newChannel = [Channel addChannelWithName:model.name withTheme:theme inManageObjectContext:APPDELEGATE.managedObjectContext];
        
        if (model.subColor)
            MyLog(@"subColor: %@", [UIColor hexFromUIColor:model.subColor]);
        //颜色，名称
        newChannel.index = [[NSNumber alloc] initWithInteger:model.index];
        newChannel.firstColorValue = model.color ? [UIColor hexFromUIColor:model.color] : @"";
        newChannel.secondColorValue = model.subColor ? [UIColor hexFromUIColor:model.subColor] : @"";
        
        newChannel.showColor = model.showColor ? [UIColor hexFromUIColor:model.showColor] : @"";
        newChannel.showSubColor = model.showSubColor ? [UIColor hexFromUIColor:model.showSubColor] : @"";
        
        newChannel.colorType = model.colorType;
        newChannel.subColorType = model.subColorType;
        
        newChannel.warmValue = model.warmValue;
        newChannel.subWarmVlaue = model.subWarmValue;
        newChannel.colorName = model.colorName;
        newChannel.isCustom = [[NSNumber alloc] initWithBool:model.isCustomColor];
        
        MyLog(@"firstColorValue: %@", newChannel.firstColorValue);
        MyLog(@"secondColorValue: %@", newChannel.secondColorValue);

    }
    
    [APPDELEGATE saveContext];
}

- (UIColor *)getColorWithString:(NSString *)colorStr
{
    if (!colorStr || colorStr.length == 0) {
        return [UIColor clearColor];
    }
    
    return [UIColor getColor:colorStr];
}

- (void)showDefaultColor:(ChannelModel *)channelModel
{
    if (!self.popColorView) {
        self.popColorView = [[DropdownListView alloc] init];
    }
    
    //载入默认颜色
//    NSArray *colorTitles = @[@"Red", @"Green", @"Amber", @"Blue", @"Purple", @"Pink", @"Winter White", @"Warm Clear", @"Champagne"];
//    NSArray *colors = @[@{@"color":[UIColor redColor], @"warm":@"0x00"},
//                        @{@"color":[UIColor greenColor], @"warm":@"0x00"},
//                        @{@"color":RGBFromColor(0xFFE4C4), @"warm":@"0x00"},  //Amber
//                        @{@"color":[UIColor blueColor], @"warm":@"0x00"},
//                        @{@"color":RGBFromColor(0x800080), @"warm":@"0x00"},  //Purple
//                        @{@"color":RGBFromColor(0xFFC0CB), @"warm":@"0x00"},  //Pink
//                        @{@"color":RGBFromColor(0xFFFFFF), @"warm":@"0x00"},  //Winter White
//                        @{@"color":RGBFromColor(0x000000), @"warm":@"0xff"},  //Warm Clear
//                        @{@"color":RGBFromColor(0xB8860B), @"warm":@"0x00"},  //Champagne
//                        ];
    NSArray *colors = [self getColorFromDataBase];
    NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
    NSMutableArray *colorTitles = [[NSMutableArray alloc] init];
    for (ColorFavorites *colorFav in colors) {
        if ([colorFav.isCustom boolValue])
            continue;
        [colorsArray addObject:colorFav];
        [colorTitles addObject:colorFav.name];
    }
//    [colorTitles addObject:CustomColor];
    
    __weak typeof(self) weakSelf = self;
    self.popColorView.dataArray = [colorTitles copy];
    self.popColorView.didSelectedActionBlock = ^(NSInteger index) {
        
//        MyLog(@"selected Color : %@", [colors objectAtIndex:index]);
        NSString *colorName = [colorTitles objectAtIndex:index];
        channelModel.colorName = colorName;
        if (![colorName isEqualToString:CustomColor]) {
            ColorFavorites *colorFav = [colorsArray objectAtIndex:index];
            channelModel.color = [UIColor getColor:colorFav.color];
            channelModel.subColor = nil;
            channelModel.warmValue = colorFav.warm;
            channelModel.subWarmValue = nil;
            channelModel.isCustomColor = [colorFav.isCustom boolValue];
            
        } else {
            //custom color
            channelModel.isCustomColor = YES;
        }
        
        [weakSelf.tableView reloadData];
    };
    
    [self.popColorView showAtCenter];
}

- (NSArray *)getColorFromDataBase
{
    ColorFavorites *colorFav = [ColorFavorites getObjectWithName:@"Red" inManagedObjectContext:APPDELEGATE.managedObjectContext];
    if (!colorFav) {
        //add dafualt color
//        NSArray *colorTitles = @[@"Red", @"Green", @"Amber", @"Blue", @"Purple", @"Pink", @"Winter White", @"Warm Clear", @"Champagne"];
        
        NSArray *colors = @[@{@"name":@"Red", @"color":[UIColor redColor], @"showColor":[UIColor redColor], @"warm":@"0x00"},
                            @{@"name":@"Green", @"color":[UIColor greenColor], @"showColor":[UIColor greenColor], @"warm":@"0x00"},
                            @{@"name":@"Amber", @"color":RGBFromColor(0xFFE4C4), @"showColor":RGBFromColor(0xFFE4C4), @"warm":@"0x00"},  //Amber
                            @{@"name":@"Blue", @"color":[UIColor blueColor], @"showColor":[UIColor blueColor], @"warm":@"0x00"},
                            @{@"name":@"Purple", @"color":RGBFromColor(0x800080), @"showColor":RGBFromColor(0x800080), @"warm":@"0x00"},  //Purple
                            @{@"name":@"Pink", @"color":RGBFromColor(0xFFC0CB), @"showColor":RGBFromColor(0xFFC0CB), @"warm":@"0x00"},  //Pink
                            @{@"name":@"Winter White", @"color":RGBFromColor(0xFFFFFF), @"showColor":RGBFromColor(0xFFFFFF), @"warm":@"0x00"},  //Winter White
                            @{@"name":@"Warm Clear", @"color":RGBFromColor(0x000000), @"showColor":RGBFromColor(0xfefe9c), @"warm":@"0xff"},  //Warm Clear
                            @{@"name":@"Champagne", @"color":RGBFromColor(0xB8860B), @"showColor":RGBFromColor(0xB8860B), @"warm":@"0x00"},  //Champagne
                            ];
        for (NSDictionary *dic in colors) {
            NSString *name = [dic objectForKey:@"name"];
            UIColor *color = [dic objectForKey:@"color"];
            NSString *warmValue = [dic objectForKey:@"warm"];
            
            ColorFavorites *newColor = [ColorFavorites addObject:name inManagedObjectContext:APPDELEGATE.managedObjectContext];
            newColor.color = [UIColor hexFromUIColor:color];
            newColor.warm = warmValue;
            newColor.isCustom = [[NSNumber alloc] initWithBool:NO];
        }
        [APPDELEGATE saveContext];
    }
    
    NSArray *colorsArray = [ColorFavorites fetchObjectsInManagedObjectContext:APPDELEGATE.managedObjectContext];
    return colorsArray;
}


@end
