//
//  LFMonthPickerCell.m
//  LFMonthSelect
//
//  Created by 王力丰 on 2018/1/9.
//  Copyright © 2018年 杭州天丽科技有限公司. All rights reserved.
//

#import "LFMonthPickerCell.h"

@interface LFMonthPickerCell(){}
@property (nonatomic,assign) CGSize cellSize;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *monthNameLabel;
@end

@implementation LFMonthPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (UITableViewCell *)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        if (CGSizeEqualToSize(size, CGSizeZero))
            [NSException raise:NSInvalidArgumentException format:@"LFMonthPickerCell size can't be zero!"];
        else
            self.cellSize = size;
        
        [self applyCellStyle];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (self = [self initWithSize:CGSizeZero reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)applyCellStyle
{
    UIView* containingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
    
    self.monthNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
    self.monthNameLabel.center = CGPointMake(containingView.frame.size.width/2, self.cellSize.height/2);
    self.monthNameLabel.textAlignment = NSTextAlignmentCenter;
    self.monthNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:self.monthNameLabel.font.pointSize];
    self.monthNameLabel.backgroundColor = [UIColor clearColor];
    
    [containingView addSubview: self.monthNameLabel];
    
    self.containerView = containingView;
    
    /************************************  转一转  ************************************/
    [containingView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [self addSubview:containingView];
    
    if (self.cellSize.width != self.cellSize.height) {
        containingView.frame = CGRectMake(0, 0, self.cellSize.height, self.cellSize.width);
    }
}


@end
