//
//  FirmwareModel.m
//  VLCController
//
//  Created by mojingyu on 2017/7/9.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "FirmwareModel.h"
#import "CLNetworking.h"

//#define GetFirmwareListUrl @"https://cdn.shopify.com/s/files/1/2095/9331/files/update.txt?4474227432324224464"

#define GetFirmwareListUrl @"http://eeev01.hk79.2ifree.com/update.txt"

@implementation FirmwareModel

+ (void)fetchListSuccess:(FetchDataSuccess)successBlock failure:(FetchDataFailure)failure
{
    [CLNetworkingManager getNetworkRequestWithUrlString:GetFirmwareListUrl parameters:nil isCache:NO succeed:^(id data) {
        
        NSArray *array = [data objectForKey:@"firmwares"];
        if (array) {
            NSArray *modelList = [NSArray yy_modelArrayWithClass:[FirmwareModel class] json:array];
            
            if (successBlock && modelList.count > 0) {
                successBlock([NSArray arrayWithObject:[modelList objectAtIndex:0]]);
            }
        }        
        
    } fail:^(NSError *error) {
        if (failure) {
            failure(error);
        }
        
    }];
}

@end
