//
//  ManageThemeViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/19.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ManageThemeViewController.h"
#import "Theme+Fetch.h"
#import "EditThemeViewController.h"

@interface ManageThemeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *themeArray;   // of ThemeModel
@property (nonatomic, strong) UIButton *addThemeButton;
@end

@implementation ManageThemeViewController

- (NSMutableArray *)themeArray
{
    if (!_themeArray) {
        _themeArray = [[NSMutableArray alloc] init];
    }
    return _themeArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Manage Themes";
//    self.tableView.frame = (CGRect){0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight};
    [self.tableView registerClass:[TextTableViewCell class] forCellReuseIdentifier:TextCellIdentifer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadThemesFromDataBase];
}

- (void)loadThemesFromDataBase
{    
    NSArray *themesArray = [Theme fetchThemesWithLightController:self.light inManageObjectContext:APPDELEGATE.managedObjectContext];
    if (themesArray) {
        [self.themeArray removeAllObjects];
        for (Theme *theme in themesArray) {
            if (![theme.isDefualt boolValue]) {
                [self.themeArray addObject:theme];
            }
        }
//        _themeArray = [themesArray copy];
        [self.tableView reloadData];
    }
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
        return self.themeArray.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// 滑动删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
//    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //删除主题
        Theme *deleteTheme = [self.themeArray objectAtIndex:indexPath.row];
        if (deleteTheme) {
            [Theme removeTheme:deleteTheme inManageObjectContext:APPDELEGATE.managedObjectContext];
            [self loadThemesFromDataBase];
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        Theme *theme = [self.themeArray objectAtIndex:indexPath.row];
        
        TextTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifer];
        textCell.titleText = theme.name;
        textCell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell = textCell;
        
        if (indexPath.row != (self.themeArray.count - 1)) {
            textCell.isBottomLine = YES;
        }
        
    } else if (indexPath.section == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];        
        
        if (!_addThemeButton) {
            _addThemeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
            _addThemeButton.backgroundColor = RGBAlphaColor(255, 255, 255, 0.6);
            
            [_addThemeButton setTitle:@"Add New Theme+" forState:UIControlStateNormal];
            [_addThemeButton setTitleColor:WhiteColor forState:UIControlStateNormal];
            [_addThemeButton addTarget:self action:@selector(addNewThemeAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell.contentView addSubview:_addThemeButton];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Theme *theme = [self.themeArray objectAtIndex:indexPath.row];
        
        //Edit Theme
        EditThemeViewController *editThemeVC = [[EditThemeViewController alloc] init];
        editThemeVC.editType = EditType_Modify;
        editThemeVC.light = self.light;
        editThemeVC.theme = theme;
        [self.navigationController pushViewController:editThemeVC animated:YES];
    }
    
}

- (void)addNewThemeAction:(UIButton *)button
{
    //New Theme
    EditThemeViewController *editThemeVC = [[EditThemeViewController alloc] init];
    editThemeVC.editType = EditType_New;
    editThemeVC.light = self.light;
    [self.navigationController pushViewController:editThemeVC animated:YES];
}


@end
