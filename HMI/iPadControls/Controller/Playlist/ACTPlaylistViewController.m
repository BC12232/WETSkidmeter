//
//  ACTPlaylistViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 3/4/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTPlaylistViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "ACTSelectShowViewController.h"
#import "iPadControls-Swift.h"


static NSString *activeTextFieldHint = @"";
static NSString *returnTappedTextFieldHint = @"~"; // HACK to mark when return was tapped

@interface UITextField (ChangeReturnKey)
- (void)changeReturnKey:(UIReturnKeyType)returnKeyType;
@end

@implementation UITextField (ChangeReturnKey)
- (void)changeReturnKey:(UIReturnKeyType)returnKeyType
{
    self.returnKeyType = returnKeyType;
    [self reloadInputViews];
}
@end

@interface ACTPlaylistViewController () <UITextFieldDelegate> {
    NSMutableArray *rowsContent;
}
@property (nonatomic) NSMutableArray *allPlaylists;
@property (nonatomic) NSMutableDictionary *editingPlaylist;
@property (nonatomic) NSMutableDictionary *fillerShowData;
@property (nonatomic) NSMutableArray *playlistContents;
@property (nonatomic) int playlistDuration;
@property (nonatomic) int activePlaylist;
@property (nonatomic) NSMutableArray *shows;
@property (nonatomic) int rowCount;
@property (nonatomic) NSArray *paths;
@property (nonatomic) NSString *docDir;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSInteger selectedShow;
@property (nonatomic) int loopCount;
@property (nonatomic) UISwipeGestureRecognizer *leftswipe;
@property (nonatomic) int  gotInfo;
@property (nonatomic) UISwipeGestureRecognizer *rightswipe;
@property (nonatomic) int viewingPlaylist;
@property (nonatomic) NSTimer *dismissPopoverTimer;
@property (nonatomic) NSString *textfieldText;
@property (nonatomic) UILabel *playingShow;
@property (nonatomic) UILabel *timeRemaining;
@property (nonatomic) int state;
@property (nonatomic) int rainState;
@property (nonatomic) int playStop;
@property (nonatomic) NSString *pass;
@property (nonatomic) NSString *plcip;
@property (nonatomic) NSString *ip;
@property (nonatomic) NSString *outOfRangeMessage;
@property (nonatomic) NSString *autoMan;
@property (nonatomic) NSString *manPlay;
@property (nonatomic) NSMutableArray *serverErrorCount;
@property (nonatomic) NSTimer *only1Ping;
@property (nonatomic) int duration;
@property (nonatomic) int pop;
@property (nonatomic) int readInitialData;
@property (nonatomic) int contentsChanged;
@property (nonatomic) NSTimer *backwashDoneTimer;
@property (nonatomic) int offSetRegisters;
@property (nonatomic, strong) NSDictionary *langData;
@property (nonatomic) bool justPressedPlay;
@property (nonatomic) bool justPressedStop;
@end


@implementation ACTPlaylistViewController{
    ACTSelectShowViewController *controller;
    UIPopoverController *popoverSelectShowController;
}

@synthesize selectedShow;


#pragma mark - View Life Cycle

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self getLanguageData];
    
    _pass = @"http://wet_act:A3139gg1121@";
    _manager = [NSFileManager defaultManager];
    
    [self constructUI];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self initializeFile];
    [self addShowStoppers];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [_dismissPopoverTimer invalidate];
    _dismissPopoverTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}



#pragma mark - construct controller

-(void)getLanguageData{

    NSArray *availableLanguages = @[@"zh", @"ko", @"en", @"es", @"ar", @"ru", @"tr"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages) forPreferences:[NSLocale preferredLanguages]][0];
 
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData* json = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"playlist"]];
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    [_clearAll setTitle:_langData[@"CLEAR"] forState:UIControlStateNormal];
    [_cancelChanges setTitle:_langData[@"CANCEL"]forState:UIControlStateNormal];
    
}

