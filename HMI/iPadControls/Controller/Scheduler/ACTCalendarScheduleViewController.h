//
//  ACTCalendarScheduleViewController.h
//  iPadControls
//
//  Created by Ryan Manalo on 4/2/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDVCalendarViewController.h"

@interface ACTCalendarScheduleViewController : UIViewController <RDVCalendarViewDelegate>
@property (weak, nonatomic) NSFileManager *manager;
@end
