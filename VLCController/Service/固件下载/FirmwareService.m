//
//  FirmwareService.m
//  VLCController
//
//  Created by Mojy on 2017/6/15.
//  Copyright © 2017年 Mojy. All rights reserved.
//

#import "FirmwareService.h"
#import "UIProgressView+AFNetworking.h"
#import <AFNetworking/AFURLSessionManager.h>
#import "BluetoothManager.h"
#import "DownloadProgressView.h"
#import <FCFileManager.h>
#import "LightControllerCommand.h"

//#define getFirmwareFileUrl @"https://cdn.shopify.com/s/files/1/2095/9331/files/v25loader_HOST.hex?12623506794102219447"

@interface FirmwareService ()
{
    NSURLSessionDownloadTask *_downloadTask;
    
}

@property (nonatomic, copy) DownloadCompletionBlock downloadCompletionBlock;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, copy) NSString *peripheralIdentifier;
@property (nonatomic, strong) DownloadProgressView *downloadViwe;
@property (nonatomic, copy) NSString *firmwareVerUrl;

@end

@implementation FirmwareService

- (instancetype)initWithPeripheralIdentifier:(NSString *)identifier url:(NSString *)url completionHandler:(DownloadCompletionBlock)completion
{
    self = [super init];
    if (self) {
        self.downloadCompletionBlock = completion;
        self.progressView = self.downloadViwe.progressView;
        self.firmwareVerUrl = url;
        
        [self downloadFirmwareFile];
    }
    return self;
}

- (DownloadProgressView *)downloadViwe
{
    if (!_downloadViwe) {
        _downloadViwe = [[DownloadProgressView alloc] init];
    }
    return _downloadViwe;
}

- (void)startUpdating
{
    [self startDownload];
    
//    __weak typeof(self) weakSelf = self;
//    [MBProgressHUD showMessage:@""];
//    
//    //发送等待命令
//    Byte commandData[20] = {0};
//    for (NSInteger i = 0; i < 20; i++) {
//        commandData[i] = 0x7F;
//    }
//    
//    NSData *sendData = [[NSData alloc] initWithBytes:commandData length:20];
//    [[BluetoothManager sharedInstance] sendData:sendData onRespond:^BOOL(NSData *data) {
//        //        
//        Byte value[2] = {0};
//        [data getBytes:&value length:sizeof(value)];
//        if (value[0] == 0xaa && value[1] == 0x0a) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUD];
//            });
//            
////
//            
//            return YES;
//        }
//        else {
//            
//            return NO;
//        }
//    } onTimeOut:^{
//        //
//    }];
}

- (void)startDownload
{
    //下载任务开始、继续
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.downloadViwe.tipLabel.text = @"Downloading 0%";
        self.progressView.progress = 0.0f;
        [self.downloadViwe show];
    });
    [_downloadTask resume];
}

- (void)stopDownload
{
    //下载任务暂停
    [_downloadTask suspend];
}

- (void)downloadFirmwareFile
{
//    __weak typeof(self) weakSelf = self;
    if (!self.firmwareVerUrl) return;
    
    //远程地址
    NSURL *url = [NSURL URLWithString:self.firmwareVerUrl];
    
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        //下载进度
        CGFloat progress = downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        self.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Downloading %.f%%", progress*100.0];
        
        //一定要使用"setProgressWithDownloadProgressOfTask"方法设置进度,不然进度条无法刷新
        if (self.progressView) {
            [self.progressView setProgressWithDownloadProgressOfTask:_downloadTask animated:true];
        }
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //设置缓存路径
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        //下载完成后打印路径
        NSLog(@"%@",filePath.absoluteString);
        
//        NSData*data = [NSDatadataWithContentsOfFile:@"/Users/tarena/Desktop/app.txt"];
//        NSData *fileData = [FCFileManager readFileAtPathAsData:filePath.absoluteString error:nil];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.progress = 100.0;
                self.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Downloading %.f%%", 100.0];
            });
            
            NSData *fileData = [NSData dataWithContentsOfURL:filePath];
            [self updateFirmwareStart:fileData];
        });
        
    }];
}

