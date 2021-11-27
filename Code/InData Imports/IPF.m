//
//  IPF.m
//  InData_Imports
//
//  Created by Raheel Sayeed on 6/17/16.
//  Copyright © 2016 Raheel Sayeed. All rights reserved.
//

#import "IPF.h"
#import "NSArray+RS.h"

@implementation IPF
#define log(FORMAT, ...) printf("> %s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);




+ (id)runIPF
{
    /*
     Rules:
     
     1. Number of Items on Marginals should be the same
     2. Array of Records is a 2D Array. (an array of Array)
     3. arrayOfRecords.count == totalMarginals_row.count
     4. EachRecord.count (insidearrayofRecord) == totalMarginals_column.count
     
     */
    
    
    
    NSArray *totalMarginals_column = @[@2500,   @7500];
    
    NSArray *totalMarginals_row = @[@3500,
                                    @6500];
   
    
    NSArray * arrayOfRecords = @[
                                 @[ @18,    @16],
                                 @[ @3,     @63],
                                ];
    float totalPUMS_size = 100;
    

    
    
    
    /*
    //VIRGINIA FILES
    totalMarginals_row      = @[ @0, @121, @214, @25 ];
    totalMarginals_column   = @[ @44,
                                 @134,
                                 @94,
                                 @46,
                                 @46,
                                 @36,
                                 @0
                                 ];
    arrayOfRecords = @[
                        @[@2,   @11,    @9,         @3,     @26,    @64,    @42],
                        @[@11,  @108,   @122,       @48,    @80,    @61,    @18],
                        @[@28,  @135,   @274,       @156,   @85,    @22,    @6],
                        @[@0,   @3,     @65,        @76,    @40,    @10,    @3],
                        ];
     totalPUMS_size = 1508;
    */

    
    //ANother sample
    totalMarginals_row      = @[@1700,   @1050];
    totalMarginals_column   = @[@1505,    @1245];
    totalPUMS_size          = 253;
    arrayOfRecords          = @[
                                @[@45, @108],
                                @[@63, @37]
                                ];
    
    totalMarginals_row      = @[@20, @30, @35, @15];
    totalMarginals_column   = @[@35, @40, @25];
    totalPUMS_size          = 96;
    arrayOfRecords          = @[
                                 @[@6,  @6,     @3],
                                 @[@8,  @10,    @10],
                                 @[@9,  @10,    @9],
                                 @[@3,  @14,    @8],
                                 ];
    
    
    
    
    
    
    NSUInteger tM_column_count = totalMarginals_column.count;

    
    
    
    
    
    
    
    
    //Check1 Data Validity
    if(arrayOfRecords.count != totalMarginals_row.count)
    {
        log(@"Invalid Data,  AR.count %lu != %lu tM_Row.count", (unsigned long)arrayOfRecords.count, (unsigned long)totalMarginals_row.count);
        return nil;
    }
    
    // Step1. Initialization and Data check
    NSMutableArray * initialisedRecordArray = [NSMutableArray new];
    
    
    for(int r =0; r<arrayOfRecords.count; r++)
    {
        NSArray *record = arrayOfRecords[r];
        //Check2:
        if(record.count != tM_column_count)
        {
            log(@"Invalid Data, AR.count %lu != %lu tM_Column.count", (unsigned long)record.count, tM_column_count);
            break;
            return nil;
        }
        
        //iterate over the record.
        NSMutableArray *tempRecord = [NSMutableArray new];
        for(int column=0; column<record.count; column++)
        {
            NSNumber * n = record[column];
            [tempRecord addObject:@(n.floatValue/totalPUMS_size)];
        }
        
        [initialisedRecordArray addObject:tempRecord.copy];
        
    }
    
//    log(@"%@\n%@", initialisedRecordArray.description, arrayOfRecords.description);
    
    //Initialise Totals
    float marginals_row_total = [[totalMarginals_row valueForKeyPath:@"@sum.self"] floatValue];
    float marginals_column_total = [[totalMarginals_column valueForKeyPath:@"@sum.self"] floatValue];
    
    
    float multiplyingFactor_row_total = 1/marginals_row_total;
    float multiplyingFactor_column_total = 1/marginals_column_total;
    
    NSArray * initializedRowTotalArray = [IPF multiplyAllObjectsBy:multiplyingFactor_row_total inArray:totalMarginals_row];
    NSArray * initializedColumnTotalArray = [IPF multiplyAllObjectsBy:multiplyingFactor_column_total inArray:totalMarginals_column];
    
    log(@"Target Marginals (ROWS):\n%@", initializedRowTotalArray.description);
    log(@"Target Columns (ROWS):\n%@", initializedColumnTotalArray.description);

    
    NSArray * ipf_array = initialisedRecordArray.copy;
    int ipfRounds = 6;
    NSArray * new_ipfarray;
    BOOL rowsAdjusted = NO;
    for(int i=1; i<ipfRounds+1; i++)
    {
        log(@"IPF iter: %d======================", i);
        if(!rowsAdjusted)
        {
            new_ipfarray = [IPF IPF_rowAdjustment:ipf_array targetMarginalsRow:initializedRowTotalArray];
        }
        else
        {
            new_ipfarray = [IPF IPF_columnAdjustment:ipf_array targetMarginalsColumn:initializedColumnTotalArray];
        }
        rowsAdjusted = !rowsAdjusted;
        
        /*if([IPF checkIterationChange:new_ipfarray oldArray:ipf_array])
        {
            log(@"IPF Stopped at Count %d\n==================", i/2);
            break;
        }*/
        
        ipf_array = new_ipfarray;
    }
    return @"FIN";
}
+ (BOOL)checkIterationChange:(NSArray *)new oldArray:(NSArray *)old
{
    float desiredIterationChange = 0.0028;

    for(int r = 0; r < new.count; r++)
    {
        NSArray * record = new[r];
        for(int c = 0; c < record.count; c++)
        {
            NSNumber * oldf = old[r][c];
            NSNumber * newf = new[r][c];
            

            float diff = newf.floatValue-oldf.floatValue;
            if(diff >= desiredIterationChange)
            {
                return NO;
                break;
            }
        }
    }
    
    return YES;
    
}

