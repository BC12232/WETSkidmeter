//
//  ACTAddShowPlaylistViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 3/31/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTAddShowPlaylistViewController.h"

@interface ACTAddShowPlaylistViewController ()
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
@property (nonatomic) UILabel *invalidTime;
@property (nonatomic) UITableView *showPlaylistTable;
@property (nonatomic) UIDatePicker *timePicker;
@property (nonatomic) int selectedTime;
@property (nonatomic) int selectedTimeMin;
@property (nonatomic) NSDateFormatter *timeFormatter;
@property (nonatomic) NSString *selectedShow;
@property (nonatomic) int highestTime;
@property (nonatomic) int highestIndex;
@property (nonatomic) int highestShowPlaylistNum;
@property (nonatomic) int lowestTime;
@property (nonatomic) UILabel *dayOfWeek;
@property (nonatomic, strong) NSDictionary *langData;
@property (nonatomic) NSUserDefaults *defaults;
@end

@implementation ACTAddShowPlaylistViewController


#pragma mark - View Life Cycle

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self){
    }
    
    return self;
    
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    NSArray *availableLanguages = @[ @"zh", @"zh-Hans", @"zh-HK", @"en"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages)][0];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData* json = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"scheduler"]];
    
    NSLog(@"ADD A SHOW/PLAYLIST");
    
    [self getCurrentScheduleAndButtonTag];
    
    self.preferredContentSize = CGSizeMake(400.0, 650);
    self.view.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    
    _invalidTime = [[UILabel alloc] initWithFrame:CGRectMake(110, 620, 180, 25)];
    _invalidTime.textColor = [UIColor colorWithRed:235.0f/255.0f green:30.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    _invalidTime.font = [UIFont fontWithName:@"Verdana" size:14];
    _invalidTime.textAlignment = NSTextAlignmentCenter;
    _invalidTime.text = @"INVALID TIME CHOSEN";
    _invalidTime.alpha = 0;
    
    [self.view addSubview:_invalidTime];
    _defaults = [NSUserDefaults standardUserDefaults];
    
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    _paths = nil;
    _docDir = nil;
    _filePath = nil;
    _data = nil;
    _schedule = nil;
    _allPlaylists = nil;
    _shows = nil;
    _settings = nil;
    _invalidTime = nil;
    _showPlaylistTable = nil;
    _timePicker = nil;
    _timeFormatter = nil;
    _selectedShow = nil;
    _dayOfWeek = nil;
    _langData = nil;
    _defaults = nil;
    
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float heightForRow = 40;
    
    int duration = 0;
    
    
    if (indexPath.row + 1>= _shows.count ) {
        duration = [[[_allPlaylists objectAtIndex:indexPath.row - _shows.count  + 1] objectForKey:@"duration"] intValue];
    } else if (indexPath.row < _shows.count  ) {
        duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
        
        if ([[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] || [[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"special"]) {
            bool testShow = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] boolValue];
            bool specialShow = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"special"] boolValue];
            if (testShow || specialShow) {
                return 0;
            }
        }
    }
    
    if(duration == 0)
        return 0;
    else
        return heightForRow;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _shows.count + _allPlaylists.count - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditableTextCell"];
    
    
    int duration = 0;
    
    if (indexPath.row + 1>= _shows.count ) {
        if ([[[_allPlaylists objectAtIndex:indexPath.row - _shows.count  + 1] objectForKey:@"number"] intValue] < 21) {
            duration = [[[_allPlaylists objectAtIndex:indexPath.row - _shows.count  + 1] objectForKey:@"duration"] intValue];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %d", _langData[@"PLAYLIST"] , [[[_allPlaylists objectAtIndex:indexPath.row -  _shows.count  + 1] objectForKey:@"number"] intValue]];
        }
        
    } else if (indexPath.row < _shows.count ) {
        duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
        cell.textLabel.text = [[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"name"];
        
        if ([[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] || [[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"special"]) {
            bool testShow = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] boolValue];
            bool specialShow = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"special"] boolValue];
            if (testShow || specialShow) {
                cell.hidden = YES;
            }
        }
    }
    
    if (duration == 0) {
        cell.hidden = YES;
    }
    int min = duration/60;
    int sec = duration % 60;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%d:%@%d", min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
    
    cell.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    
    cell.textLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    cell.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    if (duration == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 0.27)];/// change size as you need.
    separatorLineView.backgroundColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];// you can also put image here
    [cell.contentView addSubview:separatorLineView];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[_showPlaylistTable cellForRowAtIndexPath:indexPath];
    
    if (![cell.detailTextLabel.text isEqual:@"00:00"]){
        
        _invalidTime.alpha = 0;
        _selectedShow = [NSString stringWithFormat:@"%i", (int)indexPath.row + 1];
        
        if(indexPath.row + 1>=  _shows.count){
            _selectedShow = [NSString stringWithFormat:@"p%i", (int)indexPath.row - (int)_shows.count + 2];
        }
        
        if([_selectedShow intValue] == 0){
            _duration = [[[_allPlaylists objectAtIndex:indexPath.row -  _shows.count + 1] objectForKey:@"duration"] intValue];
        }else{
            _duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
        }
        
        NSLog(@"selected %@", _selectedShow);
        
    }else{
        
        if([_selectedShow intValue] > 0){
            
            [_showPlaylistTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:[_selectedShow intValue] - 1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }else{
            
            NSString *stringWithoutP = [[NSString stringWithFormat:@"%@",_selectedShow] stringByReplacingOccurrencesOfString:@"p" withString:@""];
            int selectRow = [stringWithoutP intValue] + (int)_shows.count;
            [_showPlaylistTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow - 1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }

        
        NSLog(@"selected %@", _selectedShow);
        
    }
}

#pragma mark - Error Management Functions

-(void)showInvalidTime{
    
    _invalidTime.alpha = 1;
    NSLog(@"%d", _selectedTime);
    
}

#pragma mark - Get Corresponding Scheduler Information

-(void)getCurrentScheduleAndButtonTag{
    
    _defaults = [NSUserDefaults standardUserDefaults];
    _schedule = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"schedule"]];
    _allPlaylists = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"playlists"]];
    _shows = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"shows"]];
    
    //Get button tag from user defaults
    _buttonTag = [[_defaults objectForKey:@"buttonTag"] intValue];
    
    [self createShowTableView];
    _highestTime = 0;
    _highestIndex = 100 * _dayOfTheWeek;
    _highestShowPlaylistNum = 0;
    
}

