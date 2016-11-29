//
//  LightControllerModel.m
//  VLCController
//
//  Created by mojingyu on 16/1/13.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "LightControllerModel.h"

@implementation LightControllerModel

- (id)init
{
    self = [super init];
    if (self) {
        _type = Normal;
    }
    return self;
}

- (id)initWithLightController:(LightController *)lightController
{
    self = [super init];
    if (self) {
        self.name = lightController.name;
        self.deviceName = lightController.deviceName;
        self.identifier = lightController.identifier;
        self.lightID = lightController.lightID;
    }
    return self;
}

- (NSMutableArray *)slaveArray
{
    if (!_slaveArray) {
        _slaveArray = [[NSMutableArray alloc] init];
    }
    return _slaveArray;
}
@end
