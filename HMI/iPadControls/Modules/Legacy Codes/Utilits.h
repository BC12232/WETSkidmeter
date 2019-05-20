//
//  Utilits.h
//  iPadControls
//
//  Created by Arpi Derm on 1/4/17.
//  Copyright © 2017 WET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilits : NSObject

-(NSString *)getCurrentShowInfoWithData:(NSString *)startTime;
-(NSString *)todaysDateLabel;
-(NSString *)getNextShowTimeWithTime:(NSString *)nextTime;
-(Float32)convertArrayToReal:(NSArray *)array;

@end