+ (NSArray *)multiplyAllObjectsBy:(float)f inArray:(NSArray *)array
{
    NSMutableArray * m = [NSMutableArray new];
    for(NSNumber * n in array)
    {
        [m addObject:@(n.floatValue * f)];
    }
    return m.copy;
}



+ (NSArray *)runIPF_For2DMatrixArray:(NSArray *)inputArray targetMarginalsRow:(NSArray *)targetMarginals_row targetMarginalsColumn:(NSArray *)targetMarginals_column
{
    NSArray * rowAdjustedArray      = [[self class] IPF_rowAdjustment:inputArray targetMarginalsRow:targetMarginals_row];
    
    NSArray * columnAdjustedArray   = [[self class] IPF_columnAdjustment:rowAdjustedArray targetMarginalsColumn:targetMarginals_column];
    return columnAdjustedArray;
}
+ (NSArray *)IPF_rowAdjustment:(NSArray *)inputArray targetMarginalsRow:(NSArray *)targetMarginals_row
{
    NSMutableArray *rowAdjustedArray = [NSMutableArray new];
    
    for(int row=0; row<inputArray.count; row++)
    {
        NSArray * record = inputArray[row];
        float totalRowCount = [[record valueForKeyPath:@"@sum.self"] floatValue];
        
        NSMutableArray * tempRecord = [NSMutableArray new];
        
        float multiplyingFraction = ([targetMarginals_row[row] floatValue] / totalRowCount);
        
        for(int column = 0; column < record.count; column++)
        {
            NSNumber * number = record[column];
            float factor = number.floatValue * multiplyingFraction;
            [tempRecord addObject:[NSNumber numberWithFloat:isnan(factor)?0.0:factor]];

            
        }
        [rowAdjustedArray addObject:tempRecord.copy];
    }
    
    log(@"\n\nROW ADJUSTED 2DARRAY: %@", rowAdjustedArray.description);
    //New Marginals
    
    log(@"New Marginals:%@",[IPF marginalsFor2DMatrix:rowAdjustedArray]);
    
    
    return rowAdjustedArray.copy;
    
}
+ (NSDictionary *)marginalsFor2DMatrix:(NSArray *)input
{
    NSMutableArray *rowMarginals = @[].mutableCopy;
    NSMutableArray *columnMarginals = @[].mutableCopy;
    
    for(NSArray * record in input)
    {
        NSNumber * totalRowCount = [record valueForKeyPath:@"@sum.self"];
        [rowMarginals addObject:totalRowCount];
    }
    
    NSArray * switchedToColumns = [input transposedTwoDArray];
    for(NSArray * record in switchedToColumns)
    {
        NSNumber * totalRowCount = [record valueForKeyPath:@"@sum.self"];
        [columnMarginals addObject:totalRowCount];
    }
    return @{@"rowMarginals": rowMarginals.copy, @"columnMarginals" : columnMarginals.copy};
}
+ (NSArray *)IPF_columnAdjustment:(NSArray *)inputArray targetMarginalsColumn:(NSArray *)targetMarginals_column
{
    NSMutableArray *columnAdjustedArray = @[].mutableCopy;
    NSMutableArray *totalMarginals_adjusted_columns = @[].mutableCopy;
    
    for(int column=0; column<targetMarginals_column.count; column++)
    {
        //Get All values in that column
        NSMutableArray * columnArray = [NSMutableArray new];
        for(int row = 0; row < inputArray.count; row++)
        {
            [columnArray addObject:inputArray[row][column]];
        }
        //        NSLog(@"=========%@", columnArray.description);
        float totalColumnCount = [[columnArray valueForKeyPath:@"@sum.self"] floatValue];
        float multiplyingFraction = ([targetMarginals_column[column] floatValue] / totalColumnCount);
        
        //adjust it!
        NSMutableArray * adjustedColumn = @[].mutableCopy;
        for(NSNumber * n in columnArray)
        {
            float factor = n.floatValue * multiplyingFraction;
            [adjustedColumn addObject:[NSNumber numberWithFloat:isnan(factor)?0.0:factor]];
        }
        
        NSNumber * adjusted_totalColumnCount = [adjustedColumn valueForKeyPath:@"@sum.self"] ;
        [totalMarginals_adjusted_columns addObject:adjusted_totalColumnCount];
        //convert back to 2D array
        
        [columnAdjustedArray addObject:adjustedColumn];
        //        log (@"=====AdjustedColumn====\ncountBefore=%f\nCountAffter=%f\n%@" ,totalColumnCount, adjusted_totalColumnCount.floatValue, adjustedColumn.description);
    }
    
    
    //Convert Back to Row-based 2D Array
    columnAdjustedArray = [columnAdjustedArray transposedTwoDArray].mutableCopy;
    /*
    NSMutableArray * rowBased2DArray = @[].mutableCopy;
    NSMutableArray * totalMarginals_adjusted_rows = @[].mutableCopy;
    
    for(int idx=0; idx<[columnAdjustedArray[0] count]; idx++)
    {
        NSMutableArray *rows = @[].mutableCopy;
        for(int row=0; row<columnAdjustedArray.count; row++)
        {
            [rows addObject:columnAdjustedArray[row][idx]];
        }
        NSNumber * rowsCount = [rows valueForKeyPath:@"@sum.self"];
        [totalMarginals_adjusted_rows addObject:rowsCount];
        [rowBased2DArray addObject:rows];
    }
     */
    log(@"\n\nColumn ADJUSTED 2DARRAY: %@", columnAdjustedArray.description);
    log(@"New Marginals:%@",[IPF marginalsFor2DMatrix:columnAdjustedArray]);

    
    return columnAdjustedArray.copy;
    
}
@end
