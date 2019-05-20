//
//  ACTMoveDeleteShowPlaylistViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 3/28/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTMoveDeleteShowPlaylistViewController.h"

@interface ACTMoveDeleteShowPlaylistViewController ()
@property (nonatomic) NSArray *paths;
@property (nonatomic) NSString *docDir;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSMutableArray *schedule;
@property (nonatomic) NSMutableArray *allPlaylists;
@property (nonatomic) NSMutableArray *shows;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) int buttonTag;
@property (nonatomic) int duration;
@property (nonatomic) int startingTime;
@property (nonatomic) int dayOfTheWeek;
@property (nonatomic) int selectedTime;
@property (nonatomic) int selectedTimeMin;
@property (nonatomic) int highestTime;
@property (nonatomic) int highestIndex;
@property (nonatomic) int highestShowPlaylistNum;
@property (nonatomic) int lowestTime;
@property (nonatomic) UILabel *invalidTime;
@property (nonatomic) int shouldBreak;
@property (nonatomic) UILabel *endTimeLabel;
@property (nonatomic, strong) NSDictionary *langData;
@property (nonatomic) NSUserDefaults *defaults;
@end

@implementation ACTMoveDeleteShowPlaylistViewController
UIDatePicker *timePicker;


-(void)populatePopover:(int)tag{
    
    UILabel *dayOfWeek = [[UILabel alloc] initWithFrame:CGRectMake(92.5, 45, 175, 25)];
    dayOfWeek.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    dayOfWeek.font = [UIFont fontWithName:@"Verdana" size:24];
    dayOfWeek.textAlignment = NSTextAlignmentCenter;
    
    if (tag < 100){
        dayOfWeek.text = _langData[@"SUNDAY"];
        _dayOfTheWeek = 0;
    }else if (tag < 200){
        dayOfWeek.text = _langData[@"MONDAY"];
        _dayOfTheWeek = 1;
    }else if (tag < 300){
        dayOfWeek.text = _langData[@"TUESDAY"];
        _dayOfTheWeek = 2;
    }else if (tag < 400){
        dayOfWeek.text = _langData[@"WEDNESDAY"];
        _dayOfTheWeek = 3;
    }else if (tag < 500){
        dayOfWeek.text = _langData[@"THURSDAY"];
        _dayOfTheWeek = 4;
    }else if (tag < 600){
        dayOfWeek.text = _langData[@"FRIDAY"];
        _dayOfTheWeek = 5;
    }else{
        dayOfWeek.text = _langData[@"SATURDAY"];
        _dayOfTheWeek = 6;
    }
    
    [self.view addSubview:dayOfWeek];
    
    UILabel *showName = [[UILabel alloc] initWithFrame:CGRectMake(12.5, 84, 335, 25)];
    showName.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    showName.font = [UIFont fontWithName:@"Verdana" size:19];
    showName.textAlignment = NSTextAlignmentCenter;
    
    UILabel *showDuration = [[UILabel alloc] initWithFrame:CGRectMake(102.5, 118, 155, 25)];
    showDuration.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    showDuration.font = [UIFont fontWithName:@"Verdana" size:19];
    showDuration.textAlignment = NSTextAlignmentCenter;
    
    
    int showPlaylist = 0;
    
    if ([_schedule[tag] intValue] > 0){
        
        showPlaylist = [_schedule[tag] intValue];
        
    }else if ([[[NSString stringWithFormat:@"%@",_schedule[tag]] substringToIndex:1] isEqualToString:@"p"]){
        
        NSLog(@"1st replace: %@", _schedule[tag]);
        NSString *stringWithoutP = [_schedule[tag] stringByReplacingOccurrencesOfString:@"p" withString:@""];
        showPlaylist = [stringWithoutP intValue]*-1;
        
    }
    
    if (showPlaylist >= 0){
        
        int show = showPlaylist;
        _duration = [_shows[show][@"duration"] intValue];
        [showName setText:_shows[show][@"name"]];
        [self.view addSubview:showName];
        
        
        int min = _duration/60;
        int sec = _duration % 60;
        showDuration.text = [NSString stringWithFormat:@"%@%d:%@%d", min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
        [self.view addSubview:showDuration];
        
    }else{
        
        int playlist = (showPlaylist * -1) - 1;
        _duration = [_allPlaylists[playlist][@"duration"] intValue];
        
        showName.text = [NSString stringWithFormat:@"%@ %d", _langData[@"PLAYLIST"],playlist + 1];
        [self.view addSubview:showName];
        
        int min = _duration/60;
        int sec = _duration % 60;
        showDuration.text = [NSString stringWithFormat:@"%@%d:%@%d", min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
        [self.view addSubview:showDuration];
        
    }
    
    NSString *time = [_schedule[tag - 1] stringValue];
    _startingTime = [_schedule[tag - 1] intValue];
    _selectedTime = _startingTime;

    NSString *hoursString;
    
    if (time.length == 4){
        hoursString =[time substringWithRange:NSMakeRange(0, 2)];
    }else if (time.length == 3){
        hoursString =[time substringWithRange:NSMakeRange(0, 1)];
    }
    
    NSString *minutesString;
    
    if(time.length >1){
        minutesString =[time substringWithRange:NSMakeRange([time length] - 2, 2)];
    }else{
        minutesString =[time substringWithRange:NSMakeRange([time length] - 1, 1)];
    }
    
    timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 140, 360, 250)];
    timePicker.datePickerMode = UIDatePickerModeTime;
    timePicker.hidden = NO;
    
    NSDate *today= timePicker.date;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: (NSCalendarUnitHour | NSCalendarUnitMinute ) fromDate: today];
    
    components.hour = [hoursString intValue];
    components.minute = [minutesString intValue];
    
    timePicker.date =  [gregorian dateFromComponents:components];
    [timePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timePicker];

    int min = _duration/60;
    int hours = min/60;
    int addEndingtime;
    
    if(hours >= 1){
        addEndingtime = hours*100 + (min - (hours * 60));
    }else{
        addEndingtime = min;
    }
    
    int myEndingTime;
    
    if((min - (hours * 60) + _startingTime%100) >= 59){
        myEndingTime = _startingTime + 100 + (min - (hours * 60)) - 60 + 1 ;
    }else{
        myEndingTime = _startingTime + addEndingtime + 1;
    }
    
    
    _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.5, 360, 335, 25)];
    _endTimeLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    _endTimeLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    _endTimeLabel.textAlignment = NSTextAlignmentCenter;
    NSString *myEndingTimeString = [NSString stringWithFormat:@"%i", myEndingTime];
    
    if(myEndingTimeString.length < 3){
        
        _endTimeLabel.text =[NSString stringWithFormat:@"END TIME: 12:%@", myEndingTimeString];
        
    }else if (myEndingTimeString.length < 4){
        
        _endTimeLabel.text =[NSString stringWithFormat:@"END TIME: %@:%@", [myEndingTimeString substringToIndex:1], [myEndingTimeString substringFromIndex:1]];
        
    }else{
        
        int endingTimeHour = [[myEndingTimeString substringToIndex:2] intValue];
        
        if(endingTimeHour > 12){
            endingTimeHour -= 12;
        }
        
        _endTimeLabel.text =[NSString stringWithFormat:@"END TIME: %i:%@", endingTimeHour, [myEndingTimeString substringFromIndex:2]];
        
    }

    [self.view addSubview:_endTimeLabel];
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(225, 420, 70, 30)];
    [changeButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [changeButton setTitle:_langData[@"DONE"] forState:UIControlStateNormal];
    [changeButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:12]];
    [changeButton addTarget:self action:@selector(changeTime) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(75, 420, 70, 30)];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [deleteButton setTitle:_langData[@"DELETE"] forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:12]];
    [deleteButton addTarget:self action:@selector(deleteShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
}

-(void)deleteShow{
    
    [_schedule removeObjectAtIndex:_buttonTag];
    [_schedule removeObjectAtIndex:_buttonTag - 1];
    
    if (_buttonTag < 100){
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:98];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:98];
        
    }else if (_buttonTag < 200){
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:198];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:198];
        
    }else if (_buttonTag < 300){
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:298];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:298];
        
    }else if (_buttonTag < 400){
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:398];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:398];
        
    }else if (_buttonTag < 500){
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:498];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:498];
        
    }else if (_buttonTag < 600){
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:598];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:598];
        
    }else{
        
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:698];
        [_schedule insertObject:[NSNumber numberWithInt:0] atIndex:698];
        
    }
    
    
    [self saveSchedule];
    
}

