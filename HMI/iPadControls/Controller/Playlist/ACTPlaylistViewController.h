//
//  ACTPlaylistViewController.h
//  iPadControls
//
//  Created by Ryan Manalo on 3/4/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACTUISafeNavigationController.h"

#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface ACTPlaylistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, ACTUISafeNavigationDelegate>

@property (weak, nonatomic) NSFileManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *handMode;
@property (weak, nonatomic) IBOutlet UIImageView *autoMode;
@property (weak, nonatomic) IBOutlet UIButton *autoHandToggle;
@property (weak, nonatomic) IBOutlet UITableView *playlistTable;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *clearAll;
@property (weak, nonatomic) IBOutlet UIButton *cancelChanges;
@property (weak, nonatomic) IBOutlet UIButton *playStopButton;
@property (weak, nonatomic) IBOutlet UILabel *totalDuration;
@property (weak, nonatomic) IBOutlet UILabel *finishBackwash;
@property (weak, nonatomic) IBOutlet UIView *noConnectionView;
@property (weak, nonatomic) IBOutlet UIView *backwashMsg;
@property (weak, nonatomic) IBOutlet UILabel *noConnectionLabel;
@property (weak, nonatomic) IBOutlet UIView *specialShwMsg;

// methods for possible overriding:
- (void)contentsDidChange;
- (UITextField *)createTextFieldForCell:(UITableViewCell *)cell;

-(void)dismissPopoverView;
@end
