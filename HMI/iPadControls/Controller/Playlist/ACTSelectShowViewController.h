//
//  ACTSelectShowViewController.h
//  iPadControls
//
//  Created by Ryan Manalo on 3/12/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ACTPlaylistViewController.h"

#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface ACTSelectShowViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UIPickerViewDelegate>
@property (weak, nonatomic) NSFileManager *manager;
@property (nonatomic, copy) NSArray *contents;
@end