-(void)constructUI{

    _playlistTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _playlistTable.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    _playlistTable.scrollEnabled = NO;
    
    
    _leftswipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeRecognizer:)];
    _leftswipe.delegate = self;
    _leftswipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    _rightswipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeRecognizer:)];
    _rightswipe.delegate = self;
    _rightswipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [_playlistTable addGestureRecognizer: _leftswipe];
    [_playlistTable addGestureRecognizer: _rightswipe];
    
    _pop = 1;
    
    _playingShow = [[UILabel alloc] initWithFrame:CGRectMake(247, 130, 530, 75)];
    _playingShow.font = [UIFont fontWithName:@"Verdana" size:18];
    _playingShow.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    _playingShow.text = @"PLAYING SHOW ";
    _playingShow.textAlignment = NSTextAlignmentLeft;
    _playingShow.alpha = 0;
    [self.view addSubview:_playingShow];
    
    _timeRemaining = [[UILabel alloc] initWithFrame:CGRectMake(687, 130, 200, 75)];
    _timeRemaining.font = [UIFont fontWithName:@"Verdana" size:18];
    _timeRemaining.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    _timeRemaining.text = @"TIME:";
    _timeRemaining.alpha = 0;
    [self.view addSubview:_timeRemaining];

}

-(void)initializeFile{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _ip = [defaults objectForKey:@"serverIpAddress"];

    self.navigationItem.title = @"PLAYLIST";
    _duration = 0;
    
    //Get initial State of SPM: Auto or Hand Mode
    
    
    //Check For Network Connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSystemStat) name:@"updateSystemStat" object:nil];
    
    //Get Playlists and Shows
    [self readJSONFile];
    
}

-(void)updateSystemStat{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverConnectionStatus = [defaults objectForKey:@"ServerConnectionStatus"];
    NSString *plcConnectionStatus   = [defaults objectForKey:@"PLCConnectionStatus"];
    
    if ([plcConnectionStatus isEqualToString:@"PLCConnected"] && [serverConnectionStatus isEqualToString:@"serverConnected"]){
         [self checkAutoHandMode];
        [self getCurrentShowInformation];
        self.noConnectionView.alpha = 0;
        //For the first time on view appearence fetch all necessary data and generate shows table
        if (_gotInfo == 0){
            _gotInfo = 1;
            //Get initial State of SPM: Auto or Hand Mode
            _state = [[defaults objectForKey:@"playMode"] intValue];
            [defaults setObject:[NSNumber numberWithInt:_state] forKey:@"toggledStatus"];
        }
    }else{
        //Show the no connection view
        self.noConnectionView.alpha = 1;
        
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

#pragma mark - Get Data

-(void)readJSONFile{

    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readPlaylists", _pass, _ip];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        _allPlaylists = [[NSMutableArray alloc] initWithArray:responseObject];
        _editingPlaylist = [[NSMutableDictionary alloc] initWithDictionary:_allPlaylists[_viewingPlaylist]];
        _playlistContents = [[NSMutableArray alloc] initWithArray:_allPlaylists[_viewingPlaylist][@"contents"]];
        _playlistDuration = [_allPlaylists[_viewingPlaylist][@"duration"] intValue];
        
        _rowCount = 0;
        
        for(int i = 0; i < _playlistContents.count; i++){
            
            if ([_playlistContents[i] intValue] > 0){
                _rowCount +=1;
            }
        }
        
        _rowCount /= 2;
        
        NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readShows", _pass, _ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            _shows = [[NSMutableArray alloc] initWithArray:responseObject];
            _duration = 0;
            _totalDuration.text = [NSString stringWithFormat:@"%@:  00:00", _langData[@"DURATION"]];
            
            [_playlistTable reloadData];
            
            UITextField *textField = (UITextField *)[self.view viewWithTag:TAG_TEXT_FIELD];
            textField.userInteractionEnabled = NO;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:responseObject forKey:@"shows"];
            
            if ([_editButton.titleLabel.text isEqualToString:_langData[@"SAVE"]]){
                
                for (int row = 0; row < 10; row++){
                    
                    NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
                    UITableViewCell* cell = [_playlistTable cellForRowAtIndexPath:cellPath];
                    UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
                    textField.userInteractionEnabled = YES;
                    
                }
                
                UITextField *textField = (UITextField *)[self.view viewWithTag:TAG_TEXT_FIELD];
                textField.userInteractionEnabled = NO;
                
            }else{
                
                [self disableTextFields];
                
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];

        
        
        
        [_playlistTable reloadData];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
    }];
}

