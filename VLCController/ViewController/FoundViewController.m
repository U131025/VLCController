//
//  FoundViewController.m
//  VLCController
//
//  Created by mojingyu on 16/1/21.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "FoundViewController.h"
#import "MyComBoxView.h"
#import "TextFieldWithBorderView.h"

#define CellHeight (ScreenHeight / 3)
//#define CellHeight 200

@interface FoundViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) MyComBoxView *controllerCombox;
@property (nonatomic, strong) UIButton *selectControllerButton;

@property (nonatomic, strong) NSMutableArray *dropDownListDataArray;
@property (nonatomic, strong) UITableView *dropDownTableView;   //下拉列表
@property (nonatomic, weak) LightControllerModel *selectedLightController;
@property (nonatomic, assign) NSInteger selectedLightControllerIndex;

@end

@implementation FoundViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.selectedLightControllerIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Found Controller";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tap.numberOfTapsRequired = 1;
    [self.tableView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (NSMutableArray *)dropDownListDataArray
{
    if (!_dropDownListDataArray) {
        _dropDownListDataArray = [[NSMutableArray alloc] init];
    }
    return _dropDownListDataArray;
}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    [self.dropDownTableView removeFromSuperview];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)loadBackBtn
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    btn.contentHorizontalAlignment = 1;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
    [self.navigationItem setLeftBarButtonItem:buttonItem animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:_dropDownTableView]) {
        return 1;
    }
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_dropDownTableView]) {
        return self.dropDownListDataArray.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:_dropDownTableView]) {
        return 1;
    }
    
    return CellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_dropDownTableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropDownCell"];
        if (cell) {
            //
            LightControllerModel *model = [_dropDownListDataArray objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = model.deviceName ? model.deviceName : @"Unnamed";
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_dropDownTableView]) {
        //
        _selectedLightControllerIndex = indexPath.row;
        LightControllerModel *model = [_dropDownListDataArray objectAtIndex:indexPath.row];
        _selectedLightController = model;
        
        [_selectControllerButton setTitle:model.deviceName forState:UIControlStateNormal];
        [_dropDownTableView removeFromSuperview];
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_dropDownTableView]) {
        return 50;
    }
    
    return 42;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CellHeight)];
    cellView.backgroundColor = [UIColor clearColor];
    
    if (!_selectedLightController) {
        _selectedLightController = [_dropDownListDataArray objectAtIndex:0];
        _selectedLightControllerIndex = 0;
    }    
    NSString *name = _selectedLightController.deviceName;
    
    if (name) {
        [_selectControllerButton setTitle:name forState:UIControlStateNormal];
    }
    
    if (section == 0 ) {
        
        CGFloat rowHeight = CellHeight / 3;
        myUILabel *topLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, rowHeight)];
        topLabel.verticalAlignment = VerticalAlignmentBottom;
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.textColor = WhiteColor;
        topLabel.font = Font(23);
        [cellView addSubview:topLabel];
        
        if ([BluetoothManager sharedInstance].device.count > 0) {
            topLabel.text = @"Multiple Controllers Found!";
            
            //下拉菜单
            myUILabel *midLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLabel.frame), ScreenWidth, rowHeight)];
            midLabel.text = @"Please select a controller below to continue.";
            midLabel.verticalAlignment = VerticalAlignmentMiddle;
            midLabel.textAlignment = NSTextAlignmentCenter;
            midLabel.textColor = WhiteColor;
            midLabel.font = Font(13);
            [cellView addSubview:midLabel];
            
            UIButton *selectControllerButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(midLabel.frame)+10, ScreenWidth-100, 60)];
            selectControllerButton.layer.borderColor = WhiteColor.CGColor;
            selectControllerButton.layer.borderWidth = 1;
            
            if (name) {
                [selectControllerButton setTitle:name forState:UIControlStateNormal];
            }
            [selectControllerButton setTitleColor:WhiteColor forState:UIControlStateNormal];
            [selectControllerButton addTarget:self action:@selector(dropButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            _selectControllerButton = selectControllerButton;
            [cellView addSubview:selectControllerButton];
            
            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selectControllerButton.frame)-40, CGRectGetMaxY(selectControllerButton.frame)-CGRectGetHeight(selectControllerButton.frame)/2 - 15, 30, 30)];
            arrowImageView.image = [UIImage imageNamed:@"downArrow"];
            [cellView addSubview:arrowImageView];

        } else {
            topLabel.text = @"Controller Found!";
            topLabel.frame = (CGRect){0, 0, ScreenWidth, CellHeight};
        }
        
    } else if (section == 1) {
        
        TextFieldWithBorderView *textView = [[TextFieldWithBorderView alloc] initWithFrame:CGRectMake(50, CellHeight/2 - 30, ScreenWidth-100, 60)];

        textView.textField.text = name;
        textView.textField.placeholder = @"Example Controller Name";
//        textView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Example Controller Name" attributes:@{NSForegroundColorAttributeName:RGBAlphaColor(255, 255, 255, 0.6)}];
        textView.textField.font = Font(16);
        textView.showBorder = YES;
        _nameTextField = textView.textField;
        [cellView addSubview:textView];
        
        //
        myUILabel *tipLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(textView.frame)-50, ScreenWidth, 50)];
        tipLabel.textColor = WhiteColor;
        tipLabel.text = @"Please enter the name for this controller.";
        
        
        tipLabel.font = Font(14);
        tipLabel.verticalAlignment = VerticalAlignmentMiddle;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [cellView addSubview:tipLabel];
        
    } else if (section == 2) {
        
        UIButton *pairButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, ScreenWidth-100, 60)];
        pairButton.layer.borderColor = WhiteColor.CGColor;
        pairButton.layer.borderWidth = 1;
        [pairButton setTitle:@"Pair Controller" forState:UIControlStateNormal];
        [pairButton setTitleColor:WhiteColor forState:UIControlStateNormal];
        [pairButton addTarget:self action:@selector(pairControllerAction) forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:pairButton];
    }
    
    return cellView;
}