-(void)changeTime{
    
    _shouldBreak = 0;

    if(_selectedTime == 0){
        _selectedTime = 1;
    }
    
    NSString *showPlaylistNum = _schedule[_buttonTag];
    
    [_schedule removeObjectAtIndex:_buttonTag];
    [_schedule removeObjectAtIndex:_buttonTag - 1];
    
    _lowestTime = [_schedule[100 * _dayOfTheWeek] intValue];
    
    for(int i = 100 * _dayOfTheWeek; i < 100 * _dayOfTheWeek + 98; i+=2){
        
        if(_highestTime < [_schedule[i] intValue]){
            
            _highestTime = [_schedule[i] intValue];
            _highestIndex = i;
            
            if([_schedule[i + 1] intValue] > 0){
                
                _highestShowPlaylistNum = [_schedule[i + 1] intValue];
                
            }else if ([[[NSString stringWithFormat:@"%@",_schedule[i + 1]] substringToIndex:1] isEqualToString:@"p"]){
                
                NSLog(@"2nd replace: %@", _schedule[i + 1]);
                NSString *stringWithoutP = [_schedule[i + 1] stringByReplacingOccurrencesOfString:@"p" withString:@""];
                _highestShowPlaylistNum = [stringWithoutP intValue]*-1;
                
            }
        }
    }

    int highestDuration;
    int highestMin;
    int highestHours;
    int highestAddEndingTime;
    int highestEndingTime;
    int highestStartingTimeMin = [[[NSString stringWithFormat:@"%i",_highestTime] substringWithRange:NSMakeRange([ [NSString stringWithFormat:@"%i",_highestTime] length] > 2 ?[ [NSString stringWithFormat:@"%i",_highestTime] length] - 2 : [ [NSString stringWithFormat:@"%i",_highestTime] length] - 1, [ [NSString stringWithFormat:@"%i",_highestTime] length] > 2 ? 2 : 1)] intValue];

    if (_highestShowPlaylistNum >= 0){
        
        int show = _highestShowPlaylistNum;
        highestDuration = [_shows[show][@"duration"] intValue];
        highestMin = highestDuration/60;
        highestHours = highestMin/60;
        
        if(highestHours >= 1){
            
            highestAddEndingTime = highestHours*100 + (highestMin - (highestHours * 60));
            
        }else{
            
            highestAddEndingTime = highestMin;
            
        }
        
        
        if((highestMin - (highestHours * 60) + highestStartingTimeMin) >= 60){
            
            highestEndingTime = _highestTime + 100 + (highestMin - (highestHours * 60)) - 60 + 1;
            
        }else{
            
            highestEndingTime = _highestTime + highestAddEndingTime + 1;
            
        }
        
        
    }else{
        
        int playlist = (_highestShowPlaylistNum * -1) - 1;
        highestDuration = [_allPlaylists[playlist][@"duration"] intValue];
        highestMin = highestDuration/60;
        highestHours = highestMin/60;
        
        if(highestHours >= 1){
            
            highestAddEndingTime = highestHours*100 + (highestMin - (highestHours * 60));
            
        }else{
            
            highestAddEndingTime = highestMin;
            
        }
        
        
        if ((highestMin - (highestHours * 60) + highestStartingTimeMin) >= 60){
            
            highestEndingTime = _highestTime + 100 + (highestMin - (highestHours * 60)) - 60 + 1;
            
        }else{
            
            highestEndingTime = _highestTime + highestAddEndingTime + 1;
            
        }
        
    }
    

    int lastDaysStartingTime = 0;
    int lastDaysEndingTime;
    int lastDaysShowNum = [_schedule[(_dayOfTheWeek == 0 ? 697 : 100 * (_dayOfTheWeek - 1) + 99)] intValue];
    
    if ( (_dayOfTheWeek == 1) && ([_schedule[0] intValue] == 0)){
        
        lastDaysStartingTime = 0;
        lastDaysShowNum = 0;
        
    }else{
        
        for (int i = 100 * (_dayOfTheWeek == 0 ? 6 : _dayOfTheWeek - 1) + 1; i < 100 * ((_dayOfTheWeek == 0 ? 6 : _dayOfTheWeek - 1)) + (_dayOfTheWeek == 0 ? 98 : 98); i+=2){
            
            NSString *string = [NSString stringWithFormat:@"%@", _schedule[i]];

            if ([string intValue] == 0 && ![[string substringToIndex:1] isEqualToString:@"p"]){
            
                lastDaysStartingTime = [_schedule[i-3] intValue];
                
                if ([_schedule[i - 2] intValue] > 0){
                    
                    lastDaysShowNum = [_schedule[i - 2] intValue];
                    
                }else if ([[[NSString stringWithFormat:@"%@",_schedule[i - 2]] substringToIndex:1] isEqualToString:@"p"]){
                    
                    NSLog(@"3rd replace: %@", _schedule[i - 2]);
                    NSString *stringWithoutP = [_schedule[i - 2] stringByReplacingOccurrencesOfString:@"p" withString:@""];
                    lastDaysShowNum = [stringWithoutP intValue]*-1;
                
                }
                NSLog(@"last days starting time: %i, last day showNum: %i", lastDaysStartingTime, lastDaysShowNum);
                break;
                
            }
        }
    }

    int lastDaysMin;
    int lastDaysHours;
    int lastDaysAddEndingTime;
    int lastDaysDuration;
    int lastDaysStartingTimeMin = [[[NSString stringWithFormat:@"%i", lastDaysStartingTime] substringWithRange:NSMakeRange([ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] > 2 ? [ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] - 2 : [ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] - 1, [ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] > 2 ? 2 : 1)] intValue];
    
    if (lastDaysShowNum >= 0){
        
        int show = lastDaysShowNum;
        lastDaysDuration = [_shows[show][@"duration"] intValue];
        lastDaysMin = lastDaysDuration/60;
        lastDaysHours = lastDaysMin/60;
        
        if (lastDaysHours >= 1){
            lastDaysAddEndingTime = lastDaysHours*100 + (lastDaysMin - (lastDaysHours * 60));
        }else{
            lastDaysAddEndingTime = lastDaysMin;
        }
        
        if ((lastDaysMin - (lastDaysHours * 60) + lastDaysStartingTimeMin) >= 60){
            lastDaysEndingTime = lastDaysStartingTime + 100 + (lastDaysMin - (lastDaysHours * 60)) - 60 + 1;
        }else{
            lastDaysEndingTime = lastDaysStartingTime + lastDaysAddEndingTime + 1;
        }
        
    }else{
        
        int playlist = (lastDaysShowNum * -1) - 1;
        lastDaysDuration = [_allPlaylists[playlist][@"duration"] intValue];
        lastDaysMin = lastDaysDuration/60;
        lastDaysHours = lastDaysMin/60;
        
        if (lastDaysHours >= 1){
            lastDaysAddEndingTime = lastDaysHours*100 + (lastDaysMin - (lastDaysHours * 60));
        }else{
            lastDaysAddEndingTime = lastDaysMin;
        }
        
        if ((lastDaysMin - (lastDaysHours * 60) + lastDaysStartingTimeMin) >= 60){
            lastDaysEndingTime = lastDaysStartingTime + 100 + (lastDaysMin - (lastDaysHours * 60)) - 60 + 1;
        }else{
            lastDaysEndingTime = lastDaysStartingTime + lastDaysAddEndingTime + 1;
        }
        
    }
    
    NSLog(@"last days ending time: %i", lastDaysEndingTime);
    
    int previousMin;
    int previousHours;
    int previousAddEndingTime;
    int previousEndingTime;
    
    for (int i = 100 * _dayOfTheWeek; i < (_dayOfTheWeek == 6 ? 696: 100 * _dayOfTheWeek + 98); i+=2){

        
        int previousDuration;
        int previousStaringTime = !_schedule[i]? 0 : [_schedule[i] intValue];
        int previousStartingTimeMin = [[[_schedule[i] stringValue] substringWithRange:NSMakeRange([ [_schedule[i] stringValue] length] > 2 ? [ [_schedule[i] stringValue] length] - 2 : [ [_schedule[i] stringValue] length] - 1, [ [_schedule[i] stringValue] length] > 2 ? 2 : 1)] intValue];
        int previousShow = 0;
        
        if ([_schedule[i + 1] intValue] > 0){
            
            previousShow = [_schedule[i + 1] intValue];
            NSLog(@"previous show SHOW: %i", [_schedule[i ] intValue]);

        }else if ([[[NSString stringWithFormat:@"%@",_schedule[i + 1]] substringToIndex:1] isEqualToString:@"p"]){
            
            NSLog(@"4th replace: %@", _schedule[i + 1]);
            NSString *stringWithoutP = [_schedule[i + 1] stringByReplacingOccurrencesOfString:@"p" withString:@""];
            previousShow = [stringWithoutP intValue]*-1;
            NSLog(@"previous show PLAYLIST: %i", previousShow);
            
        }
        
        
        if (previousShow >= 0 ){
            
            int show = previousShow;
            previousDuration = [_shows[show][@"duration"] intValue];
            previousMin = previousDuration/60;
            previousHours = previousMin/60;
            
            if (previousHours >= 1){
                previousAddEndingTime = previousHours*100 + (previousMin - (previousHours * 60));
            }else{
                previousAddEndingTime = previousMin;
            }
            
            
            if ((previousMin - (previousHours * 60) + previousStartingTimeMin) >= 60){
                previousEndingTime = previousStaringTime + 100 + (previousMin - (previousHours * 60)) - 60 + 1;
            }else{
                previousEndingTime = previousStaringTime + previousAddEndingTime + 1;
            }
            
            
        }else{
            
            int playlist = (previousShow * -1) - 1;
            NSLog(@"playlist num: %i", playlist);
            previousDuration = [_allPlaylists[playlist][@"duration"] intValue];
            previousMin = previousDuration/60;
            previousHours = previousMin/60;
            
            if(previousHours >= 1){
                previousAddEndingTime = previousHours*100 + (previousMin - (previousHours * 60));
            }else{
                previousAddEndingTime = previousMin;
            }
            
            if ((previousMin - (previousHours * 60) + previousStartingTimeMin) >= 60){
                previousEndingTime = previousStaringTime + 100 + (previousMin - (previousHours * 60)) - 60 + 1;
            }else{
                previousEndingTime = previousStaringTime + previousAddEndingTime + 1;
            }
            
        }
        
        int min = _duration/60;
        int hours = min/60;
        int addEndingtime;
        
        if(hours >= 1){
            addEndingtime = hours*100 + (min - (hours * 60));
        }else{
            addEndingtime = min;
        }
        
        int myEndingTime;
        
        if((min - (hours * 60) + _selectedTimeMin) >= 60){
            myEndingTime = _selectedTime + 100 + (min - (hours * 60)) - 60 + 1;
        }else{
            myEndingTime = _selectedTime + addEndingtime + 1;
        }

        int nextStartingTime;
        
        if(!_schedule[i+2]){
            nextStartingTime = 2400;
        }else{
            nextStartingTime = [_schedule[i+2] intValue];
        }
        
        int firstNextDaysStarting = [_schedule[_dayOfTheWeek == 6 ? 0 : (100 * (_dayOfTheWeek + 1)) - 2 ] intValue];
        
        if (firstNextDaysStarting == 0){
            firstNextDaysStarting = 2400;
        }
        
        if (((_selectedTime >= lastDaysEndingTime - 2400) && (_highestTime == _lowestTime) && (i == (100 * _dayOfTheWeek)) && (myEndingTime - 2400 <= firstNextDaysStarting))){
            
            
            if ((((_selectedTime <= _highestTime) && (myEndingTime <= _highestTime)) || (_lowestTime == 0))){
                
                [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i];
                [_schedule insertObject:showPlaylistNum atIndex:i + 1];
    
                [self saveSchedule];
                
            }else if (((_selectedTime >= lastDaysEndingTime - 2400) && (_selectedTime >= _highestTime) && (_selectedTime >= previousEndingTime))){

                
                [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i+2];
                [_schedule insertObject:showPlaylistNum atIndex:i+3];
                [self saveSchedule];
                
            }
            
            [_schedule insertObject:showPlaylistNum atIndex:_buttonTag-1];
            [_schedule insertObject:[NSNumber numberWithInt:_startingTime] atIndex:_buttonTag-1];
            _shouldBreak = 1;
            
            break;
            
        }else if ((((_selectedTime <= _lowestTime) || (_selectedTime >= _lowestTime))   && (i == (100 * _dayOfTheWeek)) && (myEndingTime <= previousStaringTime))){
            
            NSLog(@"last days ending time: %i", lastDaysEndingTime);
            
            if ((_selectedTime >= lastDaysEndingTime - 2400) && (_selectedTime <= _lowestTime)){
                
                [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i];
                [_schedule insertObject:showPlaylistNum atIndex:i + 1];

                [self saveSchedule];
                _shouldBreak = 1;
                break;
                
            }else if (_selectedTime >= _lowestTime){
                
                [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i+2];
                [_schedule insertObject:showPlaylistNum atIndex:i + 3];
            
                [self saveSchedule];
                _shouldBreak = 1;

                break;
                
            }
            
        }else if (((_selectedTime >= _highestTime) && (_selectedTime >= highestEndingTime))){

            if ((myEndingTime - 2400 <= firstNextDaysStarting) && (_selectedTime >= lastDaysEndingTime - 2400)){
                
                [_schedule insertObject:[NSNumber numberWithInt:_highestTime] atIndex:_highestIndex];
                [_schedule insertObject:[NSString stringWithFormat:@"%@",_highestShowPlaylistNum < 0 ?  [NSString stringWithFormat:@"p%i",_highestShowPlaylistNum * -1] : [NSString stringWithFormat:@"%i", _highestShowPlaylistNum]] atIndex:_highestIndex + 1];
                
                [_schedule replaceObjectAtIndex:(_highestIndex + 2) withObject:[NSNumber numberWithInt:_selectedTime]];
                [_schedule replaceObjectAtIndex:(_highestIndex + 3) withObject:showPlaylistNum];
            
                [self saveSchedule];
                _shouldBreak = 1;

                break;
                
            }
            
        }else if (((previousEndingTime <= _selectedTime) && (myEndingTime <= nextStartingTime)&& ([_schedule[i] intValue] != 0))){
            
            [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i +2];
            [_schedule insertObject:showPlaylistNum atIndex:i + 3];
            
            [self saveSchedule];
            _shouldBreak = 1;
            NSLog(@"set here4");
            break;
            
        }

    }
    
    if(_shouldBreak == 1){
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showInvalidTime) userInfo:nil repeats:NO];
        NSLog(@"breaks %lu", (unsigned long)_schedule.count);
        return;
        
    }else{
        
        [_schedule insertObject:showPlaylistNum atIndex:_buttonTag-1];
        [_schedule insertObject:[NSNumber numberWithInt:_startingTime] atIndex:_buttonTag-1];
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showInvalidTime) userInfo:nil repeats:NO];
        NSLog(@"put element bacl");
    
    }
    
    NSLog(@"breaks last %lu", (unsigned long)_schedule.count);

    
}

