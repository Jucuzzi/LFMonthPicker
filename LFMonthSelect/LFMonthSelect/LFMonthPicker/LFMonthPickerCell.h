//
//  LFMonthPickerCell.h
//  LFMonthSelect
//
//  Created by 王力丰 on 2018/1/9.
//  Copyright © 2018年 杭州天丽科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFMonthPickerCell : UITableViewCell

@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, readonly) UILabel *monthNameLabel;

- (UITableViewCell *)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

@end