#pragma mark - construct Table View

-(void)createShowTableView{
    
    _showPlaylistTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 108, 400, 270) style:UITableViewStylePlain];
    [_showPlaylistTable setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f]];
    _showPlaylistTable.delegate = self;
    _showPlaylistTable.dataSource = self;
    _showPlaylistTable.scrollEnabled = YES;
    
    [self.view addSubview:_showPlaylistTable];
    
    _dayOfWeek = [[UILabel alloc] initWithFrame:CGRectMake(100, 42, 200, 25)];
    _dayOfWeek.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    _dayOfWeek.font = [UIFont fontWithName:@"Verdana" size:24];
    _dayOfWeek.textAlignment = NSTextAlignmentCenter;
    
    if(_buttonTag == 5000){
        _dayOfWeek.text = _langData[@"SUNDAY"];
        _dayOfTheWeek = 0;
    }else if (_buttonTag == 5001){
        _dayOfWeek.text = _langData[@"MONDAY"];
        _dayOfTheWeek = 1;
    }else if (_buttonTag == 5002){
        _dayOfWeek.text = _langData[@"TUESDAY"];
        _dayOfTheWeek = 2;
    }else if (_buttonTag == 5003){
        _dayOfWeek.text = _langData[@"WEDNESDAY"];
        _dayOfTheWeek = 3;
    }else if (_buttonTag == 5004){
        _dayOfWeek.text = _langData[@"THURSDAY"];
        _dayOfTheWeek = 4;
    }else if (_buttonTag == 5005){
        _dayOfWeek.text = _langData[@"FRIDAY"];
        _dayOfTheWeek = 5;
    }else{
        _dayOfWeek.text = _langData[@"SATURDAY"];
        _dayOfTheWeek = 6;
    }
    
    [self.view addSubview:_dayOfWeek];
    
    NSLog(@"day of the week -> %d", _dayOfTheWeek);
    
    for (int i = 100 * _dayOfTheWeek; i < 100 * _dayOfTheWeek + 100; i+=2){
        
        if(_highestTime < [_schedule[i] intValue]){
            
            _highestTime = [_schedule[i] intValue];
            _highestIndex = i;
            
            if ([_schedule[i + 1] intValue] > 0){
                _highestShowPlaylistNum = [_schedule[i + 1] intValue];
                
            }else if ([[[NSString stringWithFormat:@"%@",_schedule[i + 1]] substringToIndex:1] isEqualToString:@"p"]){
                NSString *stringWithoutP = [[NSString stringWithFormat:@"%@",_schedule[i + 1]] stringByReplacingOccurrencesOfString:@"p" withString:@""];
                _highestShowPlaylistNum = [stringWithoutP intValue]*-1;
            }
            
        }
    }
    
    int hour;
    int min;
    
    if (_highestShowPlaylistNum >= 0){
        
        int show = _highestShowPlaylistNum;
        _duration = [_shows[show][@"duration"] intValue];
        hour = _duration/60/60;
        min = _duration/60;
        
    }else{
        
        int playlist = (_highestShowPlaylistNum * -1) - 1;
        _duration = [_allPlaylists[playlist][@"duration"] intValue];
        hour = _duration/60/60;
        min = _duration/60;
        
    }
    
    if (hour > 0){
        
        _highestTime += hour * 100;
        _highestTime += min - (hour * 60) + 1;
        
    }else{
    
        _highestTime += min + 1;
        
    }
    
    NSString *time = [NSString stringWithFormat:@"%i", _highestTime];
    NSString *hoursString;
    
    if (time.length == 4){
        hoursString =[time substringWithRange:NSMakeRange(0, 2)];
    }else if (time.length == 3){
        hoursString =[time substringWithRange:NSMakeRange(0, 1)];
    }
    
    NSString *minutesString;
    
    if (time.length >1){
        minutesString =[time substringWithRange:NSMakeRange([time length] - 2, 2)];
    }else{
        minutesString =[time substringWithRange:NSMakeRange([time length] - 1, 1)];
    }
    
    
    _timeFormatter = [[NSDateFormatter alloc]init];
    _timeFormatter.dateFormat = @"Hmm";
    
    _timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 365, 400, 250)];
    _timePicker.datePickerMode = UIDatePickerModeTime;
    _timePicker.hidden = NO;
    
    NSDate *today= _timePicker.date;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: ( NSCalendarUnitHour | NSCalendarUnitMinute) fromDate: today];
    
    components.hour = [hoursString intValue];
    components.minute = [minutesString intValue];
    
    _timePicker.date =  [gregorian dateFromComponents:components];
    [_timePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
    _selectedTime =  [[NSString stringWithFormat:@"%@", [_timeFormatter stringFromDate:_timePicker.date]] intValue];
    
    [self.view addSubview:_timePicker];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 580, 100, 30)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [addButton setTitle:_langData[@"ADD"] forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:12]];
    [addButton addTarget:self action:@selector(addShowPlaylist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 580, 150, 30)];
    [clearButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [clearButton setTitle:_langData[@"CLEAR DAY"] forState:UIControlStateNormal];
    [clearButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:12]];
    [clearButton addTarget:self action:@selector(clearDay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _invalidTime.alpha = 0;
}

-(void)clearDay{
    
    for (int i = 0; i < 100; i++){
        [_schedule replaceObjectAtIndex:(100 * _dayOfTheWeek + i) withObject:[NSNumber numberWithInt:0]];
    }
    
    [self saveSchedule];
    
}

-(void)changeDateInLabel:(id)sender{
    
    _timeFormatter.dateFormat = @"Hmm";
    _selectedTime =  [[NSString stringWithFormat:@"%@", [_timeFormatter stringFromDate:_timePicker.date]] intValue];
    _timeFormatter.dateFormat = @"mm";
    _selectedTimeMin =  [[NSString stringWithFormat:@"%@", [_timeFormatter stringFromDate:_timePicker.date]] intValue];
    _invalidTime.alpha = 0;
    
    NSLog(@"%d", _selectedTime);
}

#pragma mark - Save Changes

-(void)saveSchedule{
    
    [_defaults setObject:_schedule forKey:@"schedule"];
    
    //Let the scheduler view that we saved data and we are ready do dismiss the view
    [_defaults setObject:[NSNumber numberWithInt: (int)1] forKey:@"dismiss"];
    
}

#pragma mark - Add Playlists

-(void)addShowPlaylist{
    
    if([_schedule[100 * _dayOfTheWeek + 99] intValue] != 0){
        _invalidTime.alpha = 1;
        return;
    }
    
    if(!_selectedShow){
        _invalidTime.alpha = 1;
        return;
    }
    
    if(_selectedTime == 0){
        _selectedTime = 1;
    }
    
    _lowestTime = [_schedule[100 * _dayOfTheWeek] intValue];
    
    for (int i = 100 * _dayOfTheWeek; i < 100 * _dayOfTheWeek + 100; i+=2){
        
        if (_highestTime < [_schedule[i] intValue]){
            
            _highestTime = [_schedule[i] intValue];
            _highestIndex = i;
            
            if ([_schedule[i + 1] intValue] > 0){
                _highestShowPlaylistNum = [_schedule[i + 1] intValue];
                
            }else if ([[[NSString stringWithFormat:@"%@",_schedule[i + 1]] substringToIndex:1] isEqualToString:@"p"]){
                
                NSString *stringWithoutP = [[NSString stringWithFormat:@"%@",_schedule[i + 1]] stringByReplacingOccurrencesOfString:@"p" withString:@""];
                _highestShowPlaylistNum = [stringWithoutP intValue]*-1;
                
            }
        }
    }
    
    NSLog(@"Adding show. highest shownum: %i", _highestShowPlaylistNum);
    
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
        
        if (highestHours >= 1){
            
            highestAddEndingTime = highestHours*100 + (highestMin - (highestHours * 60));
        
        }else{
            
            highestAddEndingTime = highestMin;
            
        }
        
        
        if ((highestMin - (highestHours * 60) + highestStartingTimeMin) >= 60){
            
            highestEndingTime = _highestTime + 100 + (highestMin - (highestHours * 60)) - 60 + 1;
            
        }else{
            
            highestEndingTime = _highestTime + highestAddEndingTime + 1;
            
        }
        
        
    }else{
        
        int playlist = (_highestShowPlaylistNum * -1) - 1;
        highestDuration = [_allPlaylists[playlist][@"duration"] intValue];
        highestMin = highestDuration/60;
        highestHours = highestMin/60;
        
        if (highestHours >= 1){
            
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
    
    NSLog(@"adding show");
    
    int lastDaysStartingTime = 0;
    int lastDaysEndingTime;
    int lastDaysShowNum = [_schedule[(_dayOfTheWeek == 0 ? 699 : (100 * (_dayOfTheWeek - 1)) + 99)] intValue];
    
    if( (_dayOfTheWeek == 1) && ([_schedule[0] intValue] == 0)){
        
        lastDaysStartingTime = 0;
        lastDaysShowNum = 0;
        
    }else{
        
        for (int i = (100 * (_dayOfTheWeek == 0 ? 6 : (_dayOfTheWeek - 1))) + 1; i < (100 * (_dayOfTheWeek == 0 ? 6 : (_dayOfTheWeek - 1))) + (_dayOfTheWeek == 0 ? 100 : 100); i+=2){
            
            NSString *string = [NSString stringWithFormat:@"%@", _schedule[i] ];
            
            if ([string intValue] == 0 && ![[string substringToIndex:1] isEqualToString:@"p"]){
                
                lastDaysStartingTime = [_schedule[i-3] intValue];
                
                if ([_schedule[i - 2] intValue] > 0){
                    
                    lastDaysShowNum = [_schedule[i - 2] intValue];
                    
                }else if ([[[NSString stringWithFormat:@"%@",_schedule[i - 2]] substringToIndex:1] isEqualToString:@"p"]){
                    
                    NSString *stringWithoutP = [[NSString stringWithFormat:@"%@",_schedule[i - 2]] stringByReplacingOccurrencesOfString:@"p" withString:@""];
                    lastDaysShowNum = [stringWithoutP intValue]*-1;
                }
                
                NSLog(@"last days starting time: %i, last day showNum: %i", lastDaysStartingTime, lastDaysShowNum);
                break;
                
            }
        }
    }
    
    NSLog(@"last day show Time: %i", lastDaysStartingTime);
    
    int lastDaysMin;
    int lastDaysHours;
    int lastDaysAddEndingTime;
    int lastDaysDuration;
    int lastDaysStartingTimeMin = [[[NSString stringWithFormat:@"%i", lastDaysStartingTime] substringWithRange:NSMakeRange([ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] > 2 ? [ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] - 2 : [ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] - 1, [ [NSString stringWithFormat:@"%i", lastDaysStartingTime] length] > 2 ? 2 : 1)] intValue];
    
    NSLog(@"ERROR got to here %i" , lastDaysShowNum);
    
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
        
        if(lastDaysHours >= 1){
            
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
    
    for (int i = 100 * _dayOfTheWeek; i < 100 * _dayOfTheWeek + 98; i+=2){
        
        int previousDuration;
        int previousStaringTime = !_schedule[i]? 0 : [_schedule[i] intValue];
        int previousStartingTimeMin = [[[_schedule[i] stringValue] substringWithRange:NSMakeRange([ [_schedule[i] stringValue] length] > 2 ? [ [_schedule[i] stringValue] length] - 2 : [ [_schedule[i] stringValue] length] - 1, [ [_schedule[i] stringValue] length] > 2 ? 2 : 1)] intValue];
        
        int previousShow = 0;
        
        if ([_schedule[i + 1] intValue] > 0){
            
            previousShow = [_schedule[i + 1] intValue];
        }else if ([[[NSString stringWithFormat:@"%@",_schedule[i + 1]] substringToIndex:1] isEqualToString:@"p"]){
            
            NSString *stringWithoutP = [[NSString stringWithFormat:@"%@",_schedule[i + 1]] stringByReplacingOccurrencesOfString:@"p" withString:@""];
            previousShow = [stringWithoutP intValue]*-1;
            
        }
        
        if (previousShow >= 0 ){
            
            int show = [_schedule[i+1] intValue];
            previousDuration = [_shows[show][@"duration"] intValue];
            previousMin = previousDuration/60;
            previousHours = previousMin/60;
            
            if (previousHours >= 1){
                
                previousAddEndingTime = previousHours*100 + (previousMin - (previousHours * 60));
                
            }else{
                previousAddEndingTime = previousMin;
            }
            
            if ((previousMin - (previousHours * 60) + previousStartingTimeMin) >= 60) {
                previousEndingTime = previousStaringTime + 100 + (previousMin - (previousHours * 60)) - 60 + 1;
            } else {
                previousEndingTime = previousStaringTime + previousAddEndingTime + 1;
            }
            
            
        }else{
            
            int playlist = (previousShow * -1) - 1;
            NSLog(@"got playlist: %i", playlist);
            
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
        
        NSLog(@"previous ending time %d", previousEndingTime);
        NSLog(@"previous starting time: %i, Previous min: %i STringValue: %@", previousStaringTime, previousStartingTimeMin,  [_schedule[i] stringValue]);
        NSLog(@"selected time %d", _selectedTime);
        NSLog(@"ending time %d", myEndingTime);
        
        int nextStartingTime;
        
        if(!_schedule[i+2]){
            nextStartingTime = 2400;
        }else{
            nextStartingTime = [_schedule[i+2] intValue];
        }
        
        NSLog(@"highestTime %d, lowestTime %d, highestIndex %d", _highestTime, _lowestTime, _highestIndex);
        int firstNextDaysStarting = [_schedule[_dayOfTheWeek == 6 ? 0 : (100 * (_dayOfTheWeek + 1))] intValue];
        
        if (firstNextDaysStarting == 0){
            firstNextDaysStarting = 2400;
        }
        
        if ((_highestTime == 0) && (_selectedTime >= lastDaysEndingTime - 2400) && (myEndingTime - 2400 <= firstNextDaysStarting)){
          
            [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
            [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
            [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:100 * _dayOfTheWeek];
            
            if ([[[NSString stringWithFormat:@"%@",_selectedShow] substringToIndex:1] isEqualToString:@"p"]){
                
                [_schedule insertObject:_selectedShow atIndex:100 * _dayOfTheWeek + 1];
                
            }else{
                
                [_schedule insertObject:[NSNumber numberWithInt:[_selectedShow intValue]] atIndex:100 * _dayOfTheWeek + 1];
                
            }
            
            
            [self saveSchedule];
            return;
        }
        
        if (((_selectedTime >= lastDaysEndingTime - 2400) && (_highestTime == _lowestTime) && (i == (100 * _dayOfTheWeek))  && (myEndingTime - 2400 <= firstNextDaysStarting))){
            
            if ((((_selectedTime <= _highestTime) && (myEndingTime <= _highestTime)) || (_lowestTime == 0))){
                
                [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
                [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
                [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i];
                
                if([[[NSString stringWithFormat:@"%@",_selectedShow] substringToIndex:1] isEqualToString:@"p"]){
                    [_schedule insertObject:_selectedShow atIndex:i + 1];
                }else{
                    [_schedule insertObject:[NSNumber numberWithInt:[_selectedShow intValue]] atIndex:i + 1];
                }
            
                [self saveSchedule];
                NSLog(@"1");
                NSLog(@"first for same day 1");
                
                break;
                
            }else if((_selectedTime >= _highestTime) && (_selectedTime >= previousEndingTime)){
                
                [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
                [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
                [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i+2];
                
                if([[[NSString stringWithFormat:@"%@",_selectedShow] substringToIndex:1] isEqualToString:@"p"]){
                    [_schedule insertObject:_selectedShow atIndex:i+3];
                }else{
                    [_schedule insertObject:[NSNumber numberWithInt:[_selectedShow intValue]] atIndex:i+3];
                }
                
                [self saveSchedule];
                NSLog(@"2");
                NSLog(@"first for same day 1");
                
                break;
                
            }
            
        }else if (((_selectedTime >= lastDaysEndingTime - 2400) && (_selectedTime <= _lowestTime) && (i == (100 * _dayOfTheWeek)) && (myEndingTime <= previousStaringTime))){
            
            [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
            [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
            [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i];
            
            if([[[NSString stringWithFormat:@"%@",_selectedShow] substringToIndex:1] isEqualToString:@"p"]){
                [_schedule insertObject:_selectedShow atIndex:i + 1];
            }else{
                [_schedule insertObject:[NSNumber numberWithInt:[_selectedShow intValue]] atIndex:i + 1];
            }
            
            [self saveSchedule];
            NSLog(@"first for same day 2");
            break;
            
        }else if (((_selectedTime >= _highestTime) && (_selectedTime >= highestEndingTime))){
            
            if ((myEndingTime - 2400 <= firstNextDaysStarting) && (_selectedTime >= lastDaysEndingTime - 2400)){
                
                [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
                [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
                
                if(_highestShowPlaylistNum < 0){
                    [_schedule insertObject:[NSString stringWithFormat:@"p%i",(_highestShowPlaylistNum * -1)] atIndex:_highestIndex];
                }else{
                    [_schedule insertObject:[NSNumber numberWithInt:_highestShowPlaylistNum] atIndex:_highestIndex];
                }
                
                [_schedule insertObject:[NSNumber numberWithInt:_highestTime] atIndex:_highestIndex];
                [_schedule replaceObjectAtIndex:(_highestIndex +2) withObject:[NSNumber numberWithInt:_selectedTime]];
                
                if([[[NSString stringWithFormat:@"%@",_selectedShow] substringToIndex:1] isEqualToString:@"p"]){
                    
                    [_schedule replaceObjectAtIndex:(_highestIndex + 3) withObject:_selectedShow];
                    
                }else{
                    
                    [_schedule replaceObjectAtIndex:(_highestIndex + 3) withObject:[NSNumber numberWithInt:[_selectedShow intValue]]];
                    
                }
        
                NSLog(@"selected show is: %@", _selectedShow);
                [self saveSchedule];
                
                NSLog(@"Previous starting time: %d", previousStaringTime);
                NSLog(@"Previous ending time: %d", previousEndingTime);
                NSLog(@"My Starting time: %d", _selectedTime);
                NSLog(@"My Ending time: %d", myEndingTime);
                NSLog(@"next starting time: %d", nextStartingTime);
                
                break;
            }
        
        }else if(((previousEndingTime <= _selectedTime) && (myEndingTime <= nextStartingTime))){
            
            [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
            [_schedule removeObjectAtIndex:(100 * _dayOfTheWeek + 98)];
            
            [_schedule insertObject:[NSNumber numberWithInt:_selectedTime] atIndex:i +2];
            
            if ([[[NSString stringWithFormat:@"%@",_selectedShow] substringToIndex:1] isEqualToString:@"p"]){
                [_schedule insertObject:_selectedShow atIndex:i + 3];
            }else{
                [_schedule insertObject:[NSNumber numberWithInt:[_selectedShow intValue]] atIndex:i + 3];
            }
            
            [self saveSchedule];
            NSLog(@"in-between");
            break;
            
        }
    }
    
    NSLog(@"total elements: %lu",(unsigned long)_schedule.count);
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showInvalidTime) userInfo:nil repeats:NO];
    
}


@end
