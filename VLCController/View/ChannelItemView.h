//
//  ChannelItemView.h
//  VLCController
//
//  Created by mojingyu on 16/3/4.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelItemView : UIView

@property (nonatomic, strong) ChannelModel *channel;
@property (nonatomic, copy) void (^onDeleteAction)(ChannelModel *channel);

- (id)initWithFrame:(CGRect)frame useDeleteButton:(BOOL)useDeleteButton;

@end
