# LFMonthPicker
An iOS month picker to allow users to select year and month
![](https://github.com/Jucuzzi/LFMonthPicker/blob/master/IMG_0705.jpg)
##如何使用
###首先为了避免iOS11以上的安全区域的影响，需要在delegate里面加入以下代码，对全工程有效，已做过tableView的iOS11相关适配的同学请忽略
```c
//适配iOS11的tableView问题
[UITableView appearance].estimatedRowHeight = 0;
[UITableView appearance].estimatedSectionHeaderHeight = 0;
[UITableView appearance].estimatedSectionFooterHeight = 0;
if (@available(iOS 11, *)) {
[UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
}
```
###然后你只需要在需要使用到的地方加入以下代码
```c
self.monthpicker = [[LFMonthPicker alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width , 90) monthCellSize:CGSizeMake(60, 60) month:1 year:2018];
self.monthpicker.monthNameLabelFontSize = 18.0f;
self.monthpicker.activeMonthNameColor = [UIColor blackColor];
self.dateFormatter = [[NSDateFormatter alloc] init];
[self.dateFormatter setDateFormat:@"MM"];
self.monthpicker.delegate = self;
self.monthpicker.dataSource = self;

NSDate *now = [NSDate date];
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
NSDateComponents *comps = nil;
comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
NSDateComponents *adcomps = [[NSDateComponents alloc] init];
[adcomps setYear:0];
[adcomps setMonth:-11];
[adcomps setDay:0];
NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:now options:0];

[self.monthpicker setStartDate:newdate endDate:now];
[self.monthpicker setCurrentDate:[NSDate date] animated:NO];
[self.view addSubview:self.monthpicker];
```
###这里有以下几种代理和数据源，您可以自行添加
```c
@protocol LFMonthPickerDataSource <NSObject>
@optional

- (NSString *)monthPicker:(LFMonthPicker *)monthPicker titleForCellMonthNameLabelInMonth:(LFMonth *)month;

@end

@protocol LFMonthPickerDelegate <NSObject>
@optional
- (void)monthPicker:(LFMonthPicker *)monthPicker scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)monthPicker:(LFMonthPicker *)monthPicker scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)monthPicker:(LFMonthPicker *)monthPicker scrollViewDidEndDragging:(UIScrollView *)scrollView;

- (void)monthPicker:(LFMonthPicker *)monthPicker willSelectMonth:(LFMonth *)month;
- (void)monthPicker:(LFMonthPicker *)monthPicker didSelectMonth:(LFMonth *)month;

@end
```
###对于颜色和表现有这些属性可以设置
```c
/*
* 激活与非激活的文字颜色设置
*/
@property (nonatomic, strong) UIColor *activeMonthNameColor;
@property (nonatomic, strong) UIColor *inactiveMonthColor;

/*
* picker的背景颜色
*/
@property (nonatomic, strong) UIColor *backgroundPickerColor;

/* 月份显示的字体大小 */
@property (nonatomic, assign) CGFloat monthNameLabelFontSize;

/* 文字缩放的大小 */
@property (nonatomic, assign) CGFloat monthLabelZoomScale;

@property (nonatomic, readonly) CGSize monthCellSize;
```
##使用要求
iOS8.0及以上
##关于控件的使用背景
iOS中系统自带了年月日以及时分秒等几种选择器，但是没有只选择年月的，有很多的场景我们仅仅需要选择年月，这款控件是一个比较高度针对化的控件，横向选择更加现代化，操作也相对便捷一些，希望可以满足大家的需求。
有问题可以及时反馈给我

email:917609510@qq.com


