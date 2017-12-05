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

- (void)dealloc
{
    [self.downloadViwe hide];
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
    __weak typeof(self) weakSelf = self;
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Downloading %.f%%", progress*100.0];
        });
        
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
        
        __strong typeof(self) strongSelf = weakSelf;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                strongSelf.progressView.progress = 100.0;
//                strongSelf.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Downloading %.f%%", 100.0];
//            });
//
//            NSData *fileData = [NSData dataWithContentsOfURL:filePath];
//            [strongSelf updateFirmwareStart:fileData];
//        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.progressView.progress = 100.0;
            strongSelf.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Downloading %.f%%", 100.0];
        });

        NSData *fileData = [NSData dataWithContentsOfURL:filePath];
        [strongSelf updateFirmwareStart:fileData];
        
    }];
}
//开始更新固件
- (void)updateFirmwareStart:(NSData *)fileData
{
    //3：APP发送:7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F  （启动更新指令）
    
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand updateFirmwareCommand] onRespond:nil onTimeOut:nil];
    
    //等待2秒：
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self readyToEarsing:fileData];
    });
    
//    __weak typeof(self) weakSelf = self;
//    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand updateFirmwareCommand] onRespond:^BOOL(NSData *data) {
//
//        Byte value[20] = {0};
//        [data getBytes:&value length:sizeof(value)];
//        if (value[0] == 0xaa && value[1] == 0x0a) {
//            //            1秒内：
//            //            MCU回复:AA 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 A0 （下位机启动固件更新）
//            //继续读取
//            //            1秒内：
//            //            MCU回复5A 55；（说明引导程序已经做好准备）
//            [[BluetoothManager sharedInstance] readDataWithRespond:^BOOL(NSData *data) {
//
//                Byte value[20] = {0};
//                [data getBytes:&value length:sizeof(value)];
//                if (value[0] == 0x5a && value[1] == 0x55) {
//                    [weakSelf readyToEarsing:fileData];
//                    return YES;
//                }
//                return NO;
//            } timeOutValue:5 onTimeOut:^{
//                //超时
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.downloadViwe hide];
//                    [MBProgressHUD showError:@"Unsuccessful"];
//                });
//            }];
//
//            return YES;
//        }
//
//        return NO;
//    } timeOutValue:5 onTimeOut:^{
//
//        //超时
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.downloadViwe hide];
//            [MBProgressHUD showError:@"Unsuccessful"];
//        });
//
//    }];
}

- (void)readyToEarsing:(NSData *)fileData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadViwe.tipLabel.text = @"Erasing…";
        self.progressView.progress = 0.0;
    });
    
    //4:APP发送5A 69
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand erasingConfirmCommand] onRespond:nil onTimeOut:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadViwe.tipLabel.text = @"Erasing 100%";
        self.progressView.progress = 100;
    });
    
    //等待5秒：
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self erasingData:fileData];
    });
    
//    __weak typeof(self) weakSelf = self;
//    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand erasingConfirmCommand] onRespond:^BOOL(NSData *data) {
//
//        Byte value[2] = {0};
//        [data getBytes:&value length:sizeof(value)];
//        if (value[0] == 0x5a && value[1] == 0xa5) {
//            //5秒内：
////            MCU回复:5A A5 （程序擦除完成），
//            //表示擦除成功
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.downloadViwe.tipLabel.text = @"Erasing 100%";
//                self.progressView.progress = 100.0;
//            });
//
//            [weakSelf erasingData:fileData];
//            return YES;
//        }
//
//        return NO;
//    } timeOutValue:5.0 onTimeOut:^{
//
//        //超时
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.downloadViwe hide];
//            [MBProgressHUD showError:@"Unsuccessful"];
//        });
//
//    }];
    
}

- (void)erasingData:(NSData *)fileData
{
    //5:APP发送5A 69（无需等待MCU回复)
//    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand erasingConfirmCommand] onRespond:nil onTimeOut:nil];
    
    //6:APP发送2FC4(告知bin文件大小给MCU，2FC4是V26文件大小）
    [self readyUpdating:fileData];
}

//更新文件 
- (void)readyUpdating:(NSData *)fileData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadViwe.tipLabel.text = @"Updating 0%";
        self.progressView.progress = 0.0;
    });
    
    //6:APP发送2FC4(告知bin文件大小给MCU，2FC4是V26文件大小）
    [[BluetoothManager sharedInstance] sendData:[LightControllerCommand readyUpdateFirmwareCommandWithDataLen:fileData.length] onRespond:nil onTimeOut:nil];
    
    //延时100ms， （无需等待MCU回复)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        //7：APP传输bin文件的数据给mcu；直到程序下载完毕，mcu不再给回复；而是直接运行新程序；
        [self writeFirmwareData:fileData];
    });
}

//开始写文件
- (void)writeFirmwareData:(NSData *)fileData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
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
            if (!sendComplete) {
                sendData = [fileData subdataWithRange:NSMakeRange(offset, fileData.length - offset)];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CGFloat progress = (float)offset / (float)fileData.length;
                self.progressView.progress = progress;
                self.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Updating %.f%%", progress*100.0];
            });
            
            //        CGFloat progress = (float)offset / (float)fileData.length;
            //        self.progressView.progress = progress;
            //        self.downloadViwe.tipLabel.text = [NSString stringWithFormat:@"Updating %.f%%", progress*100.0];
            
            [NSThread sleepForTimeInterval:0.2];
            
        } while (!sendComplete);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = 100;
            self.downloadViwe.tipLabel.text = @"Successful";
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.downloadViwe hide];
            });
            
        });
        
        //写数据完成
        if (self.downloadCompletionBlock) {
            self.downloadCompletionBlock();
        }
    });
}

@end
