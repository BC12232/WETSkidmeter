//
//  ACTScheduleViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 3/28/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTScheduleViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "ACTMoveDeleteShowPlaylistViewController.h"
#import "ACTAddShowPlaylistViewController.h"
#import "ACTCalendarScheduleViewController.h"
#import "iPadControls-Swift.h"


@interface ACTScheduleViewController ()
@property (nonatomic) float mLastScale;
@property (nonatomic) float mCurrentScale;
@property (nonatomic) NSMutableArray *xOrigins;
@property (nonatomic) NSMutableArray *allDays;
@property (nonatomic) NSMutableArray *sunShows;
@property (nonatomic) NSMutableArray *monShows;
@property (nonatomic) NSMutableArray *tueShows;
@property (nonatomic) NSMutableArray *wedShows;
@property (nonatomic) NSMutableArray *thuShows;
@property (nonatomic) NSMutableArray *friShows;
@property (nonatomic) NSMutableArray *satShows;
@property (nonatomic) NSMutableArray *allPlaylists;
@property (nonatomic) NSMutableDictionary *editingPlaylist;
@property (nonatomic) int playlistDuration;
@property (nonatomic) NSMutableArray *shows;
@property (nonatomic) NSArray *paths;
@property (nonatomic) NSString *docDir;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSMutableArray *scrollViews;
@property (nonatomic) NSTimer *dismissPopoverTimer;
@property (nonatomic) NSMutableArray *schedule;
@property (nonatomic) int currentSchedule;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSString *pass;
@property (nonatomic) NSString *plcip;
@property (nonatomic) int readInitialData;
@property (nonatomic) NSString *ip;
@property (nonatomic) NSString *outOfRangeMessage;
@property (nonatomic) int hoursBefore;
@property (nonatomic) NSString *manPlay;
@property (nonatomic) NSMutableArray *serverErrorCount;
@property (nonatomic) NSTimer *only1Ping;
@property (nonatomic) int pop;
@property (nonatomic) int contentsChanged;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet UIButton *mondayButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UILabel *regularLabel;
@property (weak, nonatomic) IBOutlet UILabel *special1Label;
@property (weak, nonatomic) IBOutlet UILabel *special2Label;
@property (weak, nonatomic) IBOutlet UILabel *special3Label;
@property (nonatomic, strong) NSDictionary *langData;

@property (nonatomic) NSUserDefaults *defaults;
@end

@implementation ACTScheduleViewController{
    
    ACTMoveDeleteShowPlaylistViewController *controller;
    UIPopoverController *popoverMoveDeleteShowController;
    
    ACTAddShowPlaylistViewController *controller2;
    UIPopoverController *popoverAddShowController;
    
    ACTCalendarScheduleViewController *controller3;
    UIPopoverController *popoverCalendarController;
    
}

#pragma mark - View Life Cycle

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self getLanguageData];
    [self addTimeStamps];
    [self constructUITouch];
    
    _pop =1;
    _defaults = [NSUserDefaults standardUserDefaults];
    _pass = @"http://wet_act:A3139gg1121@";
    
}

#pragma mark - View Will Appear

-(void)viewWillAppear:(BOOL)animated{
    
    [self initializeFile];
    [self addShowStoppers];
    [((ACTUISafeNavigationController *) self.navigationController)setSafeDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForConnection) name:@"updateSystemStat" object:nil];
    
}

#pragma mark - Check For Connection

-(void)checkForConnection{
    
    
    NSString *serverConnectionStatus = [_defaults objectForKey:@"ServerConnectionStatus"];
    NSString *plcConnectionStatus   = [_defaults objectForKey:@"PLCConnectionStatus"];
    
    if ([plcConnectionStatus isEqualToString:@"PLCConnected"] && [serverConnectionStatus isEqualToString:@"serverConnected"]){
        self.noConnection.alpha = 0;
        if(_readInitialData == 0){
            [self readPlaylistsAndShows];
            [self checkCurrentSchedule];
            _readInitialData = 1;
        }
    }else{
        //Show the no connection view
        self.noConnection.alpha = 1;
        
        if ([plcConnectionStatus isEqualToString:@"plcFailed"] || [serverConnectionStatus isEqualToString:@"serverFailed"]) {
            if ([serverConnectionStatus isEqualToString:@"serverConnected"]) {
                self.noConnectionLabel.text = @"PLC CONNECTION FAILED, SERVER GOOD";
            } else if ([plcConnectionStatus isEqualToString:@"PLCConnected"]) {
                self.noConnectionLabel.text = @"SERVER CONNECTION FAILED, PLC GOOD";
            } else {
                self.noConnectionLabel.text = @"SERVER AND PLC CONNECTION FAILED";
            }
        }
        
        if ([plcConnectionStatus isEqualToString:@"connectingPLC"] || [serverConnectionStatus isEqualToString:@"connectingServer"]) {
            if ([serverConnectionStatus isEqualToString:@"serverConnected"]) {
                self.noConnectionLabel.text = @"CONNECTING TO PLC, SERVER CONNECTED";
            } else if ([serverConnectionStatus isEqualToString:@"PLCConnected"]) {
                self.noConnectionLabel.text = @"CONNECTING TO SERVER, PLC CONNECTED";
            } else {
                self.noConnectionLabel.text = @"CONNECTING TO SERVER AND PLC..";
            }
        }
        
        if ([plcConnectionStatus isEqualToString:@"poorPLC"] && [serverConnectionStatus isEqualToString:@"poorServer"]) {
            self.noConnectionLabel.text = @"SERVER AND PLC POOR CONNECTION";
        } else if ([plcConnectionStatus isEqualToString:@"poorPLC"]) {
            self.noConnectionLabel.text = @"PLC POOR CONNECTION, SERVER CONNECTED";
        } else if ([serverConnectionStatus isEqualToString:@"poorServer"]) {
            self.noConnectionLabel.text = @"SERVER POOR CONNECTION, PLC CONNECTED";
        }
        
    }
}