-(void)checkAutoHandMode{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _state = [[defaults objectForKey:@"playMode"] intValue];
    
    //We want to make sure user does not constantly tap on the toggle button
    int toggledValue = [[defaults objectForKey:@"toggledStatus"] intValue];
    
    if (toggledValue != _state){
        self.autoHandToggle.enabled = NO;
    }else{
        self.autoHandToggle.enabled = YES;
    }
    
    if (_state == 0){
        
        _autoMode.alpha = 1;
        _handMode.alpha = 0;
        _playStopButton.alpha = 0;
        
        [self rotateAutoModeImage:YES];
        
    }else{
        
        _autoMode.alpha = 0;
        _handMode.alpha = 1;
        _playStopButton.alpha = 0;
    
        [self rotateAutoModeImage:NO];
        
        int playMode = [[defaults objectForKey:@"playStatus"] intValue];
        int currentShow = [[defaults objectForKey:@"currentShowNumber"] intValue];
        if(playMode == 1 &&  currentShow!= 0){
            
            _playStop = YES; //IT MEANS THE SHOW IS PLAYING
            UIImage *image = [UIImage imageNamed:@"stopButton"];
            [_playStopButton setImage:image forState:UIControlStateNormal];
            _playStopButton.alpha = 1;
            
            if ([_playStopButton isEnabled] == NO && _justPressedPlay == YES){
                [_playStopButton setEnabled:YES];
                _justPressedPlay = NO;
            }
            
        }else{
            
            _playStop = NO; //IT MEANS THE SHOW IS NOT PLAYING
            
            if ([_editButton.titleLabel.text isEqualToString:_langData[@"EDIT"]]){
                
                UIImage *image = [UIImage imageNamed:@"playButton"];
                [_playStopButton setImage:image forState:UIControlStateNormal];
                _playStopButton.alpha = 1;
                
                if ([_playStopButton isEnabled] == NO && _justPressedStop == YES){
                    [_playStopButton setEnabled:YES];
                    _justPressedStop = NO;
                }
            }
        }
        
        //check point for backwash running: If it is not 0: Hide The Play Stop Button
        int backWashRunningStat = [[defaults objectForKey:@"backWashRunningStat"] intValue];
        
        if (backWashRunningStat == 1){
            
            _playStopButton.alpha = 0;
            self.backwashMsg.alpha = 1;
            
        }else{
            
            _playStopButton.alpha = 1;
            self.backwashMsg.alpha = 0;

        }
        
    }
}

-(void)rotateAutoModeImage:(BOOL)value{
    
    if(value){
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = @0.0f;
        animation.toValue = @(2*M_PI);
        animation.duration = 2.0f;
        animation.repeatCount = HUGE_VALF;
        [_autoMode.layer addAnimation:animation forKey:@"rotation"];
        
    }else{
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = @0.0f;
        animation.toValue = @0.0f;
        [_autoMode.layer addAnimation:animation forKey:@"rotation"];
        
    }
}

-(void)reloadTableData{
    
    _duration = 0;
    _totalDuration.text = [NSString stringWithFormat:@"%@:  00:00", _langData[@"DURATION"]];
    _rowCount = 0;
    
    for (int i = 0; i < _playlistContents.count; i++){
        
        if ([_playlistContents[i] intValue] > 0){
            _rowCount +=1;
        }
        
    }
    
    _rowCount /= 2;
    [_playlistTable reloadData];
    
}

#pragma mark - Table Changes

-(void)deleteRow:(NSIndexPath *)indexPath{
    
    _playlistDuration -= [_shows[[[_playlistContents objectAtIndex:indexPath.row * 2] intValue]][@"duration"] intValue] * [[_playlistContents objectAtIndex:indexPath.row * 2 + 1] intValue];

    [_playlistContents removeObjectAtIndex:indexPath.row * 2];
    [_playlistContents removeObjectAtIndex:indexPath.row * 2];
    [_playlistContents addObject:[NSNumber numberWithInt:0]];
    [_playlistContents addObject:[NSNumber numberWithInt:0]];

    _editingPlaylist[@"contents"] = _playlistContents;
    _editingPlaylist[@"duration"] = [NSNumber numberWithInt:_playlistDuration];
    
    [_allPlaylists replaceObjectAtIndex:_viewingPlaylist withObject:_editingPlaylist];
    
    [self reloadTableData];
    [self contentsDidChange];
    
}

-(IBAction)clearAllCells:(UIButton *)sender{
    
    [_playlistContents removeAllObjects];
    
    _playlistContents = [NSMutableArray arrayWithObjects: @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, nil];
    
    _editingPlaylist[@"contents"] = _playlistContents;
    _editingPlaylist[@"duration"] = [NSNumber numberWithInt:0];
    _playlistDuration = 0;
    [_allPlaylists replaceObjectAtIndex:_viewingPlaylist withObject:_editingPlaylist];
    
    if (_rowCount > 0){
        [self contentsDidChange];
    }
    
    [self reloadTableData];
    [self disableTextFields];

}

