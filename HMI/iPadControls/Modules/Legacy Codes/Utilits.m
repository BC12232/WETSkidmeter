//
//  Utilits.m
//  iPadControls
//
//  Created by Arpi Derm on 1/4/17.
//  Copyright © 2017 WET. All rights reserved.
//

#import "Utilits.h"

@implementation Utilits

-(NSString *)getCurrentShowInfoWithData:(NSString *)startTime{
    
    NSString *remainingTime = @"";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *blah = [startTime substringWithRange:NSMakeRange(1, startTime.length - 2)];
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
    int totalSeconds = secString - secString2 + (minString - minString2)*60;
    int showDuration = [[defaults objectForKey:@"showDuration"] intValue] - totalSeconds;
    int min = showDuration/60;
    int sec = showDuration % 60;
    
    remainingTime = [NSString stringWithFormat:@"%@: %@%d:%@%d", @"REMAINING",min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
    
    return remainingTime;
    
}






-(NSString *)todaysDateLabel{
    
    NSDate *currentDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy"];
    
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    
    return localDateString;
    
}

-(NSString *)getNextShowTimeWithTime:(NSString *)nextTime{
    
    NSString *time = @"";
    NSMutableString *nextTimeMutated = [NSMutableString stringWithFormat:@"%@",nextTime];
    
    if (nextTime.length == 6){
        
        int hour = [[nextTime substringToIndex:2] intValue];
        hour = hour > 12 ? hour - 12: hour;
        
        [nextTimeMutated insertString:@":" atIndex:4];
        time  = [NSString stringWithFormat:@"%@ %i:%@%@", @"AT" , hour, [nextTimeMutated substringFromIndex:2], [[nextTime substringToIndex:2] intValue] >= 12 ? @"PM" : @"AM" ];
        
    }else if (nextTime.length == 5){
        
        int hour = [[nextTime substringToIndex:1] intValue];
        hour = hour > 12 ? hour - 12: hour;
        
        [nextTimeMutated insertString:@":" atIndex:3];
        time = [NSString stringWithFormat:@"%@ %i:%@AM", @"AT" , hour, [nextTimeMutated substringFromIndex:1]];
        
    }
    
    return time;
    
}

-(Float32)convertArrayToReal:(NSArray *)array{
    
    NSArray *arrayDec1 = [[NSArray alloc] init];
    NSArray *arrayDec2 = [[NSArray alloc] init];
    NSArray *mainArray = [[NSArray alloc] init];
    
    arrayDec1 = [self convertBase10to2 :[array[0] intValue] :15];
    arrayDec2 = [self convertBase10to2 :[array[1] intValue] :15];
    mainArray = [[NSMutableArray alloc] initWithArray:[arrayDec2 arrayByAddingObjectsFromArray:arrayDec1]];
    
    int sign;
    NSMutableString *exponentStr = [[NSMutableString alloc] init];
    NSMutableString *fractionStr = [[NSMutableString alloc] init];
    
    sign = [mainArray[0] intValue];
    
    int index = 0;
    
    for (index = 1; index <= 8; index++){
        [exponentStr appendString:[NSString stringWithFormat:@"%i", [mainArray[index] intValue]]];
    }
    
    for (index = 9; index <= 31; index++){
        [fractionStr appendString:[NSString stringWithFormat:@"%i", [mainArray[index] intValue]]];
    }
    
    int exp;
    exp = [self convertBase2to10 :exponentStr :8];
    
    int fra;
    fra = [self convertBase2to10 :fractionStr :23];
    
    //Float32 realValue;
    Float32 RealNumber = pow(-1, sign)*pow(2,(exp-127))*(1+ (fra/pow(2,23)));
    return RealNumber;
    
}

-(NSArray *)convertBase10to2: (int)num :(int)lim{
    
    //Convert to Base 4
    int base = 2;
    
    //With 4 places
    //256   16  4   1
    //0    3   0   2
    int places = lim;
    
    //Our input number
    int input = num;
    
    NSMutableString *newStr = [[NSMutableString alloc] init];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    
    //We're going to loop through backwards the powers (256, 16, 4, 1 etc) and work out how many times our input evenly goes into it
    for (int index = places; index > -1; index--){
        
        //How many times does 50 go into the power
        int decimal = (int)((double)input / (double)(pow(base, index)));
        
        //Whats the remainder, set it back to input
        input = (int)(input % (int)(pow(base, index)));
        
        [array2 addObject:[NSNumber numberWithInt:decimal]];
        [newStr appendString:[NSString stringWithFormat:@"%i", decimal]];
        
    }
    
    return array2;
}

-(int)convertBase2to10: (NSString*)Str :(int)lim{
    
    NSString *input = Str;
    int base10 = 0;
    
    for (int i=0; i < lim; i++){
        
        NSInteger num = [[input substringFromIndex: [input length] - 1] integerValue];
        
        if (num == 1){
            base10 += pow(2, i);
        }
        
        input = [input substringToIndex: [input length] - 1];
        
    }
    
    return base10;
    
}




@end


