//
//  DropDownListView.m
//  VLCController
//
//  Created by mojingyu on 16/1/15.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "DropDownListView.h"

@interface DropDownListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *dropDownTableView;
@property (nonatomic, strong) NSMutableArray *dropDownListDataArray;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, assign) BOOL isExpand;
@end

@implementation DropDownListView

- (id)init
{
    self = [super init];
    if (self) {
        _rowHeight = 42;
        _minShowRowCount = 1;
        _maxShowRowCount = 5;
        
        self.frame = (CGRect){0, 0, ScreenWidth, ScreenHeight};
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundAction)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)initBackgroundButton
{
    _backgroundButton = [[UIButton alloc] initWithFrame:self.frame];
    [_backgroundButton addTarget:self action:@selector(tapBackgroundAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backgroundButton];
}

- (void)tapBackgroundAction
{
    [self removeDropListView];
}

- (void)removeDropListView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _dropDownTableView.frame;
        frame.size.height = 1;
        [_dropDownTableView setFrame:frame];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (NSMutableArray *)dropDownListDataArray
{
    if (!_dropDownListDataArray) {
        _dropDownListDataArray = [[NSMutableArray alloc] init];
    }
    return _dropDownListDataArray;
}

- (void)showDropListaWithData:(NSArray *)listData
{
    CGRect frame = [self calculationViewFrame];
    
    if (!_dropDownTableView) {
        _dropDownTableView = [[UITableView alloc] initWithFrame:(CGRect){frame.origin, frame.size.width, 1}];
        _dropDownTableView.dataSource = self;
        _dropDownTableView.delegate = self;
        _dropDownTableView.layer.borderColor = [UIColor blackColor].CGColor;
        _dropDownTableView.layer.borderWidth = 1;
        [_dropDownTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"dropDownCell"];
    } else {
        [_dropDownTableView removeFromSuperview];
        _dropDownTableView.frame = (CGRect){frame.origin, frame.size.width, 1};
        [_dropDownTableView reloadData];
    }
    
    [self addSubview:_dropDownTableView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [_dropDownTableView setFrame:frame];
        
    }];
}

- (CGRect)calculationViewFrame
{
    CGFloat dropDownHeight = _rowHeight;
    if (_dropDownListDataArray.count <= _maxShowRowCount) {
        dropDownHeight = _rowHeight*_dropDownListDataArray.count;
    } else {
        dropDownHeight = _rowHeight*_maxShowRowCount;
    }
    
//    CGRect cellRect = [_dropDownTableView rectForSection:button.tag];
    CGRect frame = (CGRect){_pt, _width, dropDownHeight};
    return frame;
}

#pragma mark UITabelViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dropDownListDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropDownCell"];
    if (cell) {
        //
        LightControllerModel *light = [_dropDownListDataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = light.name;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LightControllerModel *light = [_dropDownListDataArray objectAtIndex:indexPath.row];
    if (_selectActionBlock) {
        _selectActionBlock(light);
    }
    
    [self removeDropListView];
}
@end