-(IBAction)cancelAllChanges:(UIButton *)sender{
    
    [self readJSONFile];
    [super setEditing:NO animated:NO];
    
    [_playlistTable setEditing:NO animated:NO];
    [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
    
    _clearAll.alpha = 0;
    _clearAll.userInteractionEnabled = 0;
    _cancelChanges.alpha = 0;
    _cancelChanges.userInteractionEnabled = 0;
    _contentsChanged = 0;

    [_playlistTable addGestureRecognizer: _leftswipe];
    [_playlistTable addGestureRecognizer: _rightswipe];
    
    if (_playStop == 0 && _handMode.alpha == 1){
        
        UIImage *image = [UIImage imageNamed:@"playButton"];
        [_playStopButton setImage:image forState:UIControlStateNormal];
        _playStopButton.alpha = 1;
        
    }
    
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(_rowCount == 10){
        return 10;
    }else{
        return _rowCount + 1;
    }

}

-(UITextField *)createTextFieldForCell:(UITableViewCell *)cell{
    
    CGRect frame = CGRectMake(20,6,cell.contentView.bounds.size.width/2,30);
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];

    textField.frame = frame;
    textField.tag = TAG_TEXT_FIELD;
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return textField;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = CELL_REUSE_IDENTIFIER;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
    
    if(textField == nil){
        
        textField = [self createTextFieldForCell:cell];
        [cell.contentView addSubview:textField];
    }
    
    textField.delegate = self;
    
    if(indexPath.row < _rowCount){
        
        textField.text = [[_playlistContents objectAtIndex:indexPath.row  * 2] intValue] == 0? nil : _shows[[[_playlistContents objectAtIndex:indexPath.row  * 2] intValue]][@"name"];
        textField.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        textField.font = [UIFont fontWithName:@"Verdana" size:16];
        textField.placeholder = nil;
        cell.detailTextLabel.text = [[_playlistContents objectAtIndex:indexPath.row * 2 + 1] intValue] == 0? nil : [[_playlistContents objectAtIndex:indexPath.row * 2 + 1] stringValue];
        
        _duration += [_shows[[[_playlistContents objectAtIndex:indexPath.row  * 2] intValue]][@"duration"] intValue] * [[_playlistContents objectAtIndex:indexPath.row * 2 + 1] intValue];
        int min = _duration/60;
        int sec = _duration % 60;
        
        _totalDuration.text = [NSString stringWithFormat:@"%@:  %@%d:%@%d", _langData[@"DURATION"], min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
        
    }else{
        
        textField.text = nil;
        textField.placeholder = NSLocalizedString(activeTextFieldHint, nil);
        cell.detailTextLabel.text = nil;
        
    }

    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(-50, 0, 700, 0.27)];
    separatorLineView.backgroundColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    [cell.contentView addSubview:separatorLineView];
    
    cell.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    
    if (indexPath.row > 3){
        
        [textField addTarget:self action:@selector(slideFrameUp) forControlEvents:UIControlEventEditingDidBegin];
        [textField addTarget:self action:@selector(slideFrameDown) forControlEvents:UIControlEventEditingDidEnd];
        
    }
    

    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
   
    switch (editingStyle){
            
        case UITableViewCellEditingStyleDelete:{
            [self deleteRow:indexPath];
            break;
        }
            
        case UITableViewCellEditingStyleInsert:{
            [self openPopupShowSelector];
            break;
        }
            
        case UITableViewCellEditingStyleNone:
            break;
    }
}

-(void)openPopupShowSelector{
    
    controller = [[ACTSelectShowViewController alloc] init];
    popoverSelectShowController = [[UIPopoverController alloc] initWithContentViewController:controller];
    popoverSelectShowController.delegate = self;
    
    if ([popoverSelectShowController isPopoverVisible]){
        
        [popoverSelectShowController dismissPopoverAnimated:YES];
    
    }else{

        CGRect popRect = CGRectMake(self.view.center.x,self.view.center.y + 20,1,1);
        [popoverSelectShowController presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:NO animated:YES];
        _dismissPopoverTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(dismissPopoverView) userInfo:nil repeats:YES];
        
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    [self dismissPopoverView];
    [_dismissPopoverTimer invalidate];
    _dismissPopoverTimer = nil;
    
    NSLog(@"yes i will dismiss");
    
    UITextField *textField = (UITextField *)[self.view viewWithTag:TAG_TEXT_FIELD];
    textField.userInteractionEnabled = NO;
    
}

