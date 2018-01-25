//
//  LFMonthPicker.m
//  HEMS
//
//  Created by 王力丰 on 2018/1/8.
//  Copyright © 2018年 杭州天丽科技有限公司. All rights reserved.
//

#import "LFMonthPicker.h"
#import "LFMonthPickerCell.h"
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define VI_HZBLUE_COLOR [UIColor colorWithRed:0 / 255.0 green:171 / 255.0 blue:253 / 255.0 alpha:1]

CGFloat const kDefaultMonthNameLabelFontSize = 11.0f;

CGFloat const   kDefaultCellHeight = 60.0f;
CGFloat const   kDefaultCellWidth = 60.0f;

CGFloat const kDefaultMonthLabelMaxZoomValue = 4.0f;

NSInteger const kDefaultInitialInactiveMonths = 8;
NSInteger const kDefaultFinalInactiveMonths = 8;

#define kDefaultColorInactiveMonth  [UIColor lightGrayColor]
#define kDefaultColorBackground     [UIColor whiteColor]

#define kDefaultColorMonthName      [UIColor blackColor]

static BOOL NSRangeContainsRow(NSRange range, NSInteger row) {
    if ((row <= range.location + range.length) && (row >= range.location)) {
        return YES;
    }
    
    return NO;
}

@interface LFMonthPicker () <UITableViewDelegate, UITableViewDataSource>{
    UILabel *yearLabel;
}

// initialFrame property is a hack for initWithCoder:
@property (nonatomic, assign) CGRect initialFrame;

@property (nonatomic, strong) NSIndexPath *currentIndex;

@property (nonatomic, assign) CGSize monthCellSize;

@property (nonatomic, assign) NSRange activeMonths;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *tableMonthsData;

@end

@implementation LFMonthPicker

#pragma mark - 初始化方法

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self = [self initWithFrame:CGRectMake(0, 0, self.initialFrame.size.width, self.initialFrame.size.height) monthCellSize:CGSizeMake(self.initialFrame.size.height, self.initialFrame.size.height) month:1 year:1970];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
            self.frame = CGRectMake(self.initialFrame.origin.x, 0, self.frame.size.width, self.initialFrame.origin.y + self.frame.size.height);
        } else {
            self.frame = CGRectMake(self.initialFrame.origin.x, self.initialFrame.origin.y, self.frame.size.width, self.initialFrame.size.height);
        }
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame monthCellSize:(CGSize)cellSize {
    if (self = [self initWithFrame:frame monthCellSize:CGSizeMake(kDefaultCellWidth, kDefaultCellHeight) month:1 year:1970]) {}
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame month:(NSInteger)month year:(NSInteger)year {
    if (self = [self initWithFrame:frame monthCellSize:CGSizeMake(kDefaultCellWidth, kDefaultCellHeight) month:month year:year]) {}
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame monthCellSize:(CGSize)cellSize month:(NSInteger)month year:(NSInteger)year {
    _monthCellSize = cellSize;
    
    if (self = [self initWithFrame:frame]) {
        _month = month;
        _year = year;
        
        [self fillTableDataWithCurrentMonth];
        
        self.currentMonth = 10;
    }
    
    return self;
}

#pragma mark - setter&getter方法
- (void)setMonth:(NSInteger)month {
    if (_month != month) {
        _month = month;
        [self fillTableDataWithCurrentMonth];
        [self setupTableViewContent];
    }
}

- (void)setYear:(NSInteger)year {
    if (_year != year) {
        _year = year;
        [self fillTableDataWithCurrentMonth];
        [self setupTableViewContent];
    }
}

- (void)setMonthNameLabelFontSize:(CGFloat)monthNameLabelFontSize {
    _monthNameLabelFontSize = monthNameLabelFontSize;
    [self.tableView reloadData];
}

- (void)setActiveMonthsFrom:(NSInteger)fromMonth toMonth:(NSInteger)toMonth {
    self.activeMonths = NSMakeRange(fromMonth, toMonth - fromMonth);
}

- (void)setActiveMonths:(NSRange)activeMonths {
    _activeMonths = activeMonths;
    [self.tableView reloadData];
    [self setupTableViewContent];
}

- (void)setCurrentMonth:(NSInteger)currentMonth animated:(BOOL)animated {
    _currentMonth = currentMonth;
    _currentIndex = [NSIndexPath indexPathForRow:currentMonth - 1 inSection:0];
    // 只用一次，其余手动设置
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.tableView scrollToRowAtIndexPath:_currentIndex
                          atScrollPosition:UITableViewScrollPositionMiddle
                          animated        :animated];
    
    [self setupTableViewContent];
}

- (void)setCurrentMonth:(NSInteger)currentMonth {
    [self setCurrentMonth:currentMonth animated:NO];
}

- (void)setCurrentDate:(NSDate *)date animated:(BOOL)animated {
    if (date) {
        NSInteger           components = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
        NSDateComponents    *componentsFromDate = [[NSCalendar currentCalendar] components:components
                                                                                  fromDate:date];
        
        [self.tableMonthsData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LFMonth *month = obj;
            
            NSDateComponents *componentsFromDayDate = [[NSCalendar currentCalendar] components:components
                                                                                      fromDate:month.date];
            
            NSDate *searchingDate = [[NSCalendar currentCalendar] dateFromComponents:componentsFromDate];
            NSDate *dayDate = [[NSCalendar currentCalendar] dateFromComponents:componentsFromDayDate];
            
            if ([[searchingDate getYearAndMonth] isEqualToString:[dayDate getYearAndMonth]]) {
                _currentDate = date;
                NSString *str = [[_currentDate getYearAndMonth] substringToIndex:4];
                yearLabel.text = [NSString stringWithFormat:@"%@年", str];
                
                [self setCurrentMonth:idx + 1 animated:animated];
                *stop = YES;
            }
        }];
    }
}

