//
//  ChannelItemView.m
//  VLCController
//
//  Created by mojingyu on 16/3/4.
//  Copyright © 2016年 Mojy. All rights reserved.
//

#import "ChannelItemView.h"
#import "NSString+Extension.h"

@interface ChannelItemView()

@property (nonatomic, strong) myUILabel *channelName;
@property (nonatomic, assign) BOOL useDeleteButton;

@end

@implementation ChannelItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame useDeleteButton:(BOOL)useDeleteButton
{
    self.useDeleteButton = useDeleteButton;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        _channelName = [[myUILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame)-70, CGRectGetHeight(frame))];
        _channelName.textAlignment = NSTextAlignmentCenter;
        _channelName.textColor = WhiteColor;
        [self addSubview:_channelName];
        
        //
        if (_useDeleteButton) {
            UIButton *deleteButotn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_channelName.frame), 0, 50, CGRectGetHeight(frame))];
            [self addSubview:deleteButotn];
            
//            [deleteButotn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [deleteButotn setTitle:@"╳" forState:UIControlStateNormal];
            [deleteButotn addTarget:self action:@selector(deleteButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    return self;
}

- (void)setChannel:(ChannelModel *)channel
{
    _channel = channel;
    _channelName.text = channel.name;
}

- (void)deleteButtonClickAction
{
    if (self.onDeleteAction) {
        self.onDeleteAction(self.channel);
    }
}

@end
