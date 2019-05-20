//
//  ObjectiveLibModbus.m
//  LibModbusTest
//
//  Created by Lars-Jørgen Kristiansen on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define modbusQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "ObjectiveLibModbus.h"

@implementation ObjectiveLibModbus
@synthesize ipAddress=_ipAddress;

-(id)initWithTCP:(NSString *)ipAddress port: (int)port device:(int)device{
    
    self = [self init];
    
    if(self != nil){
        // your code here
        modbusQueue = dispatch_queue_create("com.iModbus.modbusQueue", NULL);
        if ([self setupTCP:ipAddress port:port device:device])
            return self;
    }
    
    return NULL;
}

- (BOOL)setupTCP: (NSString *)ipAddress port: (int)port device:(int)device
{
    modbusQueue = dispatch_queue_create("com.iModbus.modbusQueue", NULL);
    
    _ipAddress= ipAddress;
    mb = modbus_new_tcp([ipAddress cStringUsingEncoding: NSASCIIStringEncoding], port);
    modbus_set_error_recovery(mb,MODBUS_ERROR_RECOVERY_LINK | MODBUS_ERROR_RECOVERY_PROTOCOL);
    modbus_set_slave(mb, device);
    return YES;
}

- (BOOL) connectWithError:(NSError**)error {
    int ret = modbus_connect(mb);
    if (ret == -1) {
        NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:errorString forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
        return NO;
    }
    return YES;
}

- (void) connect:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        int ret = modbus_connect(mb);
        if (ret == -1) {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
    });
}

- (void) disconnect {
    modbus_close(mb);
}

- (void) writeType:(functionType)type address:(int)address to:(int)value success:(void (^)())success failure:(void (^)(NSError *error))failure {
    if (type == kBits) {
        [self writeBit:address to:value success:^{
            success();
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kRegisters) {
        [self writeRegister:address to:value success:^{
            success();
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else {
        NSString *errorString = @"Could not write. Function type is read only";
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:errorString forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
        failure(error);
    }
}

-(void)readType:(functionType)type startAddress:(int)address count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    
    if (type == kInputBits) {
        
        [self readInputBitsFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kBits) {
        
        [self readBitsFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kInputRegisters) {
        [self readInputRegistersFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kRegisters) {
        [self readRegistersFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

- (void) writeBit:(int)address to:(BOOL)status success:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        if(modbus_write_bit(mb, address, status) >= 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    });
    
}

- (void) writeRegister:(int)address to:(int)value success:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        
        
        if(modbus_write_register(mb, address, value) >= 0) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    });
    
}

- (void) readBitsFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint8_t tab_reg[count*sizeof(uint8_t)];
        
        if (modbus_read_bits(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithBool:tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
        }
        else {
            
            
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        
    });
}

- (void) readInputBitsFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        
        uint8_t tab_reg[count*sizeof(uint8_t)];
        
        if (modbus_read_input_bits(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithBool: tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
        }
        else {
            
            
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        
    });
}

- (void) readRegistersFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint16_t tab_reg[count*sizeof(uint16_t)];
        
        if (modbus_read_registers(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithInt: tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
            
            
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    });
}

- (void) readInputRegistersFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint16_t tab_reg[count*sizeof(uint16_t)];
        
        if (modbus_read_input_registers(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithInt: tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
            
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            
        }
    });
}

- (void) writeRegistersFromAndOn:(int)address toValues:(NSArray*)numberArray success:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint16_t valueArray[numberArray.count];
        
        for (int i = 0; i < numberArray.count; i++) {
            valueArray[i] = [[numberArray objectAtIndex:i] intValue];
        }
        
        if (modbus_write_registers(mb, address, numberArray.count, valueArray)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    });
}