- (void)setCurrentDate:(NSDate *)date {
    [self setCurrentDate:date animated:NO];
}

- (void)setCurrentIndex:(NSIndexPath *)currentIndex {
    _currentIndex = currentIndex;
    
    //  手动计算ContentOffset
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:currentIndex];
    
    CGFloat contentOffset = cell.center.y - (self.tableView.frame.size.width / 2);
    
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, contentOffset) animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(monthPicker:didSelectMonth:)]) {
        [self.delegate monthPicker:self didSelectMonth:self.tableMonthsData[currentIndex.row]];
    }
}

- (LFMonthPickerCell *)cellForMonth:(LFMonth *)month {
    NSInteger dayIndex = [self.tableMonthsData indexOfObject:month];
    
    return (LFMonthPickerCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:dayIndex inSection:0]];
}

- (void)reloadData {
    [self.tableView reloadData];
    [self setupTableViewContent];
}

- (void)setFrame:(CGRect)frame {
    if (CGRectIsEmpty(self.initialFrame)) {
        self.initialFrame = frame;
    }
    
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _activeMonthNameColor = kDefaultColorMonthName;
        _inactiveMonthColor = kDefaultColorInactiveMonth;
        _backgroundPickerColor = kDefaultColorBackground;
        _monthLabelZoomScale = kDefaultMonthLabelMaxZoomValue;
        _monthNameLabelFontSize = kDefaultMonthNameLabelFontSize;
        
        [self setActiveMonthsFrom:1 toMonth:[NSDate dateFromDay:1 month:self.month year:self.year].numberOfDaysInMonth - 1];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 30, SCREEN_WIDTH - 20, 60)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 5.f;
        [self addSubview:view];
        
        yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        yearLabel.text = [NSString stringWithFormat:@"%@年", [self.currentDate getYearAndMonth]];
        yearLabel.textAlignment = NSTextAlignmentCenter;
        yearLabel.font = [UIFont systemFontOfSize:15.f];
        yearLabel.textColor = [UIColor whiteColor];
        [self addSubview:yearLabel];
        
        // Make the UITableView's height the width, and width the height so that when we rotate it it will fit exactly
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height - 30, frame.size.width - 40)];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        
        // Rotate the tableview by 90 degrees so that it is side scrollable
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.tableView.center = CGPointMake(frame.size.width / 2, (frame.size.height - 30) / 2 + 30);
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self.tableView addGestureRecognizer:tapGesture];
        
        [self addSubview:self.tableView];
        
        self.backgroundColor = VI_HZBLUE_COLOR;
        
        // 绘制上下两个小三角形
        CAShapeLayer    *layer = [[CAShapeLayer alloc]init];
        UIBezierPath    *bezierPath = [[UIBezierPath alloc]init];
        [bezierPath moveToPoint:CGPointMake(self.frame.size.width / 2 - 8, 30)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width / 2 + 8, 30)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width / 2, 38)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width / 2 - 8, 30)];
        [bezierPath moveToPoint:CGPointMake(self.frame.size.width / 2 - 8, 90)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width / 2 + 8, 90)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width / 2, 82)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width / 2 - 8, 90)];
        layer.path = bezierPath.CGPath;
        layer.fillColor = VI_HZBLUE_COLOR.CGColor;
        [self.layer addSublayer:layer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupTableViewContent];
    
    [self setCurrentDate:self.currentDate animated:NO];
}