#pragma mark - View Will Disappear

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self removeUIObjects];
    
    [_dismissPopoverTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [((ACTUISafeNavigationController *) self.navigationController)
     setSafeDelegate:nil];
    
    _dismissPopoverTimer = nil;
    
}

-(void)viewDidLayoutSubviews{
    
    [_scrollView setContentSize:CGSizeMake(2425, _scrollView.bounds.size.height)];
    [_scrollView setScrollsToTop:YES];
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Initialize Data

-(void)getLanguageData{
    
    _manager = [NSFileManager defaultManager];
    
    NSArray *availableLanguages = @[@"zh", @"ko", @"en", @"es", @"ar", @"ru", @"tr"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages) forPreferences:[NSLocale preferredLanguages]][0];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData *json = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"scheduler"]];
    _xOrigins = [[NSMutableArray alloc] init];
    
    _regularLabel.text = _langData[@"REGULAR"];
    _special1Label.text = [NSString stringWithFormat:@"%@ 1",  _langData[@"SPECIAL"]];
    _special2Label.text = [NSString stringWithFormat:@"%@ 2",  _langData[@"SPECIAL"]];
    _special3Label.text = [NSString stringWithFormat:@"%@ 3",  _langData[@"SPECIAL"]];
    
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    [_clearWeek setTitle:_langData[@"CLEAR WEEK"] forState:UIControlStateNormal];
    [_cancelButton setTitle:_langData[@"CANCEL"] forState:UIControlStateNormal];
    [_sundayButton setTitle:_langData[@"SUNDAY"] forState:UIControlStateNormal];
    [_mondayButton setTitle:_langData[@"MONDAY"] forState:UIControlStateNormal];
    [_tuesdayButton setTitle:_langData[@"TUESDAY"] forState:UIControlStateNormal];
    [_wednesdayButton setTitle:_langData[@"WEDNESDAY"] forState:UIControlStateNormal];
    [_thursdayButton setTitle:_langData[@"THURSDAY"] forState:UIControlStateNormal];
    [_fridayButton setTitle:_langData[@"FRIDAY"] forState:UIControlStateNormal];
    [_saturdayButton setTitle:_langData[@"SATURDAY"] forState:UIControlStateNormal];
    
    self.navigationItem.title = _langData[@"SCHEDULER"];
    
}

-(void)initializeFile{
    
    _ip = [_defaults objectForKey:@"serverIpAddress"];
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"Hmm";
    
    int time =  [[NSString stringWithFormat:@"%@", [timeFormatter stringFromDate:currentTime]] intValue];
    
    //NOTE: offset multiplys by 2: which is a default parameter . It basically positions the scheduler to show data from 2 hours before current time
    int offset = floor(time) - (2 * 100) ;
    
    [_scrollView setContentOffset:CGPointMake(offset, 0)];
    [_timeScrollView setContentOffset:CGPointMake(offset, 0)];
    
}

#pragma mark - Construct UI Touch

-(void)removeUIObjects{
    
    for (int i =1; i<701; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
        
    }
}

