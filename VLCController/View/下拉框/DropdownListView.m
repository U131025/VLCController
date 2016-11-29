//
//  DropdownListView.m
//  iTotemMinFramework
//
//  Created by mojingyu on 16/1/25.
//
//

#import "DropdownListView.h"

@interface DropdownListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger lastCurrentRow;
@property (nonatomic, strong) NSString *strSchoolStage;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation DropdownListView

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)setShowFrame:(CGRect)showFrame
{
    _tableView.frame = showFrame;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.frame = (CGRect){0, 0, ScreenWidth, ScreenHeight};
        //backgroundView
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
//        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.backgroundColor = RGBAlphaColor(0, 0, 0, 0.6);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singelTapAction:)];
        tap.numberOfTapsRequired = 1;
        [_backgroundView addGestureRecognizer:tap];
        [self addSubview:_backgroundView];

        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _tableView.layer.borderWidth = 1;
//        _tableView.layer.cornerRadius = 5;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defualtCell"];
        [self addSubview:_tableView];
        
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.backgroundColor = WhiteColor;
        _cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _cancelButton.layer.borderWidth = 1;
        [_cancelButton setTitleColor:BlackColor forState:UIControlStateNormal];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        _selectButton = [[UIButton alloc] init];
        _selectButton.backgroundColor = WhiteColor;
        _selectButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _selectButton.layer.borderWidth = 1;
        [_selectButton setTitle:@"Select" forState:UIControlStateNormal];
        [_selectButton setTitleColor:BlackColor forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(selectAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectButton];
    }
    
    return self;
}

- (void)cancelAction
{
    [self removeFromSuperview];
}

- (void)selectAction
{
    [self removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedAction:)]) {
        [self.delegate didSelectedAction:_tableView.indexPathForSelectedRow.row];
    }
    
    if (_didSelectedActionBlock) {
        _didSelectedActionBlock(_tableView.indexPathForSelectedRow.row);
    }
}

- (void)singelTapAction:(UITapGestureRecognizer *)tap
{
    [self removeFromSuperview];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.titleText) {
        return 60;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 60)];
    titleView.backgroundColor = WhiteColor;
    myUILabel *titleLabel = [[myUILabel alloc] initWithFrame:titleView.frame];
    titleLabel.text = self.titleText;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = FontBold(18);
    titleLabel.textColor = BlackColor;
    titleLabel.numberOfLines = 0;
    [titleView addSubview:titleLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame)-1, ScreenWidth, 1)];
    lineLabel.backgroundColor = [UIColor lightGrayColor];
    [titleView addSubview:lineLabel];
    
    return titleView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"defualtCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    } else {
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
    }

    cell.textLabel.text = _dataArray[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self removeFromSuperview];
//    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedAction:)]) {
//        [self.delegate didSelectedAction:indexPath.row];
//    }
//        
//    if (_didSelectedActionBlock) {
//        _didSelectedActionBlock(indexPath.row);
//    }
}

#pragma mark Show
- (void)show
{
    if (_dataArray.count == 0) {
        return;
    }
    _backgroundView.hidden = NO;
    _tableView.hidden = NO;
    [_tableView reloadData];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;    
    [window addSubview:self];
}

- (void)showAtPoint:(CGPoint)point inWidth:(CGFloat)width
{
    CGFloat dropDownHeight = 43;
    if (_dataArray.count < 6) {
        dropDownHeight = 43*_dataArray.count;
    } else {
        dropDownHeight = 43*5;
    }
    
    if (self.titleText) {
        dropDownHeight += 60;
    }

    _tableView.frame = (CGRect){point.x, point.y, width, dropDownHeight};
    [self show];
}

- (void)showAtCenter
{
    CGFloat dropDownHeight = 43;
    if (_dataArray.count < 6) {
        dropDownHeight = 43*_dataArray.count;
    } else {
        dropDownHeight = 43*5;
    }
    
    if (self.titleText) {
        dropDownHeight += 60;
    }
    
    _tableView.width = ScreenWidth - 100;
    _tableView.height = dropDownHeight;
    _tableView.center = self.center;
    
    //添加按钮
    _cancelButton.frame = (CGRect){CGRectGetMinX(_tableView.frame), CGRectGetMaxY(_tableView.frame), CGRectGetWidth(_tableView.frame)/2, 50};
    
    _selectButton.frame = (CGRect){CGRectGetMaxX(_cancelButton.frame), CGRectGetMaxY(_tableView.frame), CGRectGetWidth(_tableView.frame)/2, 50};
    
//    _tableView.frame = (CGRect){point.x, point.y, width, dropDownHeight};
    [self show];
}
@end