- (void)setupTableViewContent {
    // *|1|2|3|4|5
    CGFloat startActiveMonthsWidth = (kDefaultInitialInactiveMonths * self.monthCellSize.width) + ((self.activeMonths.location - 1) * self.monthCellSize.width);
    
    // *|-|-|1|2|3|
    CGFloat insetLimit = startActiveMonthsWidth - (self.frame.size.width / 2) + (self.monthCellSize.width / 2);
    
    self.tableView.contentInset = UIEdgeInsetsMake(-insetLimit, 0, 0, 0);
    
    CGFloat contentSizeLimit = startActiveMonthsWidth + ((self.activeMonths.length + 1) * self.monthCellSize.width) + (self.frame.size.width / 2) - (self.monthCellSize.width / 2);
    
    self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.height, contentSizeLimit);
    NSLog(@"前面的大小为%lu", (unsigned long)contentSizeLimit);
}

- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    _startDate = startDate;
    _endDate = endDate;
    
    NSMutableArray *tableData = [NSMutableArray array];
    
    NSDateFormatter *dateNameFormatter = [[NSDateFormatter alloc] init];
    [dateNameFormatter setDateFormat:@"MM"];
    
    NSDate *beforeDate = startDate;
    
    for (int i = kDefaultInitialInactiveMonths; i >= 1; i--) {
        beforeDate = [beforeDate beforeMonthDate];
        NSDate *middleDay = [beforeDate dateByAddingTimeInterval:(60.0 * 60.0 * 12.0)];
        
        LFMonth *newMonth = [[LFMonth alloc] init];
        newMonth.name = [dateNameFormatter stringFromDate:middleDay];
        newMonth.date = middleDay;
        [tableData addObject:newMonth];
    }
    
    tableData = (NSMutableArray *)[[tableData reverseObjectEnumerator]allObjects];
    
    NSInteger numberOfActiveDays = 0;
    
    for (NSDate *date = startDate; [date compare:endDate] <= 0; date = [date afterMonthDate]) {
        NSDate *middleDay = [date dateByAddingTimeInterval:(60.0 * 60.0 * 12.0)];
        
        LFMonth *newMonth = [[LFMonth alloc] init];
        newMonth.name = [dateNameFormatter stringFromDate:middleDay];
        newMonth.date = middleDay;
        
        [tableData addObject:newMonth];
        
        numberOfActiveDays++;
    }
    
    NSDate *afterDate = endDate;
    
    for (int i = 1; i <= kDefaultInitialInactiveMonths; i++) {
        afterDate = [afterDate afterMonthDate];
        NSDate *middleDay = [afterDate dateByAddingTimeInterval:(60.0 * 60.0 * 12.0)];
        
        LFMonth *newMonth = [[LFMonth alloc] init];
        newMonth.name = [dateNameFormatter stringFromDate:middleDay];
        newMonth.date = middleDay;
        
        [tableData addObject:newMonth];
    }
    
    self.tableMonthsData = [tableData copy];
    
    [self setActiveMonthsFrom:1 toMonth:numberOfActiveDays];
    
    [self.tableView reloadData];
}

