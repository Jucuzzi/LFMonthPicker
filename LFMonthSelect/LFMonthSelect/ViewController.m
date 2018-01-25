//
//  ViewController.m
//  LFMonthSelect
//
//  Created by 王力丰 on 2018/1/24.
//  Copyright © 2018年 LiFeng Wang. All rights reserved.
//

#import "ViewController.h"
#import "LFMonthPicker.h"
#define VI_HZBLUE_COLOR [UIColor colorWithRed:0/255.0 green:171/255.0 blue:253/255.0 alpha:1]

@interface ViewController ()<LFMonthPickerDelegate,LFMonthPickerDataSource>{}
@property (nonatomic, strong) LFMonthPicker *monthpicker;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initView {
    self.view.backgroundColor = VI_HZBLUE_COLOR;
    
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LFMonthPickerDelegate & LFMonthPickerDataSource

/************************************  格式化每个月份的显示格式  ************************************/
-(NSString *)monthPicker:(LFMonthPicker *)monthPicker titleForCellMonthNameLabelInMonth:(LFMonth *)month {
    return [NSString stringWithFormat:@"%@月",[self.dateFormatter stringFromDate:month.date]];
}


/************************************  反馈方法  ************************************/
-(void)monthPicker:(LFMonthPicker *)monthPicker willSelectMonth:(LFMonth *)month {
    NSDate *date = month.date;
    NSString *str =[date getYearAndMonth];
    NSLog(@"%@",str);
}

-(void)monthPicker:(LFMonthPicker *)monthPicker didSelectMonth:(LFMonth *)month {
    // Do something
}


@end