-(void)dismissPopoverView{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int dismiss = [[defaults objectForKey:@"dismiss"] intValue];

    if (dismiss){
        
        [_dismissPopoverTimer invalidate];
        _dismissPopoverTimer = nil;
        [popoverSelectShowController dismissPopoverAnimated:YES];
        
        [defaults setObject:0 forKey:@"dismiss"];

        selectedShow = [[defaults objectForKey:@"selectedShow"] intValue];
        _loopCount = [[defaults objectForKey:@"loopCount"] intValue];
        
        for (int i = 0; i<_playlistContents.count; i++){
            
            if ([_playlistContents[i] integerValue] == 0){
                [_playlistContents replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:(int)selectedShow]];
                [_playlistContents replaceObjectAtIndex:i+1 withObject:[NSNumber numberWithInt:_loopCount]];
                break;
            }
        }
        
        _editingPlaylist[@"contents"] = _playlistContents;
        _playlistDuration += (([_shows[selectedShow][@"duration"] intValue]) * _loopCount);
        _editingPlaylist[@"duration"] = [NSNumber numberWithInt:_playlistDuration];
        [_allPlaylists replaceObjectAtIndex:_viewingPlaylist withObject:_editingPlaylist];
        
        [self reloadTableData];

        
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.editing;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 && indexPath.row < _rowCount;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSNumber *showNum = [NSNumber numberWithInteger:[[_playlistContents objectAtIndex:sourceIndexPath.row * 2] integerValue]];
    NSNumber *loopCount = [NSNumber numberWithInteger:[[_playlistContents objectAtIndex:sourceIndexPath.row * 2 + 1] integerValue]];

    [_playlistContents removeObjectAtIndex:sourceIndexPath.row * 2];
    [_playlistContents removeObjectAtIndex:sourceIndexPath.row * 2];
    [_playlistContents insertObject:loopCount atIndex:destinationIndexPath.row * 2];
    [_playlistContents insertObject:showNum atIndex:destinationIndexPath.row * 2];
    
    
    _editingPlaylist[@"contents"] = _playlistContents;
    [_allPlaylists replaceObjectAtIndex:_viewingPlaylist withObject:_editingPlaylist];
    
    [self contentsDidChange];
    
}

#pragma mark - Table View Delegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_playlistTable.editing){
        
        if (indexPath.section != 0) return UITableViewCellEditingStyleNone;
        return indexPath.row < _rowCount ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
   
    }
    
    return UITableViewCellEditingStyleNone;
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    
    return proposedDestinationIndexPath.section == 0 && proposedDestinationIndexPath.row < _rowCount ? proposedDestinationIndexPath : [NSIndexPath indexPathForRow:_rowCount-1 inSection:0];
    
}

#pragma mark - Table Changes

-(void)contentsDidChange{

    _contentsChanged = 1;
    
    for (int row = 0; row < 10; row++){
        
        NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell* cell = [_playlistTable cellForRowAtIndexPath:cellPath];
        UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
        textField.userInteractionEnabled = YES;
        
    }
    
    if (_rowCount != 10){
        
        UITextField *textField = (UITextField *)[self.view viewWithTag:TAG_TEXT_FIELD];
        textField.userInteractionEnabled = NO;
        
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [NSString stringWithFormat:@"%@ %d", _langData[@"PLAYLIST"],_viewingPlaylist + 1];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;{
    
    return 46;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(_playlistTable.bounds.size.width/2 - 55, 15, 110, 20);
    myLabel.font = [UIFont fontWithName:@"Verdana" size:12];
    myLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}

-(void)SwipeRecognizer:(UISwipeGestureRecognizer *)sender{
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft){
        
        if (_viewingPlaylist < 19){
        
            _viewingPlaylist++;
            
            _editingPlaylist = [[NSMutableDictionary alloc] initWithDictionary:_allPlaylists[_viewingPlaylist]];
            _playlistContents = [[NSMutableArray alloc] initWithArray:_allPlaylists[_viewingPlaylist][@"contents"]];
            _playlistDuration = [_allPlaylists[_viewingPlaylist][@"duration"] intValue];
            
            [self reloadTableData];
            [self disableTextFields];

        }

    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight){

        if (_viewingPlaylist > 0){
            
            _viewingPlaylist--;
            _editingPlaylist = [[NSMutableDictionary alloc] initWithDictionary:_allPlaylists[_viewingPlaylist]];
            _playlistContents = [[NSMutableArray alloc] initWithArray:_allPlaylists[_viewingPlaylist][@"contents"]];
            _playlistDuration = [_allPlaylists[_viewingPlaylist][@"duration"] intValue];
            
            [self reloadTableData];
            [self disableTextFields];

        }
        
    }
    
    if (_playStop == 0){

        NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/autoMan", _pass, _ip];

        NSMutableDictionary *autoMan = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:_state], @"state", [NSNumber numberWithInt:_viewingPlaylist + 1], @"focus", nil];

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:autoMan options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *escapedDataString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *strURL = [NSString stringWithFormat:@"%@?%@", fullpath, escapedDataString]; 
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            NSLog(@"switched to playlist %@", jsonString);
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
  
        }];
    }

}