- (Float32)convertArrayToReal:(NSArray *)array
{
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
    
    for (index = 1; index <= 8; index++)
    {
        //[exponent addObject:[NSNumber numberWithInt:[mainArray[index] intValue]]];
        [exponentStr appendString:[NSString stringWithFormat:@"%i", [mainArray[index] intValue]]];
    }
    
    
    for (index = 9; index <= 31; index++)
    {
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


- (void)writeReal:(Float32)fnum :(int)address
{
    // convert REAL into BINARY
    
    Float32 Realnumb = fnum; //-10040.11111;
    Realnumb = [[NSString stringWithFormat:@"%.3f",Realnumb]floatValue];
    int Wsign = 0;
    int RNumInt = floor(Realnumb);
    if (Realnumb < 0) {
        RNumInt++;
        RNumInt = -1 * RNumInt;
        Wsign = 1;
    }
    NSLog(@"Sign -> %i", Wsign);
    Float32 fracNum = 0;
    if (Realnumb < 0) {
        fracNum = -1 *(Realnumb + RNumInt);
    } else {
        fracNum = Realnumb - RNumInt;
    }
    NSLog(@"fracNum -> %f", fracNum);
    
    NSArray *fracNumBinary = [[NSArray alloc] init];
    NSMutableArray *fracNum10 = [[NSMutableArray alloc] init];
    fracNumBinary = [self convertBase10to2: RNumInt :32];
    int i = 0;
    int i2 = 0;
    //strip zeros on the left
    for (i = 0; i < 33; i++) {
        if ([fracNumBinary[i] intValue] == 1) {
            for (i2 = i; i2 < fracNumBinary.count; i2++) {
                [fracNum10 addObject:[NSNumber numberWithInt:[fracNumBinary[i2] intValue]]];
            }
            break;
        }
    }
    NSMutableArray *fracPart1 = [[NSMutableArray alloc] init];
    for (i = 0; i < 12; i++) {
        fracNum = fracNum * 2;
        if (fracNum < 1) {
            [fracPart1 addObject:[NSNumber numberWithInt:0]];
        }
        else {
            if (fracNum == 1) {
                [fracPart1 addObject:[NSNumber numberWithInt:1]];
                break;
            }
            [fracPart1 addObject:[NSNumber numberWithInt:1]];
            fracNum--;
        }
    }
    //NSLog(@"fracPart1 -> %@",fracPart1);
    
    int exponent = 0;
    if ([fracNum10 count] == 0)
    {
        for (i = 0; i < [fracPart1 count]; i++){
            if([fracPart1[i] intValue] == 0) {
                exponent--;
            }
            else{
                exponent--;
                break;
            }
        }
    }
    else {
        exponent = [fracNum10 count] - 1;
    }
    
    if ([fracNum10 count] == 0)
    {
        for (i = 0; i < [fracPart1 count]; i++)
        {
            if ([fracPart1[i] intValue] == 0)
            {
                [fracPart1 removeObjectAtIndex: i];
            }
            else
            {
                [fracPart1 removeObjectAtIndex: i];
                break;
            }
        }
    }
    
    //NSLog(@"fracPart1 modified11 -> %@",fracPart1);
    
    NSMutableArray *fraction = [[NSMutableArray alloc] init];
    for (i = 0; i <= 23; i++) {
        if (i == 0)
        {
            if ([fracNum10 count] > 0)
            {
                for (i2 = 1; i2 < [fracNum10 count]; i2++) {
                    [fraction addObject:[NSNumber numberWithInt:[fracNum10[i2] intValue]]];
                    i++;
                }
            }
            for (i2 = 0; i2 < [fracPart1 count]; i2++) {
                [fraction addObject:[NSNumber numberWithInt:[fracPart1[i2] intValue]]];
                i++;
            }
        }
        if (i == 23) {
            break;
        }
        else {
            [fraction addObject:[NSNumber numberWithInt:0]];
        }
    }
    //NSLog(@"Exponent -> %i", exponent);
    
    int biasedExponent = 127 + exponent;
    
    NSArray *exponentArray = [[NSArray alloc] init];
    exponentArray = [self convertBase10to2: biasedExponent :7];
    
    NSLog(@"Exponent -> %@", exponentArray);
    NSLog(@"Fraction -> %@", fraction);
    
    NSMutableArray *finalRealNumber = [[NSMutableArray alloc] init];
    [finalRealNumber addObject:[NSNumber numberWithInt:Wsign]];
    finalRealNumber = [[NSMutableArray alloc] initWithArray:[finalRealNumber arrayByAddingObjectsFromArray:exponentArray]];
    finalRealNumber = [[NSMutableArray alloc] initWithArray:[finalRealNumber arrayByAddingObjectsFromArray:fraction]];
    
    NSArray *firstHalfOfArray;
    NSArray *secondHalfOfArray;
    NSRange newRange;
    
    newRange.location = 0;
    newRange.length = [finalRealNumber count] / 2;
    
    firstHalfOfArray = [finalRealNumber subarrayWithRange:newRange];
    NSMutableString *firstHalfArrayStr = [[NSMutableString alloc] init];
    for (i = 0; i <= 15; i++)
    {
        [firstHalfArrayStr appendString:[NSString stringWithFormat:@"%i", [firstHalfOfArray[i] intValue]]];
    }
    
    newRange.location = newRange.length;
    newRange.length = [finalRealNumber count] - newRange.length;
    
    secondHalfOfArray = [finalRealNumber subarrayWithRange:newRange];
    NSMutableString *secondHalfArrayStr = [[NSMutableString alloc] init];
    for (i = 0; i <= 15; i++)
    {
        [secondHalfArrayStr appendString:[NSString stringWithFormat:@"%i", [secondHalfOfArray[i] intValue]]];
    }
    
    int firstHalf = [self convertBase2to10 :firstHalfArrayStr :16];
    int secondHalf = [self convertBase2to10 :secondHalfArrayStr :16];
    
    if (fnum == (Float32)1) {
        firstHalf = [self convertBase2to10 :@"0011111110000000" :16];
        secondHalf = [self convertBase2to10 :@"1000000000000000" :16];
    } else if (fnum == (Float32)0) {
        firstHalf = 0;
        secondHalf = 0;
    }
    //NSLog(@"first half of REAL NUMBER -> %@", firstHalfArrayStr);
    //NSLog(@"second half of REAL NUMBER -> %@", secondHalfArrayStr);
    
    [self writeRegister:(address+1) to:firstHalf success:^{} failure:^(NSError *error){}];
    [self writeRegister:address to:secondHalf success:^{} failure:^(NSError *error){}];
}


-(NSArray *)convertBase10to2: (int)num :(int)lim{
    
    //Convert to Base 4
    int base = 2;
    
    //With 4 places
    //256   16  4   1
    // 0    3   0   2
    int places = lim;
    
    //Our input number
    int input = num;
    
    NSMutableString *newStr = [[NSMutableString alloc] init];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    
    //We're going to loop through backwards the powers (256, 16, 4, 1 etc) and work out how many times our input evenly goes into it
    for (int index = places; index > -1; index--){
        // how many times does 50 go into the power
        int decimal = (int)((double)input / (double)(pow(base, index)));
        // whats the remainder, set it back to input
        input = (int)(input % (int)(pow(base, index)));
        
        [array2 addObject:[NSNumber numberWithInt:decimal]];
        
        // append the value to a string
        [newStr appendString:[NSString stringWithFormat:@"%i", decimal]];
        
    }
    //NSLog(@"Base2: %@", newStr);
    //NSLog(@"fff %@", array2);
    
    return array2;
}

-(int)convertBase2to10: (NSString*)Str :(int)lim{
    
    NSString *input = Str;
    int base10 = 0;
    
    for (int i=0; i < lim; i++){
        
        //NSLog(@"%@", input);
        NSInteger num = [[input substringFromIndex: [input length] - 1] integerValue];
        //NSLog(@"%d", num);
        if (num == 1) {
            base10 += pow(2, i);
            //NSLog(@"base10: %d power equals %d", i, base10);
        }
        input = [input substringToIndex: [input length] - 1];
        
    }
    //NSLog(@"FINAL result: %d", base10);
    return base10;
}


-(void)dealloc{
    //dispatch_release(modbusQueue);
    modbus_free(mb);
}

@end