-(void)constructUITouch{
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    
    [_pinchZoomView addGestureRecognizer:pinchGesture];
    _scrollView.delegate = self;
    _scrollViews = [[NSMutableArray alloc] initWithObjects:_scrollView, _timeScrollView, nil];
    
    UIGraphicsBeginImageContext(_pinchZoomView.frame.size);
    [[UIImage imageNamed:@"schedBackground"] drawInRect:_pinchZoomView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _pinchZoomView.backgroundColor = [UIColor colorWithPatternImage:image];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
    for (UIScrollView *view in self.scrollViews){
       
        if (scrollView != view){
            [view setContentOffset:scrollView.contentOffset];
        }
        
    }
}

-(void)handlePinch:(UIPinchGestureRecognizer*)sender{
    
    _mCurrentScale += [sender scale] - _mLastScale;
    _mLastScale = [sender scale];
    
    if(_mCurrentScale > 4){
        _mCurrentScale = 4;
    }else if(_mCurrentScale < 1){
        _mCurrentScale =1;
    }
    
    if(sender.state == UIGestureRecognizerStateEnded){
        _mLastScale = 1.0;
    }
    
    CGAffineTransform currentTransform = CGAffineTransformIdentity;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, _mCurrentScale, 1);
    CGAffineTransform reverseTransform = CGAffineTransformInvert(newTransform);
    
    int width = 2400;
    
    if(newTransform.a > 4){
        newTransform.a = 4;
    }else if(newTransform.a < 1){
        newTransform.a =1;
    }
    
    if(newTransform.a > 1 && newTransform.a < 4){
        
        _scrollView.transform = newTransform;
        _timeScrollView.transform = newTransform;
        
        for (int i =1000 ; i <1098; i++){
            UILabel *label = (UILabel *)[_timeScrollView viewWithTag:i];
            label.transform = reverseTransform;
        }
        
        if (newTransform.a > 3){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/11 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/11 * 3), _timeScrollView.bounds.size.height)];
            
        }else if (newTransform.a > 2.7){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/11.7 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/11.7 * 3), _timeScrollView.bounds.size.height)];
            
        }else if (newTransform.a > 2.5){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/12.5 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/12.5 * 3), _timeScrollView.bounds.size.height)];
            
            for (int i =1048; i <1148; i++){
                UILabel *label = (UILabel *)[_timeScrollView viewWithTag:i];
                label.alpha = 1;
                UIView *line = (UIView *)[_scrollView viewWithTag:i];
                line.alpha = 1;
            }
            
        }else if (newTransform.a > 2.3){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/13 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/13 * 3), _timeScrollView.bounds.size.height)];
            
        }else if (newTransform.a > 2){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/13.5 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/13.5 * 3), _timeScrollView.bounds.size.height)];
            
            for (int i =1048 ; i <1148; i++){
                UILabel *label = (UILabel *)[_timeScrollView viewWithTag:i];
                label.alpha = 0;
                UIView *line = (UIView *)[_scrollView viewWithTag:i];
                line.alpha = 0;
            }
            
        }else if (newTransform.a > 1.5 ){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/15.9 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/15.9 * 3), _timeScrollView.bounds.size.height)];
            
            for (int i =1024 ; i <1048; i++){
                
                UILabel *label = (UILabel *)[_timeScrollView viewWithTag:i];
                label.alpha = 1;
                UIView *line = (UIView *)[_scrollView viewWithTag:i];
                line.alpha = 1;
                
            }
            
        }else if(newTransform.a > 1.3 ){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/21 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/21 * 3), _timeScrollView.bounds.size.height)];
            
            for (int i =1024 ; i <1048; i++){
                
                UILabel *label = (UILabel *)[_timeScrollView viewWithTag:i];
                label.alpha = 0;
                UIView *line = (UIView *)[_scrollView viewWithTag:i];
                line.alpha = 0;
                
            }
            
        }else if (newTransform.a > 1 ){
            
            [_scrollView setContentSize:CGSizeMake(width + (width/30 * 3), _scrollView.bounds.size.height)];
            [_timeScrollView setContentSize:CGSizeMake(width + (width/30 * 3), _timeScrollView.bounds.size.height)];
        }
        
        for (int i =1000 ; i <1096; i++){
            
            UILabel *label = (UILabel *)[_timeScrollView viewWithTag:i];
            label.center = CGPointMake([_xOrigins[i-1000] floatValue] + 28.6 - (newTransform.a > 1.5 ?(newTransform.a * 5.05):(newTransform.a * 0.9)), label.center.y);
        }
        
    }
    
    if (newTransform.a > 3.5){
        
        [_scrollView setContentSize:CGSizeMake(width + (width/10.3 * 3), _scrollView.bounds.size.height)];
        [_timeScrollView setContentSize:CGSizeMake(width + (width/10.3 * 3), _timeScrollView.bounds.size.height)];
        
    }
    
    if (newTransform.a < 1){
        
        [_scrollView setContentSize:CGSizeMake(width + 25, _scrollView.bounds.size.height)];
        [_timeScrollView setContentSize:CGSizeMake(width + 25, _timeScrollView.bounds.size.height)];
        
    }
    
    [_scrollView setFrame:CGRectMake(0, 0, 920, 430)];
    [_timeScrollView setFrame:CGRectMake(93, 258, 944, 24)];
    
}

#pragma mark - Scheduler Construction

-(float)convertTimeToPixels:(NSString *)stringTime2{
    
    NSString *stringTime = [NSString stringWithFormat:@"%@", stringTime2];
    NSString *hoursString;
    
    if(stringTime.length == 4){
        
        hoursString =[stringTime substringWithRange:NSMakeRange(0, 2)];
        
    }else if (stringTime.length == 3){
        
        hoursString =[stringTime substringWithRange:NSMakeRange(0, 1)];
        
    }
    
    NSString *minutesString;
    
    if (stringTime.length >1){
        
        minutesString =[stringTime substringWithRange:NSMakeRange([stringTime length] - 2, 2)];
        
    }
    
    int hours;
    float minutes = 0.0;
    
    if (stringTime.length == 1){
        
        hours = 0;
        minutes = [stringTime intValue];
        return hours + minutes;
        
    }else{
        
        hours = [hoursString intValue]*100;
    }
    
    minutes = [minutesString floatValue]/60*100;
    float convertedTime = hours + minutes;
    return convertedTime;
    
}

-(float)convertSecondsToPixels:(int)num{
    
    float hours = num / 60.0 / 60.0 * 100;
    float convertedTime = hours;
    return convertedTime;
    
}

