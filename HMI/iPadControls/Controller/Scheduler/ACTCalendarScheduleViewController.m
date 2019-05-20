//
//  ACTCalendarScheduleViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 4/2/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTCalendarScheduleViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "RDVCalendarDayCell.h"


@interface ACTCalendarScheduleViewController ()
@property (weak, nonatomic) NSArray *paths;
@property (weak, nonatomic) NSString *docDir;
@property (weak, nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSMutableArray *schedule;
@property (nonatomic) NSMutableDictionary *special1;
@property (nonatomic) NSMutableDictionary *special2;
@property (nonatomic) NSMutableDictionary *special3;
@property (nonatomic) RDVCalendarView *calendarScedule;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) int selectedMonth;
@property (nonatomic) int selectedDay;
@property (nonatomic) UILabel *invalidTime;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSString *pass;
@property (nonatomic) NSString *ip;
@property (nonatomic) UIButton *editButton;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic, strong) NSDictionary *langData;
@property (nonatomic) NSUserDefaults *defaults;
@end

@implementation ACTCalendarScheduleViewController


#pragma mark - construct calendar view

-(void)createCalendarView:(int)tag{
    
    int num = tag;
    num = num + 100;
    
    _calendarScedule = [[RDVCalendarView alloc] initWithFrame:CGRectMake(400, 65, 330, 400)];
    _calendarScedule.delegate = self;
    _calendarScedule.currentDayColor = [UIColor clearColor];
    _calendarScedule.separatorColor = [UIColor colorWithRed:250/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
    _calendarScedule.selectedDayColor = [UIColor clearColor];
    _calendarScedule.tag = num;
    _calendarScedule.monthLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.9f];
    _calendarScedule.monthLabel.font = [UIFont fontWithName:@"Verdana" size:24];
   
    [_calendarScedule registerDayCellClass:[RDVCalendarDayCell class]];
    _calendarScedule.backButton.frame = CGRectMake(0, 0, 14, 20);
    
    [self.view addSubview:_calendarScedule];
    
}

