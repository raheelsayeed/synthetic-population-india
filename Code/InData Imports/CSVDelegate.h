//
//  CSVDelegate.h
//  InData_Imports
//
//  Created by Raheel Sayeed on 6/11/16.
//  Copyright © 2016 Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"


@interface CSVDelegate : NSObject <CHCSVParserDelegate>
@property (readonly) NSArray *lines;
@end