-(void)addTimeStamps{
    
    for (int i = 0; i < 24; i++){
        
        NSString *numString;
        int num = 12+ i;
        CGRect frame = CGRectMake((100*i) - 4, 2, 56, 21);
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        label.font = [UIFont fontWithName:@"Verdana" size:11];
        label.textAlignment = NSTextAlignmentCenter;
        
        if (num < 10){
            
            numString = [NSString stringWithFormat:@"0%d", num];
            
        }else if (num > 24){
            
            numString = [NSString stringWithFormat:@"0%d", num - 24];
            
            if ((num - 24) > 9){
                numString = [NSString stringWithFormat:@"%d", num - 24];
            }
            
        }else if (num > 21){
            
            numString = [NSString stringWithFormat:@"%d", num - 12];
            
        }else if (num > 12){
            
            numString = [NSString stringWithFormat:@"0%d", num - 12];
            
        }else{
            
            numString = [NSString stringWithFormat:@"%d", num];
            
        }
        
        label.text = [NSString stringWithFormat:@"%@:00", numString];
        
        if (num == 12){
            label.text = [NSString stringWithFormat:@"12:00AM"];
        }
        
        if (num == 24){
            label.text = [NSString stringWithFormat:@"12:00PM"];
        }
        
        if (num == 6){
            label.text = [NSString stringWithFormat:@"06:00AM"];
        }
        
        label.tag = 1000 + i;
        [_timeScrollView addSubview:label];
        
        if (i>0){
            
            UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(100 * i, 0, 0.5, 420)];/// change size as you need.
            separatorLineView.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
            [_scrollView addSubview:separatorLineView];
            
        }
        
        [_xOrigins addObject:[NSNumber numberWithFloat:(100*i)-2.5]];
        
    }
    
    for (int i = 1; i < 25; i++){
        
        NSString *numString;
        int num =11+ i;
        CGRect frame = CGRectMake(46 + (100*(i - 1)), 2, 56, 21);
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        label.font = [UIFont fontWithName:@"Verdana" size:11];
        label.textAlignment = NSTextAlignmentCenter;
        
        if (num < 10){
            
            numString = [NSString stringWithFormat:@"0%d", num];
            
        }else if (num > 24){
            
            numString = [NSString stringWithFormat:@"0%d", num - 24];
            
            if ((num - 24) > 9){
                numString = [NSString stringWithFormat:@"%d", num - 24];
            }
            
        }else if (num > 21){
            
            numString = [NSString stringWithFormat:@"%d", num - 12];
            
        }else if (num > 12){
            
            numString = [NSString stringWithFormat:@"0%d", num - 12];
            
        }else{
            
            numString = [NSString stringWithFormat:@"%d", num];
            
        }
        
        label.text = [NSString stringWithFormat:@"%@:30", numString];
        label.tag = 1023 + i;
        label.alpha = 0;
        [_timeScrollView addSubview:label];
        
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(50 + (100*(i - 1)), 0, 0.5, 420)];
        separatorLineView.tag = label.tag;
        separatorLineView.alpha = 0;
        separatorLineView.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
        [_scrollView addSubview:separatorLineView];
        
        [_xOrigins addObject:[NSNumber numberWithFloat:47.5 + (100*(i - 1))]];
        
    }
    
    for (int i = 1; i < 49; i++){
        
        NSString *numString;
        int num =11+ ((i % 2) == 0 ? floor(i/2) : floor(i/2) + 1);
        CGRect frame = CGRectMake(21 + ((50)*(i - 1)), 2, 56, 21);
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        label.font = [UIFont fontWithName:@"Verdana" size:11];
        label.textAlignment = NSTextAlignmentCenter;
        
        if (num < 10){
            
            numString = [NSString stringWithFormat:@"0%d", num];
            
        }else if (num > 24){
            
            numString = [NSString stringWithFormat:@"0%d", num - 24];
            
            if ((num - 24) > 9){
                
                numString = [NSString stringWithFormat:@"%d", num - 24];
                
            }
            
        }else if (num > 21){
            
            numString = [NSString stringWithFormat:@"%d", num - 12];
            
        }else if (num > 12){
            
            numString = [NSString stringWithFormat:@"0%d", num - 12];
            
        }else{
            
            numString = [NSString stringWithFormat:@"%d", num];
            
        }
        
        if ((i % 2) == 0){
            
            label.text = [NSString stringWithFormat:@"%@:45", numString];
            
        }else{
            
            label.text = [NSString stringWithFormat:@"%@:15", numString];
            
        }
        
        label.tag = 1047 + i;
        label.alpha = 0;
        [_timeScrollView addSubview:label];
        
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(25 + ((50)*(i - 1)), 0, 0.5, 420)];
        separatorLineView.tag = label.tag;
        separatorLineView.alpha = 0;
        separatorLineView.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
        [_scrollView addSubview:separatorLineView];
        [_xOrigins addObject:[NSNumber numberWithFloat:22.5 + ((50)*(i - 1))]];
        
    }
}

#pragma mark - Data Handler

-(void)readPlaylistsAndShows{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readPlaylists", _pass, _ip];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        //Get all playlists from the server and save it to the user defaults
        _allPlaylists = [[NSMutableArray alloc] initWithArray:responseObject];
        [defaults setObject:_allPlaylists forKey:@"playlists"];
        
        NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readShows", _pass, _ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            _shows = [[NSMutableArray alloc] initWithArray:responseObject];
            _currentSchedule = [defaults integerForKey:@"CurrentSchedule"];
            [self readJSONFile: _currentSchedule];
            
            
            switch (_currentSchedule) {
                case 1:
                    _regSched.layer.cornerRadius = 20;
                    _regSched.layer.borderWidth = 2.5f;
                    [[_regSched layer] setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0].CGColor];
                    [self animateBorderWithButton:_regSched];
                    break;
                case 2:
                    _sp1Sched.layer.cornerRadius = 20;
                    _sp1Sched.layer.borderWidth = 2.5f;
                    
                    [[_sp1Sched layer] setBorderColor:[UIColor colorWithRed:0/255.0 green:154/255.0 blue:255/255.0 alpha:85.0].CGColor];
                    [self animateBorderWithButton:_sp1Sched];
                    break;
                case 3:
                    _sp2Sched.layer.cornerRadius = 20;
                    _sp2Sched.layer.borderWidth = 2.5f;
                    
                    [[_sp2Sched layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:52/255.0 blue:47/255.0 alpha:0.85].CGColor];
                    [self animateBorderWithButton:_sp2Sched];
                    break;
                case 4:
                    _sp3Sched.layer.cornerRadius = 20;
                    _sp3Sched.layer.borderWidth = 2.5f;
                    
                    [[_sp3Sched layer] setBorderColor:[UIColor colorWithRed:57/255.0 green:181/255.0 blue:74/255.0 alpha:0.85].CGColor];
                    [self animateBorderWithButton:_sp3Sched];
                    break;
                    
                default:
                    break;
            }
            
            //Save all the shows in the user defaults
            [defaults setObject:responseObject forKey:@"shows"];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            NSLog(@"Error: %@", error);
            [_serverErrorCount addObject:error];
            
        }];
        
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSLog(@"Error: %@", error);
        [_serverErrorCount addObject:error];
        
    }];
    
}