- (void)fillTableDataWithCurrentMonth {
    NSDate  *startDate = [NSDate dateFromDay:1 month:self.month year:self.year];
    NSDate  *endDate = [NSDate dateFromDay:startDate.numberOfDaysInMonth - 1 month:self.month year:self.year];
    
    [self setStartDate:startDate endDate:endDate];
}

#pragma mark - UITapGestureRecognizer

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint     location = [tapGesture locationInView:tapGesture.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        if (NSRangeContainsRow(self.activeMonths, indexPath.row - kDefaultInitialInactiveMonths + 1)) {
            if (indexPath.row != self.currentIndex.row) {
                if ([self.delegate respondsToSelector:@selector(monthPicker:willSelectMonth:)]) {
                    [self.delegate monthPicker:self willSelectMonth:self.tableMonthsData[indexPath.row]];
                }
                
                _currentMonth = indexPath.row - 1;
                _currentDate = [(LFMonth *)self.tableMonthsData[indexPath.row] date];
                [self setCurrentIndex:indexPath];
            }
        }
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(monthPicker:scrollViewDidScroll:)]) {
        [self.delegate monthPicker:self scrollViewDidScroll:scrollView];
    }
    
    CGPoint centerTableViewPoint = [self convertPoint:CGPointMake(self.frame.size.width / 2.0, self.monthCellSize.height / 2.0) toView:self.tableView];
    
    // Zooming visible cell's
    for (LFMonthPickerCell *cell in self.tableView.visibleCells) {
        @autoreleasepool {
            // Distance between cell center point and center of tableView
            CGFloat distance = cell.center.y - centerTableViewPoint.y;
            
            // Zoom step using cosinus
            CGFloat zoomStep = cosf(M_PI_2 * distance / self.monthCellSize.width);
            
            if ((distance < self.monthCellSize.width) && (distance > -self.monthCellSize.width)) {
                cell.monthNameLabel.font = [cell.monthNameLabel.font fontWithSize:self.monthNameLabelFontSize + self.monthLabelZoomScale * zoomStep];
            } else {
                cell.monthNameLabel.font = [cell.monthNameLabel.font fontWithSize:self.monthNameLabelFontSize];
            }
            
            if ((distance < self.monthCellSize.width / 2) && (distance > -self.monthCellSize.width / 2)) {
                cell.containerView.backgroundColor = self.backgroundPickerColor;
            } else {
                cell.containerView.backgroundColor = [UIColor clearColor];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(monthPicker:scrollViewDidEndDecelerating:)]) {
        [self.delegate monthPicker:self scrollViewDidEndDecelerating:scrollView];
    }
    
    [self scrollViewDidFinishScrolling:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(monthPicker:scrollViewDidEndDragging:)]) {
        [self.delegate monthPicker:self scrollViewDidEndDragging:scrollView];
    }
    
    if (!decelerate) {
        [self scrollViewDidFinishScrolling:scrollView];
    }
}