- (void)updateFirmwareStart:(NSData *)fileData
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.downloadViwe.tipLabel.text = @"Erasing…";
//        self.progressView.progress = 0.0;
//    });
    
    __weak typeof(self) weakSelf = self;
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand updateFirmwareCommand] onRespond:^BOOL(NSData *data) {
        
        Byte value[2] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] == 0xaa && value[1] == 0x0a) {
            
            //等待50m后再次发送删除
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                //擦除
                [weakSelf readyToEarsing:fileData];
            });
            
            return YES;
        }
        
        return NO;
    } timeOutValue:10 onTimeOut:^{
        
        //超时
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadViwe hide];
            [MBProgressHUD showError:@"Timeout"];
        });
        
    }];
}

- (void)readyToEarsing:(NSData *)fileData
{
    __weak typeof(self) weakSelf = self;
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand updateFirmwareCommand] onRespond:^BOOL(NSData *data) {
        
        Byte value[2] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] == 0xaa && value[1] == 0x0a) {
            ;
            //等待擦除完成
            [weakSelf erasingData:fileData];
            
            return YES;
        }
        
        return NO;
    } timeOutValue:10 onTimeOut:^{
        
        //超时
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadViwe hide];
            [MBProgressHUD showError:@"Timeout"];
        });
        
    }];
    
}

- (void)erasingData:(NSData *)fileData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadViwe.tipLabel.text = @"Erasing…";
        self.progressView.progress = 0.0;
    });
    
    __weak typeof(self) weakSelf = self;
    
    [[BluetoothManager sharedInstance] readDataWithRespond:^BOOL(NSData *data) {
        
        Byte value[2] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] == 0xaa && value[1] == 0x0b) {
            //表示擦除成功
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadViwe.tipLabel.text = @"Erasing 100%";
                self.progressView.progress = 100.0;
            });
            //发送文件长度
            [weakSelf readyUpdating:fileData];
            
            return YES;
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.downloadViwe hide];
                [MBProgressHUD showError:@"Data Error"];
            });
        }
        
        return NO;
        
    } timeOutValue:10 onTimeOut:^{
        
        //超时
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadViwe hide];
            [MBProgressHUD showError:@"Erasing Error: Timeout"];
        });
    }];
    
}

- (void)readyUpdating:(NSData *)fileData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.downloadViwe.tipLabel.text = @"Updating 0%";
        self.progressView.progress = 0.0;
    });
    
    __weak typeof(self) weakSelf = self;
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand readyUpdateFirmwareCommandWithDataLen:fileData.length] onRespond:^BOOL(NSData *data) {
        
        Byte value[2] = {0};
        [data getBytes:&value length:sizeof(value)];
        if (value[0] == 0xaa && value[1] == 0x0a) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //开始写文件
                [weakSelf writeFirmwareData:fileData];
            });
            
            return YES;
        }
        
        return NO;
    } timeOutValue:10 onTimeOut:^{
        
        //超时
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadViwe hide];
            [MBProgressHUD showError:@"Timeout"];
        });
        
    }];
}

- (void)writeFirmwareData:(NSData *)fileData
{
    NSInteger offset = 0;
    NSInteger sendLen = 20;
    NSData *sendData = fileData;
    BOOL sendComplete = NO;
    
    do {
        
        if (sendData.length > sendLen) {
            sendData = [fileData subdataWithRange:NSMakeRange(offset, sendLen)];
            offset += sendLen;
            
        }
        else {
            sendComplete = YES;
            
            if (sendData.length < sendLen) {
                sendData = [LightControllerCommand formatCommand:sendData];
            }
        }
        
        [[BluetoothManager sharedInstance] sendData:sendData onRespond:nil onTimeOut:nil];        
//        [[BluetoothManager sharedInstance] sendDataToPeripheral:sendData];
        if (!sendComplete) {
            sendData = [fileData subdataWithRange:NSMakeRange(offset, fileData.length - offset)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat progress = (float)offset / (float)fileData.length;
            self.progressView.progress = progress;
            self.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Updating %.f%%", progress*100.0];
        });
        [NSThread sleepForTimeInterval:0.2];
        
    } while (!sendComplete);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadViwe hide];
        });
        
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadViwe.tipLabel.text = @"Updating Success";
    });
    
    //写数据完成
    if (self.downloadCompletionBlock) {
        self.downloadCompletionBlock();
    }
    
}

@end
