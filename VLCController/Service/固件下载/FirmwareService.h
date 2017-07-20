//
//  FirmwareService.h
//  VLCController
//
//  Created by Mojy on 2017/6/15.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloadCompletionBlock)();

@interface FirmwareService : NSObject

- (instancetype)initWithPeripheralIdentifier:(NSString *)identifier url:(NSString *)url completionHandler:(DownloadCompletionBlock)completion;

- (void)startUpdating;

- (void)startDownload;

- (void)stopDownload;

@end