-(void)createCalendarSettings{
    
    UIButton *sp1 = [[UIButton alloc] initWithFrame:CGRectMake(128, 68, 50, 50)];
    [sp1 setImage:[UIImage imageNamed:@"calSched1"] forState:UIControlStateNormal];
    sp1.tag = 1;
    sp1.layer.cornerRadius = 25;
    sp1.userInteractionEnabled = NO;
    [[sp1 layer] setBorderColor:[UIColor colorWithRed:0/255.0 green:154/255.0 blue:255/255.0 alpha:85.0].CGColor];
    [self.view addSubview:sp1];
    
    UISwitch *sp1State = [[UISwitch alloc] initWithFrame:CGRectMake(48 , 78, 50, 30)];
    [sp1State setOn:[_special1[@"state"] intValue]];
    
    if([_special1[@"state"] intValue]){
        sp1.layer.borderWidth = 2.5f;
    }
    
    [sp1State addTarget:self action:@selector(enableSchedule:) forControlEvents:UIControlEventValueChanged];
    sp1State.tag = 2;
    sp1State.userInteractionEnabled = NO;
    [self.view addSubview:sp1State];
    
    UIButton *sp1StartDate = [[UIButton alloc] initWithFrame:CGRectMake(110, 128.6, 91, 31)];
    [sp1StartDate setTitle:[self convertNSDateToString:[_special1[@"startMonth"] intValue] :[_special1[@"startDate"] intValue]] forState:UIControlStateNormal];
    [sp1StartDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [sp1StartDate setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sp1StartDate.tag = 3;
    [sp1StartDate addTarget:self action:@selector(tagCalendar:) forControlEvents:UIControlEventTouchUpInside];
    sp1StartDate.userInteractionEnabled = NO;
    [self.view addSubview:sp1StartDate];
    
    
    UIButton *sp1EndDate = [[UIButton alloc] initWithFrame:CGRectMake(235, 128.6, 91, 31)];
    [sp1EndDate setTitle:[self convertNSDateToString:[_special1[@"endMonth"] intValue] :[_special1[@"endDate"] intValue]] forState:UIControlStateNormal];
    [sp1EndDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [sp1EndDate setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sp1EndDate.tag = 4;
    [sp1EndDate addTarget:self action:@selector(tagCalendar:) forControlEvents:UIControlEventTouchUpInside];
    sp1EndDate.userInteractionEnabled = NO;
    [self.view addSubview:sp1EndDate];
    
    UIView *hyphen1 = [[UIView alloc] initWithFrame:CGRectMake(214, 143, 10, 1)];
    hyphen1.backgroundColor = [UIColor whiteColor];
    hyphen1.tag = 13;
    [self.view addSubview:hyphen1];
    

    UIButton *sp2 = [[UIButton alloc] initWithFrame:CGRectMake(128, 215.6, 50, 50)];
    [sp2 setImage:[UIImage imageNamed:@"calSched2"] forState:UIControlStateNormal];
    sp2.userInteractionEnabled = NO;
    sp2.tag = 5;
    sp2.layer.cornerRadius = 25;
    [[sp2 layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:52/255.0 blue:47/255.0 alpha:0.85].CGColor];
    [self.view addSubview:sp2];
    
    UISwitch *sp2State = [[UISwitch alloc] initWithFrame:CGRectMake(48, 225, 45, 45)];
    [sp2State setOn:[_special2[@"state"] intValue]];
    if ([_special2[@"state"] intValue]) {
        sp2.layer.borderWidth = 2.5f;
    }
    [sp2State addTarget:self action:@selector(enableSchedule:) forControlEvents:UIControlEventValueChanged];
    sp2State.tag = 6;
    sp2State.userInteractionEnabled = NO;
    [self.view addSubview:sp2State];
    
    UIButton *sp2StartDate = [[UIButton alloc] initWithFrame:CGRectMake(110, 276.2, 91, 31)];
    [sp2StartDate setTitle:[self convertNSDateToString:[_special2[@"startMonth"] intValue] :[_special2[@"startDate"] intValue]] forState:UIControlStateNormal];
    [sp2StartDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [sp2StartDate setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sp2StartDate.tag = 7;
    [sp2StartDate addTarget:self action:@selector(tagCalendar:) forControlEvents:UIControlEventTouchUpInside];
    sp2StartDate.userInteractionEnabled = NO;
    [self.view addSubview:sp2StartDate];
    
    UIButton *sp2EndDate = [[UIButton alloc] initWithFrame:CGRectMake(235, 276.2, 91, 31)];
    [sp2EndDate setTitle:[self convertNSDateToString:[_special2[@"endMonth"] intValue] :[_special2[@"endDate"] intValue]] forState:UIControlStateNormal];
    [sp2EndDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [sp2EndDate setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sp2EndDate.tag = 8;
    [sp2EndDate addTarget:self action:@selector(tagCalendar:) forControlEvents:UIControlEventTouchUpInside];
    sp2EndDate.userInteractionEnabled = NO;
    [self.view addSubview:sp2EndDate];
    
    UIView *hyphen2 = [[UIView alloc] initWithFrame:CGRectMake(214, 291, 10, 1)];
    hyphen2.backgroundColor = [UIColor whiteColor];
    hyphen2.tag = 14;
    [self.view addSubview:hyphen2];
    
    
    
    
    
    UIButton *sp3 = [[UIButton alloc] initWithFrame:CGRectMake(128, 363.2, 50, 50)];
    [sp3 setImage:[UIImage imageNamed:@"calSched3"] forState:UIControlStateNormal];
    sp3.userInteractionEnabled = NO;
    sp3.tag = 9;
    sp3.layer.cornerRadius = 25;
    [[sp3 layer] setBorderColor:[UIColor colorWithRed:57/255.0 green:181/255.0 blue:74/255.0 alpha:0.85].CGColor];
    [self.view addSubview:sp3];
    
    UISwitch *sp3State = [[UISwitch alloc] initWithFrame:CGRectMake(48, 372, 45, 45)];
    [sp3State addTarget:self action:@selector(enableSchedule:) forControlEvents:UIControlEventValueChanged];
    sp3State.tag = 10;
    [sp3State setOn:[_special3[@"state"] intValue]];
    if ([_special3[@"state"] intValue]) {
        sp3.layer.borderWidth = 2.5f;
    }
    sp3State.userInteractionEnabled = NO;
    [self.view addSubview:sp3State];
    
    UIButton *sp3StartDate = [[UIButton alloc] initWithFrame:CGRectMake(110, 423.8, 91, 31)];
    [sp3StartDate setTitle:[self convertNSDateToString:[_special3[@"startMonth"] intValue] :[_special3[@"startDate"] intValue]] forState:UIControlStateNormal];
    [sp3StartDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [sp3StartDate setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sp3StartDate.tag = 11;
    [sp3StartDate addTarget:self action:@selector(tagCalendar:) forControlEvents:UIControlEventTouchUpInside];
    sp3StartDate.userInteractionEnabled = NO;
    [self.view addSubview:sp3StartDate];
    
    UIButton *sp3EndDate = [[UIButton alloc] initWithFrame:CGRectMake(235, 423.8, 91, 31)];
    [sp3EndDate setTitle:[self convertNSDateToString:[_special3[@"endMonth"] intValue] :[_special3[@"endDate"] intValue]] forState:UIControlStateNormal];
    [sp3EndDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [sp3EndDate setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sp3EndDate.tag = 12;
    [sp3EndDate addTarget:self action:@selector(tagCalendar:) forControlEvents:UIControlEventTouchUpInside];
    sp3EndDate.userInteractionEnabled = NO;
    [self.view addSubview:sp3EndDate];
    
    UIView *hyphen3 = [[UIView alloc] initWithFrame:CGRectMake(214, 439, 10, 1)];
    hyphen3.backgroundColor = [UIColor whiteColor];
    hyphen3.tag = 15;
    [self.view addSubview:hyphen3];
    
    UIView *vewrticalLine = [[UIView alloc] initWithFrame:CGRectMake(355, 0, 1, 720)];
    vewrticalLine.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    vewrticalLine.tag = 16;
    [self.view addSubview:vewrticalLine];
}


-(void)tagCalendar:(UIButton *)sender{
    
    [_calendarScedule removeFromSuperview];
    [self createCalendarView:(int)sender.tag];

}

-(void)enableStartEnd:(UIButton *)sender
{
    [_calendarScedule removeFromSuperview];
    [self createCalendarView:0];
    
    
    UIButton *startDate = (UIButton *)[self.view viewWithTag:3];
    
    if (startDate.isUserInteractionEnabled) {
        
        for (int i =2; i<13; i +=4) {
            UISwitch *spState = (UISwitch *)[self.view viewWithTag:i];
            spState.userInteractionEnabled = NO;
            
            UIButton *startDate = (UIButton *)[self.view viewWithTag:i+1];
            startDate.userInteractionEnabled = NO;
            [startDate setBackgroundImage:nil forState:UIControlStateNormal];
            [startDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
            
            UIButton *endDate = (UIButton *)[self.view viewWithTag:i + 2];
            endDate.userInteractionEnabled = NO;
            [endDate setBackgroundImage:nil forState:UIControlStateNormal];
            [endDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
            
            
            
        }
        [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
        
        _cancelButton.alpha = 0;
        NSLog(@"end month %i, selected %d", [_special1[@"endMonth"] intValue] - 12 * ([_special1[@"endMonth"] intValue]/12), [_special1[@"endMonth"] intValue]);
        
        _special1[@"startMonth"] = [NSNumber numberWithInt:[_special1[@"startMonth"] intValue] > 12 ? [_special1[@"endMonth"] intValue] - 12 * ([_special1[@"endMonth"] intValue]/12) : [_special1[@"startMonth"] intValue]];
        
        _special1[@"endMonth"] = [NSNumber numberWithInt:[_special1[@"endMonth"] intValue] > 12 ? [_special1[@"endMonth"] intValue] - 12 * ([_special1[@"endMonth"] intValue]/12) : [_special1[@"endMonth"] intValue]];
        
        _special2[@"startMonth"] = [NSNumber numberWithInt:[_special2[@"startMonth"] intValue] > 12 ? [_special2[@"startMonth"] intValue] - (12 * [_special2[@"startMonth"] intValue]/12) : [_special2[@"startMonth"] intValue]];
        _special2[@"endMonth"] = [NSNumber numberWithInt:[_special2[@"endMonth"] intValue] > 12 ? [_special2[@"endMonth"] intValue] - 12 * ([_special2[@"endMonth"] intValue]/12) : [_special2[@"endMonth"] intValue]];
        NSLog(@"sp3 start month %i", [_special3[@"startMonth"] intValue]);
        _special3[@"startMonth"] = [NSNumber numberWithInt:[_special3[@"startMonth"] intValue] > 12 ? [_special3[@"startMonth"] intValue] - (12 * [_special3[@"startMonth"] intValue]/12) : [_special3[@"startMonth"] intValue]];
        _special3[@"endMonth"] = [NSNumber numberWithInt:[_special3[@"endMonth"] intValue] > 12 ? [_special3[@"endMonth"] intValue] - 12 * ([_special3[@"endMonth"] intValue]/12) : [_special3[@"endMonth"] intValue]];
        
        
        _schedule = [[NSMutableArray alloc] initWithObjects:_special1, _special2, _special3, nil];
        
        
        
        if (_special1) {
            NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/writeTimeTable", _pass, _ip];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_schedule options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *escapedDataString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *strURL = [NSString stringWithFormat:@"%@?%@", fullpath, escapedDataString]; 
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
            [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"SAVED CALENDER SETTINGS");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
            }];
            
            
            NSLog(@"schedule %@", _schedule);
        }
        
    } else {
        for (int i =2; i<13; i +=4) {
            UISwitch *spState = (UISwitch *)[self.view viewWithTag:i];
            spState.userInteractionEnabled = YES;
            
            
            UIButton *startDate = (UIButton *)[self.view viewWithTag:i + 1];
            startDate.userInteractionEnabled = YES;
            [startDate setBackgroundImage:[UIImage imageNamed:@"datebutton"] forState:UIControlStateNormal];
            [startDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
            
            
            UIButton *endDate = (UIButton *)[self.view viewWithTag:i + 2];
            endDate.userInteractionEnabled = YES;
            [endDate setBackgroundImage:[UIImage imageNamed:@"datebutton"] forState:UIControlStateNormal];
            [endDate.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
            
            
            
        }
        [_editButton setTitle:_langData[@"SAVE"] forState:UIControlStateNormal];
        
        
        _cancelButton.alpha = 1;
        
    }
    
    
}


-(void)enableSchedule:(UISwitch *)sender{
    
    UIButton *button = (UIButton *)[self.view viewWithTag:sender.tag - 1];
    
    if(sender.on){
        
        button.layer.borderWidth = 2.5f;
        
    }else{
        
        button.layer.borderWidth = 0.0f;
        
    }
    
    if (sender.tag == 2){
        
        _special1[@"state"] = [NSNumber numberWithInt:sender.on];
        
    }else if (sender.tag == 6){
        
        _special2[@"state"] = [NSNumber numberWithInt:sender.on];
        
    }else if (sender.tag == 10){
        
        _special3[@"state"] = [NSNumber numberWithInt:sender.on];
        
    }
    
    [_calendarScedule reloadData];
    
}

-(void)populateCalendar
{
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _docDir = [_paths objectAtIndex:0];
    _filePath = [_docDir stringByAppendingPathComponent:@"/WET/timeTable.txt"];
    
    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readTimeTable", _pass, _ip];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        _schedule = [[NSMutableArray alloc] initWithArray:responseObject];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        [jsonString writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        
        _special1 = [[NSMutableDictionary alloc] initWithDictionary:_schedule[0]];
        _special2 = [[NSMutableDictionary alloc] initWithDictionary:_schedule[1]];
        _special3 = [[NSMutableDictionary alloc] initWithDictionary:_schedule[2]];
        
        NSLog(@"\n SPECIAL 1\n%@ \n SPECIAL 2\n %@ \n SPECIAL 3\n %@", _special1, _special2, _special3);
        
        
        [self createCalendarSettings];
        [self createCalendarView:0];
        
        _editButton.alpha = 1;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        
    }];
    
}

-(void)cancelChanges
{
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _docDir = [_paths objectAtIndex:0];
    _filePath = [_docDir stringByAppendingPathComponent:@"/WET/timeTable.txt"];
    
    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readTimeTable", _pass, _ip];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_calendarScedule removeFromSuperview];
        for (int i = 1; i<17; i++) {
            [[self.view viewWithTag:i] removeFromSuperview];
        }
        _cancelButton.alpha = 0;
        
        
        
        _schedule = [[NSMutableArray alloc] initWithArray:responseObject];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        [jsonString writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        
        _special1 = [[NSMutableDictionary alloc] initWithDictionary:_schedule[0]];
        _special2 = [[NSMutableDictionary alloc] initWithDictionary:_schedule[1]];
        _special3 = [[NSMutableDictionary alloc] initWithDictionary:_schedule[2]];
        
        NSLog(@"\n SPECIAL 1\n%@ \n SPECIAL 2\n %@ \n SPECIAL 3\n %@", _special1, _special2, _special3);
        
        
        
        
        
        
        [self createCalendarSettings];
        [self createCalendarView:0];
        
        [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        
    }];
    
}
-(void)calendarView:(RDVCalendarView *)calendarView didSelectCellAtIndex:(NSInteger)index
{
    _invalidTime.alpha = 0;
    
    int sp1StartMonth = [_special1[@"startMonth"] intValue];
    int sp1StartDay = [_special1[@"startDate"] intValue];
    int sp1EndMonth = [_special1[@"endMonth"] intValue];
    int sp1EndDay = [_special1[@"endDate"] intValue];
    
    int sp2StartMonth = [_special2[@"startMonth"] intValue];
    int sp2StartDay = [_special2[@"startDate"] intValue];
    int sp2EndMonth = [_special2[@"endMonth"] intValue];
    int sp2EndDay = [_special2[@"endDate"] intValue];
    
    int sp3StartMonth = [_special3[@"startMonth"] intValue];
    int sp3StartDay = [_special3[@"startDate"] intValue];
    int sp3EndMonth = [_special3[@"endMonth"] intValue];
    int sp3EndDay = [_special3[@"endDate"] intValue];
    
    _dateFormatter = [[NSDateFormatter alloc]init];
    
    _dateFormatter.dateFormat = @"M";
    _selectedMonth = [[NSString stringWithFormat:@"%@", [_dateFormatter stringFromDate:_calendarScedule.selectedDate]] intValue];
    int currentMonth = [[NSString stringWithFormat:@"%@", [_dateFormatter stringFromDate:[[NSDate alloc]init]]] intValue];
    
    
    _dateFormatter.dateFormat = @"d";
    _selectedDay = [[NSString stringWithFormat:@"%@", [_dateFormatter stringFromDate:_calendarScedule.selectedDate]] intValue];
    int currentDay = [[NSString stringWithFormat:@"%@", [_dateFormatter stringFromDate:[[NSDate alloc]init]]] intValue];
    NSLog(@"selected month %i", _selectedMonth);
    
    _dateFormatter.dateFormat = @"YYYY";
    int currentYear = [[NSString stringWithFormat:@"%@", [_dateFormatter stringFromDate:[[NSDate alloc]init]]] intValue];
    
    int selectedYear = [[NSString stringWithFormat:@"%@", [_dateFormatter stringFromDate:_calendarScedule.selectedDate]] intValue];
    
    NSLog(@"current year: %i, selected year: %i", currentYear, selectedYear);
    
    
    if (selectedYear > currentYear) {
        if (_selectedMonth == 12) {
            _selectedMonth = 0;
        }
        _selectedMonth += 12 * (selectedYear - currentYear);
    }
    
    
    
    if (selectedYear > (currentYear + 1)) {
        _invalidTime.alpha = 1;
        [_calendarScedule reloadData];
        NSLog(@"decemebr bad days 1 ");
        return;
    } else if ((selectedYear == (currentYear + 1)) && (_selectedMonth >= (currentMonth + 12)) && (_selectedDay >= currentDay + 1)&& (_selectedMonth == 12))  {
        _invalidTime.alpha = 1;
        [_calendarScedule reloadData];
        NSLog(@"decemebr bad days 2.5");
        return;
    }
    
    
    if (calendarView.tag > 100) {
        UIButton *buttonDate = (UIButton *)[self.view viewWithTag:calendarView.tag - 100];
        
        if (calendarView.tag == 103) {
            
            if ((_selectedMonth > sp1EndMonth)) {
                _invalidTime.alpha = 1;
            } else if ((_selectedMonth == sp1EndMonth) && (_selectedDay > sp1EndDay)  ) {
                _invalidTime.alpha = 1;
            } else {
                _special1[@"startDate"] = [NSNumber numberWithInt: (int)_selectedDay];
                _special1[@"startMonth"] = [NSNumber numberWithInt: (int)_selectedMonth];
                [buttonDate setTitle:[self convertNSDateToString:_selectedMonth :_selectedDay] forState:UIControlStateNormal];
                
            }
            
        } else if (calendarView.tag == 104) {
            
            if ((_selectedMonth < sp1StartMonth)) {
                _invalidTime.alpha = 1;
            } else if ((_selectedMonth == sp1StartMonth) && (_selectedDay < sp1StartDay)  ) {
                _invalidTime.alpha = 1;
            } else {
                _special1[@"endDate"] = [NSNumber numberWithInt: (int)_selectedDay];
                _special1[@"endMonth"] = [NSNumber numberWithInt: (int)_selectedMonth];
                [buttonDate setTitle:[self convertNSDateToString:_selectedMonth :_selectedDay] forState:UIControlStateNormal];
                
            }
            
            
        } else if (calendarView.tag == 107) {
            
            if ((_selectedMonth > sp2EndMonth)) {
                _invalidTime.alpha = 1;
            } else if ((_selectedMonth == sp2EndMonth) && (_selectedDay > sp2EndDay)  ) {
                _invalidTime.alpha = 1;
            } else {
                _special2[@"startDate"] = [NSNumber numberWithInt: (int)_selectedDay];
                _special2[@"startMonth"] = [NSNumber numberWithInt: (int)_selectedMonth];
                [buttonDate setTitle:[self convertNSDateToString:_selectedMonth :_selectedDay] forState:UIControlStateNormal];
                
            }
            
            
        } else if (calendarView.tag == 108) {
            
            if ((_selectedMonth < sp2StartMonth)) {
                _invalidTime.alpha = 1;
            } else if ((_selectedMonth == sp2StartMonth) && (_selectedDay < sp2StartDay)  ) {
                _invalidTime.alpha = 1;
            } else {
                _special2[@"endDate"] = [NSNumber numberWithInt: (int)_selectedDay];
                _special2[@"endMonth"] = [NSNumber numberWithInt: (int)_selectedMonth];
                [buttonDate setTitle:[self convertNSDateToString:_selectedMonth :_selectedDay] forState:UIControlStateNormal];
                
            }
            
        } else if (calendarView.tag == 111) {
            if ((_selectedMonth > sp3EndMonth)) {
                _invalidTime.alpha = 1;
            } else if ((_selectedMonth == sp3EndMonth) && (_selectedDay > sp3EndDay)  ) {
                _invalidTime.alpha = 1;
            } else {
                _special3[@"startDate"] = [NSNumber numberWithInt: (int)_selectedDay];
                _special3[@"startMonth"] = [NSNumber numberWithInt: (int)_selectedMonth];
                [buttonDate setTitle:[self convertNSDateToString:_selectedMonth :_selectedDay] forState:UIControlStateNormal];
                
            }
            
        } else if (calendarView.tag == 112) {
            
            if ((_selectedMonth < sp3StartMonth)) {
                _invalidTime.alpha = 1;
            } else if ((_selectedMonth == sp3StartMonth) && (_selectedDay < sp3StartDay)  ) {
                _invalidTime.alpha = 1;
            } else {
                _special3[@"endDate"] = [NSNumber numberWithInt: (int)_selectedDay];
                _special3[@"endMonth"] = [NSNumber numberWithInt: (int)_selectedMonth];
                [buttonDate setTitle:[self convertNSDateToString:_selectedMonth :_selectedDay] forState:UIControlStateNormal];
                
            }
            
            
        }
        
    }
    
    [_calendarScedule reloadData];
}

-(NSString *)convertNSDateToString:(int)monthNum :(int)dayNum{
    
    NSString *month;
    
    if ((monthNum % 12) == 1){
        month = _langData[@"JANUARY"];
    }else if ((monthNum % 12) == 2){
        month = _langData[@"FEBRUARY"];
    }else if ((monthNum % 12) == 3){
        month = _langData[@"MARCH"];
    }else if ((monthNum % 12) == 4){
        month = _langData[@"APRIL"];
    }else if ((monthNum % 12) == 5){
        month = _langData[@"MAY"];
    }else if ((monthNum % 12) == 6){
        month = _langData[@"JUNE"];
    }else if ((monthNum % 12) == 7){
        month = _langData[@"JULY"];
    }else if ((monthNum % 12) == 8){
        month = _langData[@"AUGUST"];
    }else if ((monthNum % 12) == 9){
        month = _langData[@"SEPTEMBER"];
    }else if ((monthNum % 12) == 10){
        month = _langData[@"OCTOBER"];
    }else if ((monthNum % 12) == 11){
        month = _langData[@"NOVEMBER"];
    }else if (((monthNum % 12) == 0) || (monthNum == 12)){
        month = _langData[@"DECEMBER"];
    }
    
    NSString *newTitle = [NSString stringWithFormat:@"%@ %d", month, dayNum];
    return newTitle;
    
}

- (void)calendarView:(RDVCalendarView *)calendarView configureDayCell:(RDVCalendarDayCell *)dayCell atIndex:(NSInteger)index {
    
    int sp1StartMonth = [_special1[@"startMonth"] intValue];
    int sp1StartDay = [_special1[@"startDate"] intValue];
    int sp1EndMonth = [_special1[@"endMonth"] intValue];
    int sp1EndDay = [_special1[@"endDate"] intValue];
    
    int sp2StartMonth = [_special2[@"startMonth"] intValue];
    int sp2StartDay = [_special2[@"startDate"] intValue];
    int sp2EndMonth = [_special2[@"endMonth"] intValue];
    int sp2EndDay = [_special2[@"endDate"] intValue];
    
    int sp3StartMonth = [_special3[@"startMonth"] intValue];
    int sp3StartDay = [_special3[@"startDate"] intValue];
    int sp3EndMonth = [_special3[@"endMonth"] intValue];
    int sp3EndDay = [_special3[@"endDate"] intValue];
    
    int currentMonth = (int)_calendarScedule.month.month;
    if (currentMonth > 12) {

    }
    
    if ((sp1StartMonth > sp1EndMonth)) {
        sp1EndMonth += 12;
    }
    
    if ((sp2StartMonth > sp2EndMonth)) {
        sp2EndMonth += 12;
    }
    
    if ((sp3StartMonth > sp3EndMonth)) {
        sp3EndMonth += 12;
    }
    
    
    UIColor *blue = [UIColor colorWithRed:0/255.0 green:154/255.0 blue:255/255.0 alpha:85.0];
    UIColor *orange = [UIColor colorWithRed:236/255.0 green:52/255.0 blue:47/255.0 alpha:0.85];
    UIColor *green = [UIColor colorWithRed:57/255.0 green:181/255.0 blue:74/255.0 alpha:0.85];
    
    
    
    if (([_special1[@"state"] intValue] == 1) && ([_special2[@"state"] intValue] == 1) && ([_special3[@"state"] intValue] == 1)) {
        
        if ( (sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) &&  (sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth)) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if (((sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth)&& (sp1StartMonth == currentMonth)) || ((sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth)&& (sp2StartMonth == currentMonth))) {
            
            
            if ((sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else if (index < sp2EndDay) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                    dayCell.backgroundColor = blue;
                } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth)) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if ((sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else if (index < sp2EndDay) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                    dayCell.backgroundColor = blue;
                } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth)) {
                    dayCell.backgroundColor = blue;
                    
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
            } else if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth )) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
            } else if ((sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth )) {
                    dayCell.backgroundColor = orange;
                } else if (index < sp1EndDay) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            }
            
            
        } else if (((sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth)&& (sp3StartMonth == currentMonth)) || ((sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth)&& (sp2StartMonth == currentMonth))) {
            
            
            if ((sp2StartMonth == currentMonth) &&(sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
                if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                    dayCell.backgroundColor = orange;
                } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if ((sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
                if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                    dayCell.backgroundColor = green;
                } else if (index < sp2EndDay) {
                    dayCell.backgroundColor = orange;
                } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
            } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
                if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth )) {
                    dayCell.backgroundColor = orange;
                } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
            } else if ((sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
                if (index < sp3EndDay) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth )) {
                    dayCell.backgroundColor = orange;
                } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
                
            }
            
        } else if (((sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth)&& (sp3StartMonth == currentMonth)) || ((sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth)&& (sp1StartMonth == currentMonth))) {
            
            if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
                if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                    dayCell.backgroundColor = green;
                } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if ((sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
                if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                    dayCell.backgroundColor = green;
                } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                    dayCell.backgroundColor = green;
                } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else if (index < sp1EndDay) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
            } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
                if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                    dayCell.backgroundColor = green;
                } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                    dayCell.backgroundColor = blue;
                } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth )) {
                    dayCell.backgroundColor = blue;
                    
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
            } else if ((sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
                if (index < sp3EndDay) {
                    dayCell.backgroundColor = green;
                } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                    dayCell.backgroundColor = blue;
                } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth )) {
                    dayCell.backgroundColor = blue;
                    
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
                
            }
            
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth)) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay) && (sp1StartMonth == sp1EndMonth) && (sp1StartMonth == currentMonth))) {
                dayCell.backgroundColor = blue;
            } else if (((index >= sp1StartDay - 1) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth))) {
                dayCell.backgroundColor = blue;
            } else if ((sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
                dayCell.backgroundColor = blue;
            } else if ((sp1EndMonth == currentMonth) && (index < sp1EndDay) && (sp1StartMonth < currentMonth)) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth == currentMonth) && (sp2StartMonth < currentMonth) && (sp2EndMonth > currentMonth)) {
            if ((index < sp3EndDay ))  {
                dayCell.backgroundColor = green;
            } else if (index <= 31) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay) && (sp1StartMonth == sp1EndMonth) && (sp1StartMonth == currentMonth))) {
                dayCell.backgroundColor = blue;
            } else if (((index >= sp1StartDay - 1) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth))) {
                dayCell.backgroundColor = blue;
            } else if ((sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
                dayCell.backgroundColor = blue;
            } else if ((sp1EndMonth == currentMonth) && (index < sp1EndDay) && (sp1StartMonth < currentMonth)) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp2EndMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay) && (sp1StartMonth == sp1EndMonth) && (sp1StartMonth == currentMonth))) {
                dayCell.backgroundColor = blue;
            } else if (((index >= sp1StartDay - 1) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth))) {
                dayCell.backgroundColor = blue;
            } else if ((sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
                dayCell.backgroundColor = blue;
            } else if ((sp1EndMonth == currentMonth) && (index < sp1EndDay) && (sp1StartMonth < currentMonth)) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth)) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay) && (sp2StartMonth == sp2EndMonth) && (sp2StartMonth == currentMonth))) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp2StartDay - 1) && (sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth))) {
                dayCell.backgroundColor = orange;
            } else if ((sp2StartMonth < currentMonth) && (sp2EndMonth > currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if ((sp2EndMonth == currentMonth) && (index < sp2EndDay) && (sp2StartMonth < currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth == currentMonth) && (sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
            if ((index < sp3EndDay ))  {
                dayCell.backgroundColor = green;
            } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay) && (sp2StartMonth == sp2EndMonth) && (sp2StartMonth == currentMonth))) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp2StartDay - 1) && (sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth))) {
                dayCell.backgroundColor = orange;
            } else if ((sp2StartMonth < currentMonth) && (sp2EndMonth > currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if ((sp2EndMonth == currentMonth) && (index < sp2EndDay) && (sp2StartMonth < currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if (index <= 31) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay) && (sp2StartMonth == sp2EndMonth) && (sp2StartMonth == currentMonth))) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp2StartDay - 1) && (sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth))) {
                dayCell.backgroundColor = orange;
            } else if ((sp2StartMonth < currentMonth) && (sp2EndMonth > currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if ((sp2EndMonth == currentMonth) && (index < sp2EndDay) && (sp2StartMonth < currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth)) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay) && (sp3StartMonth == sp3EndMonth) && (sp3StartMonth == currentMonth))) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp3StartDay - 1) && (sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth))) {
                dayCell.backgroundColor = green;
            } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if ((sp3EndMonth == currentMonth) && (index < sp3EndDay) && (sp3StartMonth < currentMonth)) {
                dayCell.backgroundColor = green;
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2StartMonth < currentMonth) && (sp2EndMonth == currentMonth) && (sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay) && (sp3StartMonth == sp3EndMonth) && (sp3StartMonth == currentMonth))) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp3StartDay - 1) && (sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth))) {
                dayCell.backgroundColor = green;
            } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if ((sp3EndMonth == currentMonth) && (index < sp3EndDay) && (sp3StartMonth < currentMonth)) {
                dayCell.backgroundColor = green;
            } else if ((index < sp2EndDay ))  {
                dayCell.backgroundColor = orange;
            } else if (index <= 31) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay) && (sp3StartMonth == sp3EndMonth) && (sp3StartMonth == currentMonth))) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp3StartDay - 1) && (sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth))) {
                dayCell.backgroundColor = green;
            } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if ((sp3EndMonth == currentMonth) && (index < sp3EndDay) && (sp3StartMonth < currentMonth)) {
                dayCell.backgroundColor = green;
            } else if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth >= (currentMonth + 1))) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                dayCell.backgroundColor = orange;
            } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth )) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth >= (currentMonth + 1))) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else  if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
            
            if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth)) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth == currentMonth) && (sp2StartMonth < currentMonth) && (sp2EndMonth > currentMonth)) {
            if ((index < sp3EndDay ))  {
                dayCell.backgroundColor = green;
            } else if (index <= 31) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp2EndMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth >= (currentMonth + 1))) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                dayCell.backgroundColor = blue;
            } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth )) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth >= (currentMonth + 1))) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
            if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth)) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth == currentMonth) && (sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
            if ((index < sp3EndDay ))  {
                dayCell.backgroundColor = green;
            } else if (index <= 31) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth >= (currentMonth + 1))) {
            if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                dayCell.backgroundColor = blue;
            } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth )) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth >= (currentMonth + 1))) {
            if (index >= sp2StartDay - 1) {
                
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
            
            if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                dayCell.backgroundColor = orange;
            } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth)) {
            if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2StartMonth < currentMonth) && (sp2EndMonth == currentMonth) && (sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
            if ((index < sp2EndDay ))  {
                dayCell.backgroundColor = orange;
            } else if (index <= 31) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
            
            
        } else  if ( sp3StartMonth == currentMonth) {
            if (sp3StartMonth == sp3EndMonth) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if (currentMonth == sp3EndMonth) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp3StartMonth < currentMonth) && (currentMonth < sp3EndMonth)) ) {
            dayCell.backgroundColor = green;
            
            
            
            
            
        } else if ( sp2StartMonth == currentMonth) {
            if (sp2StartMonth == sp2EndMonth) {
                if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp2EndMonth) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp2StartMonth < currentMonth) && (currentMonth < sp2EndMonth)) ) {
            dayCell.backgroundColor = orange;
            
            
            
        } else if ( sp1StartMonth == currentMonth) {
            if (sp1StartMonth == sp1EndMonth) {
                if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp1EndMonth) {
            if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp1StartMonth < currentMonth) && (currentMonth < sp1EndMonth)) ) {
            dayCell.backgroundColor = blue;
            
            
            
            
            
            
            
            
            
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth)) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth)) {
            if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
        }
        
        
        
        
        
        
        
        
        
    } else if (([_special1[@"state"] intValue] == 1) && ([_special2[@"state"] intValue] == 1)) {
        if ( (sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth)) {
            if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth >= (currentMonth + 1))) {
            if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                dayCell.backgroundColor = blue;
            } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth )) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth >= (currentMonth + 1))) {
            if (index >= sp2StartDay - 1) {
                
                dayCell.backgroundColor = orange;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp1EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
            
            if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                dayCell.backgroundColor = orange;
            } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth)) {
                dayCell.backgroundColor = orange;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth)) {
            if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2StartMonth < currentMonth) && (sp2EndMonth == currentMonth) && (sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
            if ((index < sp2EndDay ))  {
                dayCell.backgroundColor = orange;
            } else if (index <= 31) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ( sp2StartMonth == currentMonth) {
            if (sp2StartMonth == sp2EndMonth) {
                if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp2EndMonth) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp2StartMonth < currentMonth) && (currentMonth < sp2EndMonth)) ) {
            dayCell.backgroundColor = orange;
            
        } else if ( sp1StartMonth == currentMonth) {
            if (sp1StartMonth == sp1EndMonth) {
                if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp1EndMonth) {
            if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp1StartMonth < currentMonth) && (currentMonth < sp1EndMonth)) ) {
            dayCell.backgroundColor = blue;
            
            
            
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
            
        }
        
        
        
        
    } else if (([_special1[@"state"] intValue] == 1) && ([_special3[@"state"] intValue] == 1)) {
        if ( (sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth)) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth >= (currentMonth + 1))) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp1StartMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp1StartDay - 1) && (index < sp1EndDay)) {
                dayCell.backgroundColor = blue;
            } else if ((index >= sp1StartDay - 1) && (sp1EndMonth > currentMonth )) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if ((sp1StartMonth == currentMonth) && (sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth >= (currentMonth + 1))) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp1EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
            if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth) && (sp1StartMonth == currentMonth) && (sp1EndMonth > currentMonth)) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth == currentMonth) && (sp1StartMonth < currentMonth) && (sp1EndMonth > currentMonth)) {
            if ((index < sp3EndDay ))  {
                dayCell.backgroundColor = green;
            } else if (index <= 31) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp1EndMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ( sp3StartMonth == currentMonth) {
            if (sp3StartMonth == sp3EndMonth) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp3EndMonth) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp3StartMonth < currentMonth) && (currentMonth < sp3EndMonth)) ) {
            dayCell.backgroundColor = green;
            
        } else if ( sp1StartMonth == currentMonth) {
            if (sp1StartMonth == sp1EndMonth) {
                if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp1EndMonth) {
            if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp1StartMonth < currentMonth) && (currentMonth < sp1EndMonth)) ) {
            dayCell.backgroundColor = blue;
            
            
            
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
            
        }
        
        
        
        
        
        
    } else if (([_special2[@"state"] intValue] == 1) && ([_special3[@"state"] intValue] == 1)) {
        if ( (sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth)) {
            
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth >= (currentMonth + 1))) {
            if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                dayCell.backgroundColor = green;
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp2StartMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp2StartDay - 1) && (index < sp2EndDay)) {
                dayCell.backgroundColor = orange;
            } else if ((index >= sp2StartDay - 1) && (sp2EndMonth > currentMonth )) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2StartMonth == currentMonth) && (sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth) && (sp3EndMonth >= (currentMonth + 1))) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else  if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp2EndMonth == currentMonth) && (sp3StartMonth == currentMonth)) {
            
            if ((index >= sp3StartDay - 1) && (index < sp3EndDay)) {
                dayCell.backgroundColor = green;
            } else if ((index >= sp3StartDay - 1) && (sp3EndMonth > currentMonth)) {
                dayCell.backgroundColor = green;
            } else if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
            
        } else if ((sp3StartMonth == currentMonth) && (sp3EndMonth > currentMonth) && (sp2StartMonth == currentMonth) && (sp2EndMonth > currentMonth)) {
            if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3StartMonth < currentMonth) && (sp3EndMonth == currentMonth) && (sp2StartMonth < currentMonth) && (sp2EndMonth > currentMonth)) {
            if ((index < sp3EndDay ))  {
                dayCell.backgroundColor = green;
            } else if (index <= 31) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
        } else if ((sp3EndMonth == currentMonth) && (sp2EndMonth == currentMonth)) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
            
        } else if ( sp3StartMonth == currentMonth) {
            if (sp3StartMonth == sp3EndMonth) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp3EndMonth) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp3StartMonth < currentMonth) && (currentMonth < sp3EndMonth)) ) {
            dayCell.backgroundColor = green;
            
        } else if ( sp2StartMonth == currentMonth) {
            if (sp2StartMonth == sp2EndMonth) {
                if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = green;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp2EndMonth) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp2StartMonth < currentMonth) && (currentMonth < sp2EndMonth)) ) {
            dayCell.backgroundColor = orange;
            
            
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
            
        }
        
        
        
        
        
        
        
        
    } else if ([_special3[@"state"] intValue] == 1) {
        if ( sp3StartMonth == currentMonth) {
            if (sp3StartMonth == sp3EndMonth) {
                if (((index >= sp3StartDay - 1) && (index < sp3EndDay))) {
                    dayCell.backgroundColor = green;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp3StartDay - 1) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp3EndMonth) {
            if (index < sp3EndDay) {
                dayCell.backgroundColor = green;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp3StartMonth < currentMonth) && (currentMonth < sp3EndMonth)) ) {
            dayCell.backgroundColor = green;
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
        }
        
        
    } else if ([_special2[@"state"] intValue] == 1) {
        if ( sp2StartMonth == currentMonth) {
            if (sp2StartMonth == sp2EndMonth) {
                if (((index >= sp2StartDay - 1) && (index < sp2EndDay))) {
                    dayCell.backgroundColor = orange;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp2StartDay - 1) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp2EndMonth) {
            if (index < sp2EndDay) {
                dayCell.backgroundColor = orange;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp2StartMonth < currentMonth) && (currentMonth < sp2EndMonth)) ) {
            dayCell.backgroundColor = orange;
            
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
        }
    } else if ([_special1[@"state"] intValue] == 1) {
        if ( sp1StartMonth == currentMonth) {
            if (sp1StartMonth == sp1EndMonth) {
                if (((index >= sp1StartDay - 1) && (index < sp1EndDay))) {
                    dayCell.backgroundColor = blue;
                } else {
                    dayCell.backgroundColor = [UIColor clearColor];
                }
                
            } else if (index >= sp1StartDay - 1) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (currentMonth == sp1EndMonth) {
            if (index < sp1EndDay) {
                dayCell.backgroundColor = blue;
            } else {
                dayCell.backgroundColor = [UIColor clearColor];
            }
            
        } else if (((sp1StartMonth < currentMonth) && (currentMonth < sp1EndMonth)) ) {
            dayCell.backgroundColor = blue;
            
        } else {
            dayCell.backgroundColor = [UIColor clearColor];
        }
        
        
    } else {
        dayCell.backgroundColor = [UIColor clearColor];
    }
    
    
    
}