-(IBAction)editButtonPushed:(id)sender{
    
    if ([_editButton.titleLabel.text isEqualToString:_langData[@"SAVE"]]){
        
        NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/writePlaylists", _pass, _ip];
        NSArray *updatePlaylist = [NSArray arrayWithObjects:_allPlaylists[_viewingPlaylist][@"number"], _allPlaylists[_viewingPlaylist][@"contents"], nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:updatePlaylist options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *escapedDataString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *strURL = [NSString stringWithFormat:@"%@?%@", fullpath, escapedDataString]; 
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"Hello %@",responseObject);
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            NSLog(@"Error: %@", error);
            [_serverErrorCount addObject:error];
            
        }];
        
        
        NSString *fullpath2 = [NSString stringWithFormat:@"%@%@:8080/writeShows", _pass, _ip];
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:_shows options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        NSString *escapedDataString2 = [jsonString2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *strURL2 = [NSString stringWithFormat:@"%@?%@", fullpath2, escapedDataString2]; 
        
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:strURL2 parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            NSLog(@"Error: %@", error);
            [_serverErrorCount addObject:error];
            
        }];
        
        for (int row = 0; row < 10; row++){
            
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
            UITableViewCell* cell = [_playlistTable cellForRowAtIndexPath:cellPath];
            UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
            textField.userInteractionEnabled = NO;
            
        }

    
        [super setEditing:NO animated:NO];
        [_playlistTable setEditing:NO animated:NO];
        [_editButton setTitle:_langData[@"EDIT"] forState:UIControlStateNormal];
        
        _clearAll.alpha = 0;
        _clearAll.userInteractionEnabled = 0;
        _cancelChanges.alpha = 0;
        _cancelChanges.userInteractionEnabled = 0;
        _contentsChanged = 0;

        [_playlistTable addGestureRecognizer: _leftswipe];
        [_playlistTable addGestureRecognizer: _rightswipe];
        
        if (_playStop == 0 && _handMode.alpha == 1){
            
            NSLog(@"showing play button");
            UIImage *image = [UIImage imageNamed:@"playButton"];
            [_playStopButton setImage:image forState:UIControlStateNormal];
            _playStopButton.alpha = 1;
            
        }

    }else{
        
        NSLog(@"VIEWING PLAYLIST: %d",_viewingPlaylist);
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _state = [[defaults objectForKey:@"playStatus"] intValue];
        NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/autoMan", _pass, _ip];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            int playlist = [responseObject[1] intValue];
            NSLog(@"PLAYLIST FROM AUTO MAN: %i",playlist);
            if (((_state == 0) && ( playlist == _viewingPlaylist + 1) )){
                
                [_playlistTable setSeparatorInset:UIEdgeInsetsZero];
                
                for(int row = 0; row < 10; row++){
                    
                    NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
                    UITableViewCell* cell = [_playlistTable cellForRowAtIndexPath:cellPath];
                    UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
                    textField.userInteractionEnabled = YES;
                    
                }
                
                if(_rowCount != 10){
                    
                    UITextField *textField = (UITextField *)[self.view viewWithTag:TAG_TEXT_FIELD];
                    textField.userInteractionEnabled = NO;
                }
                
                [super setEditing:YES animated:YES];
                [_playlistTable setEditing:YES animated:YES];
                [_editButton setTitle:_langData[@"SAVE"] forState:UIControlStateNormal];
                
                _clearAll.alpha = 1;
                _clearAll.userInteractionEnabled = 1;
                _cancelChanges.alpha = 1;
                _cancelChanges.userInteractionEnabled = 1;
                
                [_playlistTable removeGestureRecognizer: _leftswipe];
                [_playlistTable removeGestureRecognizer: _rightswipe];
                
                if(_playStop == 0){
                    
                    NSLog(@"hiding play button");
                    _playStopButton.alpha = 0;
                    
                }
            }
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            NSLog(@"Error: %@", error);
            [_serverErrorCount addObject:error];
            
        }];
    }
}

