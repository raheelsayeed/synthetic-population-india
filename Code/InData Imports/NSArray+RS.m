//
//  NSArray+RS.m
//  InData_Imports
//
//  Created by Raheel Sayeed on 6/18/16.
//  Copyright © 2016 Raheel Sayeed. All rights reserved.
//

#import "NSArray+RS.h"

@implementation NSArray (RS)


- (NSArray *)transposedTwoDArray
{
    NSMutableArray * rowBased2DArray = @[].mutableCopy;
    NSMutableArray * totalMarginals_adjusted_rows = @[].mutableCopy;
    
    for(int idx=0; idx<[self[0] count]; idx++)
    {
        NSMutableArray *rows = @[].mutableCopy;
        for(int row=0; row<self.count; row++)
        {
            [rows addObject:self[row][idx]];
        }
        NSNumber * rowsCount = [rows valueForKeyPath:@"@sum.self"];
        [totalMarginals_adjusted_rows addObject:rowsCount];
        [rowBased2DArray addObject:rows];
    }
    return rowBased2DArray.copy;

}

@end
