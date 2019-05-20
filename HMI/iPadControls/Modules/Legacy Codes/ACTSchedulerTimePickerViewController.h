//
//  ACTSchedulerTimePickerViewController.h
//  iPadControls
//
//  Created by Ryan Manalo on 10/2/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACTSchedulerTimePickerViewController : UIViewController{
    
    NSNumber *timeChosen;
    NSNumber *buttonTag;
    NSString *currentValue;
    
}
@property (nonatomic, retain) NSNumber *timeChosen;
@property (nonatomic, retain) NSNumber *buttonTag;
@property (nonatomic, retain) NSString *currentValue;

@property (weak, nonatomic) NSFileManager *manager;

@property (nonatomic) int eqroomNum;
@end
