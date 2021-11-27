//
//  PopulationSetBuilder.m
//  InData_Imports
//
//  Created by Raheel Sayeed on 6/20/16.
//  Copyright © 2016 Raheel Sayeed. All rights reserved.
//

#import "PopulationSetBuilder.h"
#import "sqlk.h"
#import "FMDatabase.h"
#import "SQLKStructure.h"
#import "SQLKTableStructure.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "CHCSVParser.h"
#import "NSString+RS.h"

@interface PopulationSetBuilder()
@property (nonatomic) FMDatabase * db;

@end
@implementation PopulationSetBuilder

#define dbStructurelocation @"/Users/raheelsayeed/Desktop/Synth_India Projects/InData_Imports/population_dataset_schema.xml"

+(id)run
{
    PopulationSetBuilder * population = [[PopulationSetBuilder alloc] init];
    [population initialiseDatabase];
//    [population insertRegions_Rural];
//    [population insertRegions_Urban];
    [population inserPopulationsToFMDB:nil];
//    [population insert_Subdistrict_Household_no_distruction];
    [population.db close];
    return @"--INDIA.db Build Fin.";
}
- (FMDatabase *)initialiseDatabase
{
    SQLKStructure * structure = [self structureFromXMLNamed:@"population_dataset_schema"];
    NSString * dbPath = nil;
    self.db = [self databaseFromStructure:structure path:&dbPath];
    log(@"%@", dbPath);
    return _db;
}
- (void)insertRegions_Rural
{
    NSArray * array = [NSArray arrayWithContentsOfCSVURL:[NSURL fileURLWithPath:[@"Rural-28-codes.CSV" IDF_filepath]] options:CHCSVParserOptionsUsesFirstLineAsKeys];
    NSInteger total = array.count;
    log(@"Total Rows in File: %ld\n  Last row: %@", (long)total, array[total-1]);

   
    for(int i=0; i<total; i++)
    {
        NSDictionary * d = array[i];
        NSUInteger level = 0;
        NSUInteger  code = 0;
        NSUInteger type = 1; //Rural.
        
        BOOL isState = ([d[@"DTCode"] integerValue] == 0);
        BOOL isDistrict = ([d[@"SDTCode"] integerValue] == 0);
        BOOL isSubdistrict = ([d[@"TVCode"] integerValue] == 0);
        BOOL isTown_village = ([d[@"TVCode"] integerValue] != 0);
        
        NSUInteger level1 = 0;
        NSUInteger level2 = 0;
        NSUInteger level3 = 0;
        NSUInteger level4 = 0;
        
        if(isState){
            level = 1;
            code = [d[@"STCode"] integerValue];
        }
        else if(isDistrict){
            level = 2;
            code = [d[@"DTCode"] integerValue];
            level1 = [d[@"STCode"] integerValue];
        }
        else if(isSubdistrict){
            level = 3;
            code = [d[@"SDTCode"] integerValue];
            level1 = [d[@"STCode"] integerValue];
            level2 = [d[@"DTCode"] integerValue];
        }
        else if(isTown_village){
            level = 4;
            code = [d[@"TVCode"] integerValue];
            level1 = [d[@"STCode"] integerValue];
            level2 = [d[@"DTCode"] integerValue];
            level3 = [d[@"SDTCode"] integerValue];

        }
        if(![_db executeUpdate:@"INSERT INTO Region (name,code,level,type,statecode,districtcode,subdistrictcode,tvcode)  Values(?,?,?,?,?,?,?,?)", d[@"Name"],@(code),@(level),@(type),@(level1),@(level2),@(level3),@(level4)])
        
        {
            log(@"%@", _db.lastError.localizedDescription);
        }
        
        log(@".....finished %u", i);
    }
   
    
}
-(void)insertRegions_Urban
{
    NSArray * array = [NSArray arrayWithContentsOfCSVURL:[NSURL fileURLWithPath:[@"Urban-28-codes.CSV" IDF_filepath]] options:CHCSVParserOptionsUsesFirstLineAsKeys];
    NSInteger total = array.count;
    log(@"Total Rows in File: %ld\n  Last row: %@", (long)total, array[total-1]);
    
    
    for(int i=0; i<total; i++)
    {
        //Only look for the Towncodes here. As all the necessary heirarchies were probably added by the Rural Codes
        //Assuming we inserted Rurals before Urban!
        NSDictionary * d = array[i];
        BOOL isTown = ([d[@"TVCode"] integerValue] != 0);
        if(isTown)
        {
            if(![_db executeUpdate:@"INSERT INTO Region (name,code,level,type,statecode,districtcode,subdistrictcode,tvcode)  Values(?,?,?,?,?,?,?,?)",
                 d[@"Name"],
                 @([d[@"TVCode"] integerValue]),
                 @4,
                 @2,
                 @([d[@"STCode"] integerValue]),
                 @([d[@"DTCode"] integerValue]),
                 @([d[@"SDTCode"] integerValue]),
                 @(0)])
                
            {
                log(@"%@", _db.lastError.localizedDescription);
            }
        }
        log(@".....finished %u", i);
    }
}