-(IBAction)clearWeekPushed:(UIButton *)sender{
    
    for (int i=0; i<700; i++){
        [_schedule replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
    }
    
    for (int i =1; i<701; i++){
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
    }
    
    [_defaults setObject:_schedule forKey:@"schedule"];
    [self reloadScheduler];
    
    _contentsChanged = 1;
    
}

-(IBAction)cancelChanges:(UIButton *)sender{
    
    for (int i =1; i<701; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
        
    }
    
    for (int i = 5000; i<5007; i++){
        
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    
    _regSched.userInteractionEnabled = NO;
    _sp1Sched.userInteractionEnabled = NO;
    _sp2Sched.userInteractionEnabled = NO;
    _sp3Sched.userInteractionEnabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self readJSONFile:_currentSchedule];
        
    });
    
    _cancelButton.alpha = 0;
    _cancelButton.userInteractionEnabled = NO;
    _clearWeek.alpha = 0;
    _clearWeek.userInteractionEnabled = NO;
    _contentsChanged = 0;
    
}

#pragma mark - different scheduler options

-(IBAction)regularScheduleButton:(UIButton *)sender{
    
    //contentsChanged suggest that the current selected scheduler has been modified
    
    if (_contentsChanged == 1){
        
        [self confirmChangingSchedule:2];
        return;
        
    }
    
    for (int i =1; i<701; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
        
    }
    
    _currentSchedule = 1;
    
    _regSched.layer.cornerRadius = 20;
    _regSched.layer.borderWidth = 2.5f;
    [[_regSched layer] setBorderColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.85].CGColor];
    
    _sp1Sched.layer.borderWidth = 0.0f;
    _sp2Sched.layer.borderWidth = 0.0f;
    _sp3Sched.layer.borderWidth = 0.0f;
    
    for (int i = 1; i<700; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    for (int i = 5000; i<5007; i++){
        
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    
    _contentsChanged = 0;
    _cancelButton.alpha = 0;
    _cancelButton.userInteractionEnabled = NO;
    _clearWeek.alpha = 0;
    _clearWeek.userInteractionEnabled = NO;
    
    _regSched.userInteractionEnabled = NO;
    _sp1Sched.userInteractionEnabled = NO;
    _sp2Sched.userInteractionEnabled = NO;
    _sp3Sched.userInteractionEnabled = NO;
    
    //Read the schedule data from server
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self readJSONFile:_currentSchedule];
        
    });
    
}

-(IBAction)specialSchedule1Button:(UIButton *)sender{
    
    //contentsChanged suggest that the current selected scheduler has been modified
    if (_contentsChanged == 1){
        
        [self confirmChangingSchedule:3];
        return;
        
    }
    
    for (int i =1; i<701; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
        
    }
    
    _currentSchedule = 2;
    _sp1Sched.layer.cornerRadius = 20;
    _sp1Sched.layer.borderWidth = 2.5f;
    
    [[_sp1Sched layer] setBorderColor:[UIColor colorWithRed:0/255.0 green:154/255.0 blue:255/255.0 alpha:85.0].CGColor];
    
    _regSched.layer.borderWidth = 0.0f;
    _sp2Sched.layer.borderWidth = 0.0f;
    _sp3Sched.layer.borderWidth = 0.0f;
    
    for (int i = 1; i<700; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    for (int i = 5000; i<5007; i++){
        
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    
    _contentsChanged = 0;
    _cancelButton.alpha = 0;
    _cancelButton.userInteractionEnabled = NO;
    _clearWeek.alpha = 0;
    _clearWeek.userInteractionEnabled = NO;
    _regSched.userInteractionEnabled = NO;
    _sp1Sched.userInteractionEnabled = NO;
    _sp2Sched.userInteractionEnabled = NO;
    _sp3Sched.userInteractionEnabled = NO;
    
    
    //Read the correspoding schedule data from server
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self readJSONFile:_currentSchedule];
        
    });
    
}