#pragma mark - view life cycle

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    _paths = nil;
    _docDir = nil;
    _filePath = nil;
    _data = nil;
    _schedule = nil;
    _special1 = nil;
    _special2 = nil;
    _special3 = nil;
    _calendarScedule = nil;
    _dateFormatter = nil;
    _invalidTime = nil;
    _settings = nil;
    _pass = nil;
    _ip = nil;
    _editButton = nil;
    _cancelButton = nil;
    _langData = nil;
    
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self){
    }
    
    return self;
}

-(void)viewDidLoad{
    
    NSArray *availableLanguages = @[@"zh", @"ko", @"en", @"es", @"ar", @"ru", @"tr"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages) forPreferences:[NSLocale preferredLanguages]][0];
    
    NSLog(@"best language: %@", bestMatchedLanguage);
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData* json = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"scheduler"]];
    _pass = @"http://wet_act:A3139gg1121@";
    
    [self initializeFile];
    [self populateCalendar];
    
    self.preferredContentSize = CGSizeMake(770.0, 520);
    self.view.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    
    _invalidTime = [[UILabel alloc] initWithFrame:CGRectMake(335, 20, 180, 25)];
    _invalidTime.textColor = [UIColor colorWithRed:235.0f/255.0f green:30.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    _invalidTime.font = [UIFont fontWithName:@"Verdana" size:14];
    _invalidTime.textAlignment = NSTextAlignmentCenter;
    _invalidTime.text = @"INVALID DATE CHOSEN";
    _invalidTime.alpha = 0;
    
    [self.view addSubview:_invalidTime];
    
    _editButton = [[UIButton alloc] initWithFrame:CGRectMake(650, 15, 90, 25)];
    [_editButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [_editButton.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(enableStartEnd:) forControlEvents:UIControlEventTouchUpInside];
    _editButton.alpha = 0;
    
    [self.view addSubview:_editButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(650, 470, 90, 25)];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [_cancelButton setTitle:_langData[@"CANCEL"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelChanges) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.alpha = 0;
    
    [self.view addSubview:_cancelButton];
    [super viewDidLoad];
    
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Initializer

-(void)initializeFile{
    
    _defaults = [NSUserDefaults standardUserDefaults];
    _ip = [_defaults objectForKey:@"serverIpAddress"];
    
}




@end