-(void)saveSchedule{
    
    [_defaults setObject:_schedule forKey:@"schedule"];
    [_defaults setObject:[NSNumber numberWithInt: (int)1] forKey:@"dismiss"];

}

-(void)showInvalidTime{
    
    _invalidTime.alpha = 1;

}

-(void)changeDateInLabel:(id)sender{
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"Hmm";
    
    _selectedTime =  [[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:timePicker.date]] intValue];
    
    timeFormatter.dateFormat = @"mm";
    
    _selectedTimeMin =  [[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:timePicker.date]] intValue];
    _invalidTime.alpha = 0;
    
    int min = _duration/60;
    int hours = min/60;
    int addEndingtime;
    
    if(hours >= 1){
        addEndingtime = hours*100 + (min - (hours * 60));
    }else{
        addEndingtime = min;
    }
    
    int myEndingTime;
    
    if((min - (hours * 60) + _selectedTimeMin%100) >= 59){
        myEndingTime = _selectedTime + 100 + (min - (hours * 60)) - 60 + 1;
    }else{
        myEndingTime = _selectedTime + addEndingtime + 1;
    }
    
    NSString *myEndingTimeString = [NSString stringWithFormat:@"%i", myEndingTime];
    
    if (myEndingTimeString.length < 3){
        
        _endTimeLabel.text =[NSString stringWithFormat:@"END TIME: 12:%@", myEndingTimeString];
        
    }else if (myEndingTimeString.length < 4){
        
        _endTimeLabel.text =[NSString stringWithFormat:@"END TIME: %@:%@", [myEndingTimeString substringToIndex:1], [myEndingTimeString substringFromIndex:1]];
    
    }else{
        
        int endingTimeHour = [[myEndingTimeString substringToIndex:2] intValue];
        
        if (endingTimeHour > 12){
            endingTimeHour -= 12;
        }
        
        _endTimeLabel.text =[NSString stringWithFormat:@"END TIME: %i:%@", endingTimeHour, [myEndingTimeString substringFromIndex:2]];
        
    }
    
}