-(IBAction)specialSchedule2Button:(UIButton *)sender{
    
    //contentsChanged suggest that the current selected scheduler has been modified
    if (_contentsChanged == 1){
        
        [self confirmChangingSchedule:4];
        return;
        
    }
    
    for (int i =1; i<701; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
        
    }
    
    _currentSchedule = 3;
    _sp2Sched.layer.cornerRadius = 20;
    _sp2Sched.layer.borderWidth = 2.5f;
    
    [[_sp2Sched layer] setBorderColor:[UIColor colorWithRed:236/255.0 green:52/255.0 blue:47/255.0 alpha:0.85].CGColor];
    
    _regSched.layer.borderWidth = 0.0f;
    _sp1Sched.layer.borderWidth = 0.0f;
    _sp3Sched.layer.borderWidth = 0.0f;
    
    for (int i = 1; i<700; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    for (int i = 5000; i<5007; i++){
        
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    
    _contentsChanged = 0;
    _cancelButton.alpha = 0;
    _cancelButton.userInteractionEnabled = NO;
    _clearWeek.alpha = 0;
    _clearWeek.userInteractionEnabled = NO;
    
    _regSched.userInteractionEnabled = NO;
    _sp1Sched.userInteractionEnabled = NO;
    _sp2Sched.userInteractionEnabled = NO;
    _sp3Sched.userInteractionEnabled = NO;
    
    //Read corresponding chosen schedule data from server
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self readJSONFile:_currentSchedule];
        
    });
    
}

-(IBAction)specialSchedule3Button:(UIButton *)sender{
    
    //contentsChanged suggest that the current selected scheduler has been modified
    if (_contentsChanged == 1){
        
        [self confirmChangingSchedule:5];
        return;
        
    }
    
    for (int i =1; i<701; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        [button removeFromSuperview];
        
    }
    
    _currentSchedule = 4;
    _sp3Sched.layer.cornerRadius = 20;
    _sp3Sched.layer.borderWidth = 2.5f;
    
    [[_sp3Sched layer] setBorderColor:[UIColor colorWithRed:57/255.0 green:181/255.0 blue:74/255.0 alpha:0.85].CGColor];
    
    _regSched.layer.borderWidth = 0.0f;
    _sp1Sched.layer.borderWidth = 0.0f;
    _sp2Sched.layer.borderWidth = 0.0f;
    
    for (int i = 1; i<700; i++){
        
        UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    for (int i = 5000; i<5007; i++){
        
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.userInteractionEnabled = NO;
        
    }
    
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    
    _contentsChanged = 0;
    _cancelButton.alpha = 0;
    _cancelButton.userInteractionEnabled = NO;
    _clearWeek.alpha = 0;
    _clearWeek.userInteractionEnabled = NO;
    
    _regSched.userInteractionEnabled = NO;
    _sp1Sched.userInteractionEnabled = NO;
    _sp2Sched.userInteractionEnabled = NO;
    _sp3Sched.userInteractionEnabled = NO;
    
    
    //Get corresponding schedule data from server
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self readJSONFile:_currentSchedule];
        
    });
    
}

#pragma amark - make sure the user wants to change the schedule before loosing all data

-(void)confirmChangingSchedule:(int)num{
    
    //TODO: Rewrite the depricated alert view code
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Switch Schedules?"
                                                     message:@"All changes made will be lost."
                                                    delegate:self
                                           cancelButtonTitle:@"Yes"
                                           otherButtonTitles: nil];
    [alert addButtonWithTitle:@"Cancel"];
    alert.tag = num;
    [alert show];
    
}

#pragma mark - read the schedule data froms erver based on chosen schedule

