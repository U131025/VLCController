//
//  FirmwareModel.h
//  VLCController
//
//  Created by mojingyu on 2017/7/9.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchDataSuccess)(id data);
typedef void (^FetchDataFailure)(id error);

@interface FirmwareModel : NSObject

@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *url;

+ (void)fetchListSuccess:(FetchDataSuccess)successBlock failure:(FetchDataFailure)failure;

@end
