//
//  SelectDateView.h
//  iTotemMinFramework
//
//  Created by xiexianhui on 14-7-21.
//
//

#import <UIKit/UIKit.h>
@class SelectDateView;

@protocol SelectDateViewDelegate <NSObject>

@optional
- (void)selectDateView:(SelectDateView *)selectView withSelectDate:(NSDate *)selectDate;

@end


@interface SelectDateView : UIView
{
    
    IBOutlet UIView *_viewDateBg;
    IBOutlet UIDatePicker *_datePicker;
    IBOutlet UILabel *_labelTimeTitle;
    IBOutlet UIImageView *_imgViewLine;
}
@property (nonatomic, weak) id<SelectDateViewDelegate> delegate;
@property (nonatomic, strong) NSString *strKey;

- (void)loadTitle:(NSString *)title;
- (void)loadDate:(NSDate *)date;
- (void)loadMaxDate:(NSDate *)date;
- (void)loadMinDate:(NSDate *)date;
@end