-(void)readJSONFile:(int)num{
    
    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readScheduler?%d", _pass, _ip, num];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        _allDays = [[NSMutableArray alloc] initWithArray:responseObject];
        _sunShows = [[NSMutableArray alloc] init];
        _monShows = [[NSMutableArray alloc] init];
        _tueShows = [[NSMutableArray alloc] init];
        _wedShows = [[NSMutableArray alloc] init];
        _thuShows = [[NSMutableArray alloc] init];
        _friShows = [[NSMutableArray alloc] init];
        _satShows = [[NSMutableArray alloc] init];
        
        _schedule = [[NSMutableArray alloc] initWithArray:_allDays];
        
        for (int i = 0; i < 100; i++){
            [_sunShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        for (int i = 100; i < 200; i++){
            [_monShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        for (int i = 200; i < 300; i++){
            [_tueShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        for (int i = 300; i < 400; i++){
            [_wedShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        for (int i = 400; i < 500; i++){
            [_thuShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        for (int i = 500; i < 600; i++){
            [_friShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        for (int i = 600; i < 700; i++){
            [_satShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
        }
        
        [self populateWeek:_sunShows tag:0 yAxis:0 userInteractionEnabled:NO];
        [self populateWeek:_monShows tag:100 yAxis:60 userInteractionEnabled:NO];
        [self populateWeek:_tueShows tag:200 yAxis:120 userInteractionEnabled:NO];
        [self populateWeek:_wedShows tag:300 yAxis:180 userInteractionEnabled:NO];
        [self populateWeek:_thuShows tag:400 yAxis:240 userInteractionEnabled:NO];
        [self populateWeek:_friShows tag:500 yAxis:300 userInteractionEnabled:NO];
        [self populateWeek:_satShows tag:600 yAxis:360 userInteractionEnabled:NO];
        
        [_defaults setObject:_allDays forKey:@"schedule"];
        
        _regSched.userInteractionEnabled = YES;
        _sp1Sched.userInteractionEnabled = YES;
        _sp2Sched.userInteractionEnabled = YES;
        _sp3Sched.userInteractionEnabled = YES;
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSLog(@"Error: %@", error);
        
        _regSched.userInteractionEnabled = YES;
        _sp1Sched.userInteractionEnabled = YES;
        _sp2Sched.userInteractionEnabled = YES;
        _sp3Sched.userInteractionEnabled = YES;
        [_serverErrorCount addObject:error];
        
    }];
    
}

-(void)populateWeek:(NSMutableArray *)day tag:(int)num yAxis:(int)height userInteractionEnabled:(BOOL)value{
    
    UIColor *blockColors;
    
    if (_currentSchedule == 1){
        blockColors = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.85];
    }else if (_currentSchedule == 2){
        blockColors = [UIColor colorWithRed:0/255.0 green:154/255.0 blue:255/255.0 alpha:85.0];
    }else if (_currentSchedule == 3){
        blockColors = [UIColor colorWithRed:236/255.0 green:52/255.0 blue:47/255.0 alpha:0.85];
    }else if (_currentSchedule == 4){
        blockColors = [UIColor colorWithRed:57/255.0 green:181/255.0 blue:74/255.0 alpha:0.85];
    }
    
    num += 1;
    
    for (int i=0; i < day.count; i+=2){
        
        if (([day[i] intValue] != 0)){
            
            if ([day[i+1] intValue] > 0){
                
                int show = [day[i+1] intValue];
                
                //We want to get the show duration
                if (show < _shows.count){
                    
                    int duration = [_shows[show][@"duration"] intValue];
                    CGRect frame = CGRectMake([self convertTimeToPixels:day[i]], height, [self convertSecondsToPixels:duration], 60);
                    
                    UIButton *button = [[UIButton alloc] initWithFrame:frame];
                    button.backgroundColor = blockColors;
                    button.tag = i + num;
                    
                    [button addTarget:self action:@selector(moveDeleteShowPlaylist:) forControlEvents:UIControlEventTouchUpInside];
                    button.userInteractionEnabled = value;
                    [_scrollView addSubview:button];
                    
                }else{
                    
                    NSLog(@"The Schedule File In Server is corrupted check to see what is the issue.");
                    
                }
                
            }else{
                
                NSString *stringWithoutP = [day[i+1] stringByReplacingOccurrencesOfString:@"p" withString:@""];
                int playlist = [stringWithoutP intValue] - 1;
                int duration = [_allPlaylists[playlist][@"duration"] intValue];
                CGRect frame = CGRectMake([self convertTimeToPixels:day[i]], height, [self convertSecondsToPixels:duration], 60);
                
                
                UIButton *button = [[UIButton alloc] initWithFrame:frame];
                button.backgroundColor = blockColors;
                button.tag = i + num;
                [button addTarget:self action:@selector(moveDeleteShowPlaylist:) forControlEvents:UIControlEventTouchUpInside];
                button.userInteractionEnabled = value;
                [_scrollView addSubview:button];
                
            }
        }
    }
}

#pragma mark - modify schedule

-(void)moveDeleteShowPlaylist:(UIButton *)button{
    
    [_defaults setObject:[NSNumber numberWithInt: (int)button.tag] forKey:@"buttonTag"];
    [_defaults setObject:[NSNumber numberWithInt: (int)0] forKey:@"dismiss"];
    
    controller = [[ACTMoveDeleteShowPlaylistViewController alloc] init];
    popoverMoveDeleteShowController = [[UIPopoverController alloc] initWithContentViewController:controller];
    popoverMoveDeleteShowController.delegate = self;
    
    if ([popoverMoveDeleteShowController isPopoverVisible]){
        
        [popoverMoveDeleteShowController dismissPopoverAnimated:YES];
        
    }else{
        
        CGRect popRect = CGRectMake(self.view.center.x,self.view.center.y,1,1);
        [popoverMoveDeleteShowController presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:NO animated:YES];
        _dismissPopoverTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(dismissPopoverView) userInfo:nil repeats:YES];
        
    }
    
}

-(IBAction)addShowPlaylist:(UIButton *)sender{
    
    [_defaults setObject:[NSNumber numberWithInt: (int)sender.tag] forKey:@"buttonTag"];
    [_defaults setObject:[NSNumber numberWithInt: (int)0] forKey:@"dismiss"];
    
    controller2 = [[ACTAddShowPlaylistViewController alloc] init];
    popoverAddShowController = [[UIPopoverController alloc] initWithContentViewController:controller2];
    popoverAddShowController.delegate = self;
    
    if ([popoverAddShowController isPopoverVisible]){
        
        [popoverAddShowController dismissPopoverAnimated:YES];
        
    }else{
        
        CGRect popRect = CGRectMake(self.view.center.x,self.view.center.y + 20,1,1);
        
        [popoverAddShowController presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:NO animated:YES];
        _dismissPopoverTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(dismissPopoverView) userInfo:nil repeats:YES];
        
    }
}

-(void)reloadScheduler{
    
    _allDays = [[NSMutableArray alloc] initWithArray:_schedule];
    _sunShows = [[NSMutableArray alloc] init];
    _monShows = [[NSMutableArray alloc] init];
    _tueShows = [[NSMutableArray alloc] init];
    _wedShows = [[NSMutableArray alloc] init];
    _thuShows = [[NSMutableArray alloc] init];
    _friShows = [[NSMutableArray alloc] init];
    _satShows = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 100; i++){
        [_sunShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    for (int i = 100; i < 200; i++){
        [_monShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    for (int i = 200; i < 300; i++){
        [_tueShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    for (int i = 300; i < 400; i++){
        [_wedShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    for (int i = 400; i < 500; i++){
        [_thuShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    for (int i = 500; i < 600; i++){
        [_friShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    for (int i = 600; i < 700; i++){
        [_satShows addObject:[NSString stringWithFormat:@"%@", _allDays[i]]];
    }
    
    [self populateWeek:_sunShows tag:0 yAxis:0 userInteractionEnabled:YES];
    [self populateWeek:_monShows tag:100 yAxis:60 userInteractionEnabled:YES];
    [self populateWeek:_tueShows tag:200 yAxis:120 userInteractionEnabled:YES];
    [self populateWeek:_wedShows tag:300 yAxis:180 userInteractionEnabled:YES];
    [self populateWeek:_thuShows tag:400 yAxis:240 userInteractionEnabled:YES];
    [self populateWeek:_friShows tag:500 yAxis:300 userInteractionEnabled:YES];
    [self populateWeek:_satShows tag:600 yAxis:360 userInteractionEnabled:YES];
    
}

-(IBAction)editButtonPushed:(id)sender{
    
    if ([_editButton.titleLabel.text isEqualToString:_langData[@"SAVE"]]){
        if (_schedule == (id)[NSNull null] || [_schedule count] != 0) {
            for (int i = 1; i<700; i++){
                
                UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
                button.userInteractionEnabled = NO;
                
            }
            
            for (int i = 5000; i<5007; i++){
                
                UIButton *button = (UIButton *)[self.view viewWithTag:i];
                button.userInteractionEnabled = NO;
                
            }
            
            NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/writeScheduler", _pass, _ip];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_schedule options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *escapedDataString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *strURL = [NSString stringWithFormat:@"%@%d?%@", fullpath, _currentSchedule, escapedDataString];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
            
            [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
                
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
            }];
            
            [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
            
            _cancelButton.alpha = 0;
            _cancelButton.userInteractionEnabled = NO;
            _clearWeek.alpha = 0;
            _clearWeek.userInteractionEnabled = NO;
            _contentsChanged = 0;
        }
        
        
    }else{
        
        for (int i = 1; i<700; i++){
            
            UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
            button.userInteractionEnabled = YES;
            
        }
        
        for (int i = 5000; i<5007; i++){
            
            UIButton *button = (UIButton *)[self.view viewWithTag:i];
            button.userInteractionEnabled = YES;
            
        }
        
        
        [_editButton setTitle:_langData[@"SAVE"] forState:UIControlStateNormal];
        _cancelButton.alpha = 1;
        _cancelButton.userInteractionEnabled = YES;
        _clearWeek.alpha = 1;
        _clearWeek.userInteractionEnabled = YES;
        
    }
    
}

#pragma mark - navigation handler

-(void)dismissPopoverView{
    
    int dismiss =[[_defaults objectForKey:@"dismiss"] intValue];
    
    if (dismiss){
        
        [_dismissPopoverTimer invalidate];
        _dismissPopoverTimer = nil;
        
        [popoverMoveDeleteShowController dismissPopoverAnimated:YES];
        [popoverAddShowController dismissPopoverAnimated:YES];
        
        [_defaults setObject:[NSNumber numberWithInt: (int)0]  forKey:@"dismiss"];
        _schedule = [[NSMutableArray alloc]initWithArray:[_defaults objectForKey:@"schedule"]];
        
        for (int i =1; i<701; i++){
            UIButton *button = (UIButton *)[_scrollView viewWithTag:i];
            [button removeFromSuperview];
        }
        
        [self reloadScheduler];
        _contentsChanged = 1;
        
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    [_dismissPopoverTimer invalidate];
    _dismissPopoverTimer = nil;
    
}

-(IBAction)openCalendarSchedule:(UIButton *)sender{
    
    controller3 = [[ACTCalendarScheduleViewController alloc] init];
    popoverCalendarController = [[UIPopoverController alloc] initWithContentViewController:controller3];
    popoverCalendarController.delegate = self;
    
    if ([popoverCalendarController isPopoverVisible]){
        [popoverCalendarController dismissPopoverAnimated:YES];
    }else{
        CGRect popRect = CGRectMake(self.view.center.x,self.view.center.y,1,1);
        [popoverCalendarController presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:NO animated:YES];
    }
}

-(BOOL)navigationController:(UINavigationController *)navigationController shouldPopViewController:(UIViewController *)controller pop:(void(^)())pop{
    
    
    NSLog(@"CHECKING NAVIAGTION");
    if (_contentsChanged == 1){
        
        if (_pop == 1){
            
            
            
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Exit now?"
                                                             message:@"All changes made will be lost."
                                                            delegate:self
                                                   cancelButtonTitle:@"Yes"
                                                   otherButtonTitles: nil];
            [alert addButtonWithTitle:@"Cancel"];
            alert.tag = 1;
            [alert show];
            
            return NO;
            
        }else{
            
            pop();
            return YES;
            
        }
    }
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1){
        
        if (buttonIndex == 0){
            _pop = 0;
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        
        if (buttonIndex == 0){
            
            _contentsChanged = 0;
            
            if (alertView.tag == 2) {
                [self regularScheduleButton:nil];
            } else if (alertView.tag == 3) {
                [self specialSchedule1Button:nil];
            } else if (alertView.tag == 4) {
                [self specialSchedule2Button:nil];
            } else if (alertView.tag == 5) {
                [self specialSchedule3Button:nil];
            }
        }
    }
}

@end
