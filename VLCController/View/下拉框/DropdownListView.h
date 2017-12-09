//
//  DropdownListView.h
//  iTotemMinFramework
//
//  Created by mojingyu on 16/1/25.
//
//

#import <UIKit/UIKit.h>

@protocol DropdownListViewDelegate <NSObject>

- (void)didSelectedAction:(NSInteger)index;

@end

@interface DropdownListView : UIView

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) NSMutableArray *dataArray;    //of NSString
@property (nonatomic, assign) CGRect showFrame;
@property (nonatomic, weak) id<DropdownListViewDelegate> delegate;

@property (nonatomic, copy) void (^didSelectedActionBlock)(NSInteger index);

- (void)show;
- (void)showAtCenter;

- (void)showAtPoint:(CGPoint)point inWidth:(CGFloat)width;

@end