-(NSDictionary *)sanitize_Rural_28_codes_CSV:(NSDictionary *)d
{
    NSMutableDictionary * m  = @{}.mutableCopy;
    
    [d enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        m[key] = [[obj substringFromIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }];
    return m.copy;
    
}

#pragma mark - Utilities
/*
 [db executeUpdate:@"INSERT INTO Regions (level, name, type) VALUES (1, 'Andhra', 5)"];
 
 log(@"%@", [db.lastError localizedDescription]);
 FMResultSet * set = [db executeQuery:@"SELECT * FROM Regions"];
 
 while ([set next]) {
 log(@"%@", [set stringForColumn:@"name"]);
 }
 log(@"%@", 	set);
 
 
 log(@"%@", dbPath);
 [db close];
 */

- (SQLKStructure *)structureFromXMLNamed:(NSString *)xmlName
{
    SQLKStructure *structure = [SQLKStructure structureFromXML:dbStructurelocation];
    
    return structure;
}

- (FMDatabase *)databaseFromStructure:(SQLKStructure *)structure path:(NSString * __autoreleasing *)dbPath
{
    // get the cache directory
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //STAssertTrue(([libraryPaths count] > 0), @"Cache directory not found");
    NSString *path = [[libraryPaths objectAtIndex:0] stringByAppendingPathComponent:@"india.db"];
    //STAssertNotNil(path, @"No file to write to");
    
    // create it
    NSFileManager *fm = [NSFileManager new];
    [fm removeItemAtPath:path error:nil];				// we always want to start blank
    BOOL didCreate = NO;
    FMDatabase *db = [structure createDatabaseAt:path useBundleDbIfMissing:nil wasMissing:&didCreate updateStructure:NO error:nil];
    //STAssertNotNil(db, @"Failed to create sqlite database");
    //STAssertTrue(didCreate, @"Thinks it did not create a database");
    //STAssertTrue([db open], @"Failed to open the database");
    [db open];
    // return
    if (dbPath) {
        *dbPath = path;
    }
    return db;
}




- (void)inserPopulationsToFMDB:(FMDatabase *)db
{
    
    
    
    int totalFiles=23;
    NSMutableArray *cdblockFiles = @[].mutableCopy;
    for(int i=1; i<totalFiles+1; i++)
    {
        [cdblockFiles addObject:[[NSString stringWithFormat:@"cdblocklevel_data/PCA CDB-28%02d-F-Census.csv", i] IDF_filepath]];
    }
    cdblockFiles = cdblockFiles.copy;
    
    
    for(NSString * filepath in cdblockFiles)
    {
        NSURL * fileURL = [NSURL fileURLWithPath:filepath];
        NSArray * districtData = [NSArray arrayWithContentsOfCSVURL:fileURL options:CHCSVParserOptionsUsesFirstLineAsKeys];
        log(@"=============\nPopulation for File: %@\nRows: %lu", [filepath lastPathComponent], (unsigned long)districtData.count);
        log(@"......adding Town/Village Populations/Households/Workers (NO Distributions)");
        
        for(int p=0; p<districtData.count; p++)
        {
            log(@"......fin:%d", p);

            NSDictionary * d = districtData[p];
            
            NSUInteger townCode = [d[@"Town/Village"] integerValue];
            
            BOOL isTown_village = (townCode != 0);
            

            if(isTown_village)
            {
                // ### Population
                BOOL inserted = [_db executeUpdate:@"INSERT INTO POPULATION (region_code, total, males, females, A0_6_T, A0_6_M, A0_6_F) VALUES (?,?,?,?,?,?,?)",
                 @(townCode),
                 @([d[@"TOT_P"] integerValue]),
                 @([d[@"TOT_M"] integerValue]),
                 @([d[@"TOT_F"] integerValue]),
                 @([d[@"P_06"] integerValue]),
                 @([d[@"M_06"] integerValue]),
                 @([d[@"F_06"] integerValue])];
                
                if(!inserted)
                {
                    log(@"%@", _db.lastError.localizedDescription);
                }
                
                // ### Households
                BOOL insertHouseholds = [_db executeUpdate:@"INSERT INTO Household (region_code, total) VALUES (?, ?)",
                                         @(townCode),
                                         @([d[@"No_HH"] integerValue])];
                if(!insertHouseholds)
                {
                    log(@"%@", _db.lastError.localizedDescription);
                }
                
                // ### Workers
                BOOL insertWorkers = [_db executeUpdate:@"INSERT INTO Workers (region_code, total, males, females) VALUES (?, ?, ?, ?)",
                                        @(townCode),
                                        @([d[@"TOT_WORK_P"] integerValue]),
                                        @([d[@"TOT_WORK_M"] integerValue]),
                                        @([d[@"TOT_WORK_F"] integerValue])
                                      ];
                if(!insertWorkers)
                {
                    log(@"%@", _db.lastError.localizedDescription);
                }
        
            }
            
            
        }
        
        
    }
}

-(void)insert_Subdistrict_Household_no_distruction
{
    //Households/HH_pop_size_urban_rural
    NSURL * fileURL = [NSURL fileURLWithPath:[@"households/HH_pop_size_urban_rural.csv" IDF_filepath]];
    NSArray * households = [NSArray arrayWithContentsOfCSVURL:fileURL options:CHCSVParserOptionsUsesFirstLineAsKeys];
    
    log(@"==================\nSubdistrict-wise Household distribution count: %lu", households.count);
    log(@"%@", households[20]);
    
    for(int p=0; p<households.count; p++)
    {
        NSDictionary * d = households[p];
        
        //Skip the Rural/Urban Divides
        if(![d[@"figuretype"] isEqualToString:@"Total"]) continue;
        
        NSUInteger subdistrictcode = [d[@"tahsilcode"] integerValue];
        NSUInteger districtcode = [d[@"districtcode"] integerValue];
        NSUInteger statecode = [d[@"statecode"] integerValue];
        
        BOOL isSubDistrict = (subdistrictcode != 0);
        BOOL isDistrict    = (subdistrictcode == 0);
        BOOL isState       = (districtcode == 0 && subdistrictcode == 0);
        
        NSUInteger regionCode = 0;
        
        if(isState) regionCode = statecode;
        else if(isDistrict) regionCode = districtcode;
        else if(isSubDistrict) regionCode = subdistrictcode;
        
         BOOL insertedHouses =   [_db executeUpdate:@"INSERT INTO Household (region_code, total, size_1, size_2, size_3, size_4, size_5, size_6, size_7_10, size_11_15, size_15_plus, size_mean) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
             @(regionCode),
             @([d[@"hh_number"] integerValue]),
             @([d[@"size_1"] integerValue]),
             @([d[@"size_2"] integerValue]),
             @([d[@"size_3"] integerValue]),
             @([d[@"size_4"] integerValue]),
             @([d[@"size_5"] integerValue]),
             @([d[@"size_6"] integerValue]),
             @([d[@"size_7-10"] integerValue]),
             @([d[@"size_11-14"] integerValue]),
             @([d[@"size_15+"] integerValue]),
             d[@"size_mean"]];
        
        if(!insertedHouses)
        {
            log(@"%@", _db.lastError.localizedDescription);
        }
        
        log(@"...... HH-distro fin:%d", p);
    }

    

}




@end
