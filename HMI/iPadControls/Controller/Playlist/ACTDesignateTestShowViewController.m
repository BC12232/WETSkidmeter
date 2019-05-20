//
//  ACTDesignateTestShowViewController.m
//  iPadControls
//
//  Created by Ryan  on 6/12/15.
//  Copyright (c) 2015 WET. All rights reserved.
//

#import "ACTDesignateTestShowViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "iPadControls-Swift.h"

@interface ACTDesignateTestShowViewController ()
@property (nonatomic) UITableView *showTable;
@property (nonatomic) NSMutableArray *shows;
@property (nonatomic) NSMutableArray *showColors;

@property (weak, nonatomic) NSArray *paths;
@property (weak, nonatomic) NSString *docDir;
@property (weak, nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSString *path;

@property (nonatomic) NSMutableDictionary *settings;
@end

@interface UITableViewCell (ChangeHighlight)
- (void)setSelected:(BOOL)selected;
@end

@implementation UITableViewCell (ChangeHighlight)


-(void)setSelected:(BOOL)selected{
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"isDesignateShows"] == false) {
        if(selected){
            
            self.detailTextLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
            self.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
            
        } else{
            
            self.detailTextLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            self.textLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            
        }
    }
 
}

@end

@implementation ACTDesignateTestShowViewController

-(void)readInternalShowFile{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"shows"]){
        
        _shows = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"shows"]];
        [_showTable reloadData];
        
        _showColors = [[NSMutableArray alloc] init];
        
        for (int i = 0; i <_shows.count; i++){
            [_showColors addObject:_shows[i][@"color"]];
        }
    }
}

-(void)createShowTableView{
    
    UILabel *shows = [[UILabel alloc] initWithFrame:CGRectMake(50, 42, 300, 25)];
    shows.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    shows.font = [UIFont fontWithName:@"Verdana" size:24];
    shows.textAlignment = NSTextAlignmentCenter;
        shows.text = @"TEST SHOWS";
    
    
    [self.view addSubview:shows];
    
    _showTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 400, 270) style:UITableViewStylePlain];
    _showTable.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    _showTable.bounces = NO;
    _showTable.delegate = self;
    _showTable.dataSource = self;
    _showTable.scrollEnabled = YES;
    
    _showTable.allowsMultipleSelection = YES;
    [self.view addSubview:_showTable];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(165,395, 70, 30)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"done_70x30"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(updateTestShows) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addButton];

}


#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _shows.count - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditableTextCell"];
    
    int duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
    int min = duration/60;
    int sec = duration % 60;
    
    if (duration == 0){
        cell.hidden = YES;
    }
        
    cell.textLabel.text = [[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%d:%@%d", min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
    
    cell.detailTextLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    
    cell.textLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    cell.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

   
        if ([[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] boolValue]){
            
            [_showTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            
        }else{
            
            [_showTable deselectRowAtIndexPath:indexPath animated:NO];
            
        }
   
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 0.27)];/// change size as you need.
    separatorLineView.backgroundColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];// you can also put image here
    [cell.contentView addSubview:separatorLineView];

    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float heightForRow = 40;
    int duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
    
    if(duration == 0)
        return 0;
    else
        return heightForRow;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.section == 0);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[_showTable cellForRowAtIndexPath:indexPath];
    
 
        if ([cell.textLabel.textColor isEqual:[UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f]]){
        
            NSMutableDictionary *showProperties = [[NSMutableDictionary alloc] initWithDictionary:_shows[indexPath.row + 1]];
            NSNumber *boolNumber = [NSNumber numberWithBool:NO];
            showProperties[@"test"] = boolNumber;
            
            [_shows replaceObjectAtIndex:indexPath.row + 1 withObject:showProperties];
            
        }else{
            
            NSMutableDictionary *showProperties = [[NSMutableDictionary alloc] initWithDictionary:_shows[indexPath.row + 1]];
            NSNumber *boolNumber = [NSNumber numberWithBool:YES];
            NSNumber *boolNumberNo = [NSNumber numberWithBool:NO];
            showProperties[@"test"] = boolNumber;
            showProperties[@"filler"] = boolNumberNo;
            [_shows replaceObjectAtIndex:indexPath.row + 1 withObject:showProperties];
            
        }
   
    return indexPath;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *showProperties = [[NSMutableDictionary alloc] initWithDictionary:_shows[indexPath.row + 1]];
    
    UITableViewCell *cell = (UITableViewCell *)[_showTable cellForRowAtIndexPath:indexPath];

    
    cell.detailTextLabel.textColor =  [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];

    if (![showProperties[@"test"] boolValue]){
        
        [_showTable deselectRowAtIndexPath:indexPath animated:YES];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        
    }else{
    
        cell.detailTextLabel.textColor =  [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        
    }
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    if (self){

    }
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    _manager = [NSFileManager defaultManager];
    [self readInternalShowFile];
    
    self.preferredContentSize = CGSizeMake(400.0, 460);
    self.view.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    [self createShowTableView];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}

-(void)updateTestShows{
    
    NSLog(@"GOING TO UPDTAE TEST SHOWS");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * ipAddress = [defaults objectForKey:@"serverIpAddress"];
    NSString *fullpath2 = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/writeShows",ipAddress];
    NSData   *jsonData2 = [NSJSONSerialization dataWithJSONObject:_shows options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    NSString *escapedDataString2 = [jsonString2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *strURL2 = [NSString stringWithFormat:@"%@?%@", fullpath2, escapedDataString2];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:strURL2 parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_shows forKey:@"shows"];
        [defaults setObject:@"1" forKey:@"dismissTestShows"];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSLog(@"Error: %@", error);
        
    }];
    

}

@end
