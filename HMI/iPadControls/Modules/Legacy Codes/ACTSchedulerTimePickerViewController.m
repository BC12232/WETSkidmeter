//
//  ACTSchedulerTimePickerViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 10/2/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTSchedulerTimePickerViewController.h"

@interface ACTSchedulerTimePickerViewController ()
@property (nonatomic) UIDatePicker *timePicker;
@property (nonatomic) NSDateFormatter *timeFormatter;

@property (weak, nonatomic) NSArray *paths;
@property (weak, nonatomic) NSString *docDir;
@property (weak, nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSString *time;

@end

@implementation ACTSchedulerTimePickerViewController{

}

@synthesize timeChosen;
@synthesize buttonTag;
@synthesize currentValue;
@synthesize eqroomNum;

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    _manager = [NSFileManager defaultManager];
    self.preferredContentSize = CGSizeMake(300.0, 300);
    self.view.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    
    _timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, 300, 250)];
    _timePicker.datePickerMode = UIDatePickerModeTime;
    _timePicker.hidden = NO;
    NSString *hoursString;
    hoursString =[_time substringWithRange:NSMakeRange(0, 2)];
    NSString *minutesString;
    minutesString =[_time substringWithRange:NSMakeRange([_time length] - 2, 2)];
    
    NSDate *today= _timePicker.date;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: ( NSCalendarUnitHour | NSCalendarUnitMinute  ) fromDate: today];
    
    components.hour = [hoursString intValue];
    components.minute = [minutesString intValue];
    
    NSLog(@"hour: %@, minute: %@, currentValue: %@", hoursString, minutesString, _time);
    _timePicker.date =  [gregorian dateFromComponents:components];
    
    [_timePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_timePicker];
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(115, 250, 70, 30)];
    [changeButton setBackgroundImage:[UIImage imageNamed:@"done_70x30"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeTime) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:changeButton];
    
    
}

-(void)changeTime{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt: (int)1] forKey:@"dismiss"];
    
}

-(void)changeDateInLabel:(id)sender{
    
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"Hmm";
    self.timeChosen =  [NSNumber numberWithInt: (int)[[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:_timePicker.date]] intValue]];
    
    NSLog(@"time chosen from picker: %@", self.timeChosen);

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    _time = self.currentValue;
    
    NSString *hoursString;
    hoursString =[_time substringWithRange:NSMakeRange(0, 2)];
    NSString *minutesString;
    minutesString =[_time substringWithRange:NSMakeRange([_time length] - 2, 2)];
    
    NSDate *today= _timePicker.date;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: ( NSCalendarUnitHour | NSCalendarUnitMinute  ) fromDate: today];
    
    components.hour = [hoursString intValue];
    components.minute = [minutesString intValue];
    
    NSLog(@"hour: %@, minute: %@, currentValue: %@", hoursString, minutesString, _time);
    _timePicker.date =  [gregorian dateFromComponents:components];
    
    [self changeDateInLabel:nil];
    
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];

}


@end