- (void)pairControllerAction
{
    //连接设备后发送配对指令
    NSLog(@"Pairing ...");
    
    if (_selectedLightController) {
        
        [MBProgressHUD showMessage:nil];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //
            CBPeripheral *peripheral = [[BluetoothManager sharedInstance].device objectAtIndex:_selectedLightControllerIndex];
            
            [[BluetoothManager sharedInstance] disConnectPeripheral];
            [[BluetoothManager sharedInstance] connectPeripheral:peripheral onSuccessBlock:^{
                //success
                if (peripheral.state == CBPeripheralStateConnected) {
                                     
                    [self showPairSuccess:peripheral];
                    
//                    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand pairMainControllerCommand] onRespond:^(NSData *data) {
//                        //success
//                        Byte value[30] = {0};
//                        [data getBytes:&value length:sizeof(value)];
//                        
//                        if (value[0] == 0xaa && value[1] == 0x0a) {
//                            //paired success
//                            //                            [MBProgressHUD showSuccess:@"Paired Success."];
//                            [self showPairSuccess:peripheral];
//                        }
//                        else {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [MBProgressHUD hideHUD];
//                                [MBProgressHUD showError:@"Paired Error!"];
//                            });
//                        }
//                        
//                        
//                    } onTimeOut:^{
//                        //timeout
//                        
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [MBProgressHUD hideHUD];
//                            [MBProgressHUD showError:@"No Respond."];
//                        });
//                    }];
                }
            } onTimeoutBlock:nil];
            
            
        });
        
    }
}

- (void)showPairSuccess:(CBPeripheral *)peripheral
{
    //添加到数据库
    NSString *name;
    NSString *deviceName = _selectedLightController.deviceName?_selectedLightController.deviceName : @"Unnamed";
    if (_nameTextField.text && ![_nameTextField.text isEqualToString:@""]) {
        name = _nameTextField.text;
    } else {
        name = deviceName;
    }
    
    LightController *newObject = [LightController addObjectWithIdentifier:[peripheral.identifier UUIDString] inManagedObjectContext:APPDELEGATE.managedObjectContext];
    newObject.deviceName = deviceName;
    newObject.name = name;
    
    [APPDELEGATE saveContext];
    
    //配对命令
    [[BluetoothManager sharedInstance] sendDataToPeripheral:[LightControllerCommand pairMainControllerCommand:newObject.lightID]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
    
    //Tip
    TipViewController *tip = [[TipViewController alloc] init];
    tip.headTitleText = @"Controller Found";
    tip.tiptilteText = @"Success!";
    tip.tipDetailText = [NSString stringWithFormat:@"You have paired \"%@\" controller.", name];
    tip.okButtonContent = @"Return";
    tip.cancelButtonContent = nil;
    [self.navigationController pushViewController:tip animated:YES];
    
    tip.okActionBlock = ^() {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[HomeViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    };
}

//下拉菜单事件
- (void)dropButtonClick:(UIButton *)button
{
    //下拉菜单事件
    [self.dropDownListDataArray removeAllObjects];
    for (CBPeripheral *peripheral in [BluetoothManager sharedInstance].device) {
        //过滤掉没有名字的设备
        NSString *deviceName = peripheral.name;
        if (!deviceName) continue;
        deviceName = [deviceName lowercaseString];
  
#ifdef TEST_FILTER_NAME
        LightControllerModel *device = [[LightControllerModel alloc] init];
        device.deviceName = peripheral.name;
        device.identifier = [peripheral.identifier UUIDString];
        [self.dropDownListDataArray addObject:device];
#else
        if ([deviceName hasPrefix:@"vlc"] || [deviceName hasPrefix:@"tv"]) {
            
            LightControllerModel *device = [[LightControllerModel alloc] init];
            device.deviceName = peripheral.name;
            device.identifier = [peripheral.identifier UUIDString];
            [self.dropDownListDataArray addObject:device];
        }
#endif
        
        
    }
    
    CGFloat dropDownHeight = 50;
    if (_dropDownListDataArray.count < 6) {
        dropDownHeight = 50*_dropDownListDataArray.count;
    } else {
        dropDownHeight = 50*5;
    }
    
    CGRect cellRect = [self.tableView rectForSection:button.tag];
    
    CGRect frame = (CGRect){50, cellRect.origin.y+NavBarHeight+cellRect.size.height, ScreenWidth-100, dropDownHeight};
    [self showDropDownListWithFrame:frame];
    [self.tableView reloadData];
}

- (void)showDropDownListWithFrame:(CGRect)frame
{
    if (!_dropDownTableView) {
        _dropDownTableView = [[UITableView alloc] initWithFrame:frame];
        _dropDownTableView.dataSource = self;
        _dropDownTableView.delegate = self;
        _dropDownTableView.layer.borderColor = [UIColor blackColor].CGColor;
        _dropDownTableView.layer.borderWidth = 1;
        [_dropDownTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"dropDownCell"];
    } else {
        [_dropDownTableView removeFromSuperview];
        _dropDownTableView.frame = frame;
        [_dropDownTableView reloadData];
    }
    
    [self.view addSubview:_dropDownTableView];
}

@end
