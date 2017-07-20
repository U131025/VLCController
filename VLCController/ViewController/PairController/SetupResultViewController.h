//
//  SetupResultViewController.h
//  VLCController
//
//  Created by Mojy on 2017/5/31.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "BaseViewController.h"
#import "ConnectModel.h"

typedef NS_ENUM(NSInteger, SetupResultType) {
    SetupResultTypeSuccess,
    SetupResultTypeOops,
    SetupResultTypeNiceToMeetYou,
};

@interface SetupResultViewController : BaseViewController

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) ConnectModel *model;

- (instancetype)initWithType:(SetupResultType)type;

@end
