//
//  ACTDesignateTestShowViewController.h
//  iPadControls
//
//  Created by Ryan  on 6/12/15.
//  Copyright (c) 2015 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface ACTDesignateTestShowViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) NSFileManager *manager;
@property (nonatomic) NSString *pathString;
@end
