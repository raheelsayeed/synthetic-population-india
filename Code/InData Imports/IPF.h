//
//  IPF.h
//  InData_Imports
//
//  Created by Raheel Sayeed on 6/17/16.
//  Copyright © 2016 Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPF : NSObject

+ (NSArray *)runIPFonMicrosample:(NSArray *)microsample marginals:(NSArray *)marginals;

+ (id)runIPF;
@end