#pragma mark - perform server operations

-(IBAction)toggleAutoHandMode:(UIButton *)sender{
    
    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/autoMan", _pass, _ip];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int newState = 0;
    
    if (_state == 0){
        
        newState = 1;
        [defaults setObject:[NSNumber numberWithInt:(int)1] forKey:@"toggledStatus"];
        
    }else{
        
        newState = 0;
        [defaults setObject:[NSNumber numberWithInt:(int)0] forKey:@"toggledStatus"];
        
    }
    NSMutableDictionary *autoMan = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:newState], @"state", [NSNumber numberWithInt:_viewingPlaylist+1], @"focus", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:autoMan options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *escapedDataString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *strURL = [NSString stringWithFormat:@"%@?%@", fullpath, escapedDataString];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSString *fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/autoManPlay?0",_ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            [_playStopButton setEnabled:NO];
            _justPressedStop = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];

        [self checkAutoHandMode];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        
    }];
    
}

-(IBAction)togglePlayStop:(UIButton *)sender{
    
    NSString *focusFullPath = [NSString stringWithFormat:@"%@%@:8080/autoMan", _pass, _ip];
    NSMutableDictionary *autoMan = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:_state], @"state", [NSNumber numberWithInt:_viewingPlaylist + 1], @"focus", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:autoMan options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *escapedDataString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *strURL = [NSString stringWithFormat:@"%@?%@", focusFullPath, escapedDataString];
    

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
    }];
    
    if (_playStop == YES){
        
        NSString *fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/autoManPlay?0",_ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            [_playStopButton setEnabled:NO];
            _justPressedStop = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
        
    }else{
        

        NSString *fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/autoManPlay?1",_ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            [_playStopButton setEnabled:NO];
            _justPressedPlay = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
        
    }
}

#pragma mark - UI Operations

-(IBAction)slideFrameUp{
    
    [self slideFrame:YES];

}

-(IBAction)slideFrameDown{
    
    [self slideFrame:NO];
    
}

-(void)slideFrame:(BOOL)up{
    
    const int movementDistance = 245;
    const float movementDuration = 0.5f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    
}

-(void)disableTextFields{
    
    for (int row = 0; row < 10; row++){
        
        NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell* cell = [_playlistTable cellForRowAtIndexPath:cellPath];
        UITextField *textField = (UITextField *)[cell viewWithTag:TAG_TEXT_FIELD];
        textField.userInteractionEnabled = NO;
        
    }
}

#pragma mark - UITextFieldDelegate

-(NSIndexPath *)cellIndexPathForField:(UITextField *)textField{
    
    UIView *view = textField;
    
    while (![view isKindOfClass:[UITableViewCell class]]){
        view = [view superview];
    }
    
    return [_playlistTable indexPathForCell:(UITableViewCell *)view];
    
}

