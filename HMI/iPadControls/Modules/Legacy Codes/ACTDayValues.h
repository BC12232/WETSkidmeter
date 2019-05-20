//
//  ACTDayValues.h
//  iPadControls
//
//  Created by Ryan Manalo on 1/27/14.
//  Copyright (c) 2014 Ryan Manalo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACTDayValues : NSObject {
    int selectedAsAWeekend;
    float lightsOn;
    float lightsOff;
    float cascadeOn;
    float cascadeOff;
}

@property (assign, nonatomic) int isWeekend;
@property (assign, nonatomic) float lightsOn;
@property (assign, nonatomic) float lightsOff;
@property (assign, nonatomic) float cascadeOn;
@property (assign, nonatomic) float cascadeOff;

@end
