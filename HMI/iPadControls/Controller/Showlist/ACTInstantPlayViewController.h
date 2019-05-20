//
//  ACTInstantPlayViewController.h
//  iPadControls
//
//  Created by Ryan Manalo on 11/21/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface ACTInstantPlayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSFileManager *manager;

@property (weak, nonatomic) IBOutlet UILabel *noConnectionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *handMode;
@property (weak, nonatomic) IBOutlet UIImageView *autoMode;
@property (weak, nonatomic) IBOutlet UIButton *autoHandToggle;
@property (weak, nonatomic) IBOutlet UIImageView *estop;
@property (weak, nonatomic) IBOutlet UIImageView *waterLevel;
@property (weak, nonatomic) IBOutlet UIImageView *wind;
@property (weak, nonatomic) IBOutlet UIImageView *ratMode;

@property (weak, nonatomic) IBOutlet UIView *noConnectionView;


@end