-(NSUInteger)rowIndexForField:(UITextField *)textField{
    return [self cellIndexPathForField:textField].row;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if ([textField.text length] == 0){
        textField.placeholder = NSLocalizedString(activeTextFieldHint, nil);
    }
    
    _textfieldText = textField.text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    textField.placeholder = returnTappedTextFieldHint;
    [textField resignFirstResponder];
    return YES;
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField.text.length == 0){
        
        if ([self rowIndexForField:textField] == _rowCount){
            [textField changeReturnKey:UIReturnKeyNext];
        }
        
    }else{
        
        if (textField.returnKeyType == UIReturnKeyNext && string.length == 0 && range.length == textField.text.length){
            [textField changeReturnKey:UIReturnKeyDone];
        }
        
    }
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    if(textField.returnKeyType == UIReturnKeyNext){
        [textField changeReturnKey:UIReturnKeyDone];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSIndexPath *currRow = [self cellIndexPathForField:textField];
    NSUInteger cellIndex = currRow.row;
    
    if (cellIndex < _rowCount){
        
        NSString *newShowName = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([newShowName length]){
            
            if (![newShowName isEqualToString:_textfieldText]){
                
                _editingPlaylist[@"contents"] = _playlistContents;
                [_allPlaylists replaceObjectAtIndex:_viewingPlaylist withObject:_editingPlaylist];
                int getShowNum = [_playlistContents[cellIndex * 2] intValue];
                
                NSMutableDictionary *updateShowName = [[NSMutableDictionary alloc] initWithDictionary:_shows[getShowNum]];
                updateShowName[@"name"] = textField.text;
                [_shows replaceObjectAtIndex:getShowNum withObject:updateShowName];
                
                [self reloadTableData];
            
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:_shows forKey:@"shows"];
                
                [self contentsDidChange];
                
            }
            
        }else{
            
            [self deleteRow:currRow];
            
        }
    }
}


#pragma mark - Navigation Handlers

-(BOOL)navigationController:(UINavigationController *)navigationController shouldPopViewController:(UIViewController *)controller pop:(void(^)())pop{
    
    if (_contentsChanged == 1){
        
        if (_pop == 1){
            
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Exit now?"
                                                             message:@"All changes made will be lost."
                                                            delegate:self
                                                   cancelButtonTitle:@"Yes"
                                                   otherButtonTitles: nil];
            [alert addButtonWithTitle:@"Cancel"];
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
    
    if (buttonIndex == 0){
        
        _pop = 0;
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(buttonIndex == 1){
        NSLog(@"You have clicked CANCEL");
    }
    
}

-(void)getCurrentShowInformation{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *showScannerOn = [defaults objectForKey:@"scanningShows"];
    
    if ([showScannerOn isEqualToString:@"0"]){
        
        int currentShowNumber = [[defaults objectForKey:@"currentShowNumber"] intValue];
        int showPlaying = [[defaults objectForKey:@"playStatus"] intValue];
        
        NSString *showName = [defaults objectForKey:@"currentShowName"];
        NSString *dateStr =  [defaults objectForKey:@"deflate"];
        
        if (showPlaying && currentShowNumber > 0){
            
            if (_playingShow.alpha != 1){
                _playingShow.alpha = 1;
            }
            
            if (_timeRemaining.alpha != 1){
                _timeRemaining.alpha = 1;
            }
            
            _playingShow.text = [NSString stringWithFormat:@"%@: %@", _langData[@"NOW PLAYING"],showName];
            
            if(_playingShow.text.length > 35){
                
                _playingShow.frame = CGRectMake(247 - (_playingShow.text.length - 35)*4, 130, 600, 75);
                _timeRemaining.frame = CGRectMake(687 + (_playingShow.text.length - 35)*4, 130, 200, 75);
                
            }else{
                
                _playingShow.frame = CGRectMake(247, 130, 530, 75);
                _timeRemaining.frame = CGRectMake(687, 130, 200, 75);
                
            }

            NSString *blah = [dateStr substringWithRange:NSMakeRange(1, dateStr.length - 2)];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSDate *date = [dateFormat dateFromString:blah];
            [dateFormat setDateFormat:@"mm:ss"];
            NSString *date2 = [dateFormat stringFromDate:date];
            
            int minString2 = [[date2 substringToIndex:2] intValue];
            int secString2 = [[date2 substringFromIndex:3] intValue];
            
            NSDate *now =  [[NSDate alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString *nowString = [dateFormat stringFromDate:now];
            NSString *nowString2 = [nowString substringFromIndex:14];
            NSString *nowString3 = [nowString2 substringToIndex:5];
            
            int minString = [[nowString3 substringToIndex:2] intValue];
            int secString = [[nowString3 substringFromIndex:3] intValue];
            
            if(minString2 > minString){
                minString += 60;
            }
            
            int totalSeconds = secString - secString2 + (minString - minString2)*60;
            int showDuration = [[defaults objectForKey:@"showDuration"] intValue] - totalSeconds;
            int min = showDuration/60;
            int sec = showDuration % 60;
            
            _timeRemaining.text = [NSString stringWithFormat:@"%@: %@%d:%@%d", _langData[@"TIME"],min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
            
        }else if (!showPlaying){
            
            _playingShow.alpha = 0;
            _timeRemaining.alpha = 0;
            
        }
    }
}

@end