- (void)scrollViewDidFinishScrolling:(UIScrollView *)scrollView {
    CGPoint point = [self convertPoint:CGPointMake(self.frame.size.width / 2.0, self.monthCellSize.height / 2.0) toView:self.tableView];
    
    NSIndexPath *centerIndexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(0, point.y)];
    
    if (centerIndexPath.row != self.currentIndex.row) {
        if ([self.delegate respondsToSelector:@selector(monthPicker:willSelectMonth:)]) {
            [self.delegate monthPicker:self willSelectMonth:self.tableMonthsData[centerIndexPath.row]];
        }
        
        _currentMonth = centerIndexPath.row - 1;
        _currentDate = [(LFMonth *)self.tableMonthsData[centerIndexPath.row] date];
        NSString *str = [[_currentDate getYearAndMonth] substringToIndex:4];
        yearLabel.text = [NSString stringWithFormat:@"%@年", str];
        self.currentIndex = centerIndexPath;
    } else {
        // Go back to currentIndex
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_currentIndex];
        
        CGFloat contentOffset = cell.center.y - (self.tableView.frame.size.width / 2);
        
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, contentOffset) animated:YES];
    }
}

#pragma mark - UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableMonthsData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.monthCellSize.width;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"LFMonthPickerCell";
    
    LFMonthPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[LFMonthPickerCell alloc] initWithSize:self.monthCellSize reuseIdentifier:reuseIdentifier];
    }
    
    LFMonth *month = self.tableMonthsData[indexPath.row];
    
    // Bug: 有时候点击的时候row并没有被选中，所以不能在didselect中统一处理，我添加了一个tap手势😉
    [cell setUserInteractionEnabled:NO];
    
    cell.monthNameLabel.font = [cell.monthNameLabel.font fontWithSize:self.monthNameLabelFontSize];
    cell.monthNameLabel.textColor = self.activeMonthNameColor;
    
    if ([self.dataSource respondsToSelector:@selector(monthPicker:titleForCellMonthNameLabelInMonth:)]) {
        cell.monthNameLabel.text = [self.dataSource monthPicker:self titleForCellMonthNameLabelInMonth:month];
    }
    
    if (indexPath.row == _currentIndex.row) {
        cell.containerView.backgroundColor = self.backgroundPickerColor;
        cell.monthNameLabel.font = [cell.monthNameLabel.font fontWithSize:self.monthNameLabelFontSize + self.monthLabelZoomScale];
    } else {
        cell.containerView.backgroundColor = [UIColor clearColor];
        cell.monthNameLabel.font = [cell.monthNameLabel.font fontWithSize:self.monthNameLabelFontSize];
    }
    
    if (NSRangeContainsRow(self.activeMonths, indexPath.row - kDefaultInitialInactiveMonths + 1)) {
        cell.monthNameLabel.textColor = kDefaultColorMonthName;
    } else {
        cell.monthNameLabel.textColor = kDefaultColorInactiveMonth;
    }
    
    return cell;
}

@end

#pragma mark - NSDate (Additional) implementation

@implementation NSDate (Additional)

+ (NSDate *)dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    NSCalendar          *calendar = [NSCalendar currentCalendar];
    NSDateComponents    *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    
    if (month <= 0) {
        [components setMonth:12 - month];
        [components setYear:year - 1];
    } else if (month >= 13) {
        [components setMonth:month - 12];
        [components setYear:year + 1];
    } else {
        [components setMonth:month];
        [components setYear:year];
    }
    
    return [calendar dateFromComponents:components];
}

- (NSUInteger)numberOfDaysInMonth {
    NSCalendar  *c = [NSCalendar currentCalendar];
    NSRange     days = [c rangeOfUnit:NSCalendarUnitDay
                             inUnit  :NSCalendarUnitMonth
                             forDate :self];
    
    return days.length;
}

- (NSDate *)beforeMonthDate {
    NSCalendar          *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents    *comps = nil;
    
    comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:-1];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:self options:0];
    return newdate;
}

- (NSDate *)afterMonthDate {
    NSCalendar          *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents    *comps = nil;
    
    comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:1];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:self options:0];
    return newdate;
}

///获得年月
- (NSString *)getYearAndMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    /// 年月日获得
    NSDateComponents    *comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    int                 month = (int)[comps month];
    int                 year = (int)[comps year];
    
    return [NSString stringWithFormat:@"%d%02d", year, month];
}

@end