#pragma mark - view life cycle

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){

    }
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    NSArray *availableLanguages = @[@"zh", @"ko", @"en", @"es", @"ar", @"ru", @"tr"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages) forPreferences:[NSLocale preferredLanguages]][0];
    
    NSLog(@"best language: %@", bestMatchedLanguage);
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData* json = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"scheduler"]];
    
    
    NSLog(@"MOVE OR DELETE SHOW/PLAYLIST");
    [self getCurrentScheduleAndButtonTag];
    
    self.preferredContentSize = CGSizeMake(360.0, 520);
    self.view.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    
    
    _invalidTime = [[UILabel alloc] initWithFrame:CGRectMake(90, 470, 180, 25)];
    _invalidTime.textColor = [UIColor colorWithRed:235.0f/255.0f green:30.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    _invalidTime.font = [UIFont fontWithName:@"Verdana" size:14];
    _invalidTime.textAlignment = NSTextAlignmentCenter;
    _invalidTime.text = @"INVALID TIME CHOSEN";
    _invalidTime.tag = 9999;
    _invalidTime.alpha = 0;
    [self.view addSubview:_invalidTime];
    
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    _manager = nil;
    _paths = nil;
    _docDir = nil;
    _filePath = nil;
    _data = nil;
    _schedule = nil;
    _allPlaylists = nil;
    _shows = nil;
    _settings = nil;
    _invalidTime = nil;
    _endTimeLabel = nil;
    _langData = nil;
    _defaults = nil;
    
}

-(void)getCurrentScheduleAndButtonTag{
    
    _defaults = [NSUserDefaults standardUserDefaults];
    
    _schedule = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"schedule"]];
    _allPlaylists = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"playlists"]];
    _shows = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"shows"]];
    _buttonTag = [[_defaults objectForKey:@"buttonTag"] intValue];
    
    [self populatePopover:_buttonTag];
    
    _highestTime = 0;
    _highestIndex = 100 * _dayOfTheWeek;
    _highestShowPlaylistNum = 0;
    
}



@end
