//
//  SHDRedmineSpecificDatasource.h
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/23/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHDReporterSpecificDatasource.h"

@interface SHDRedmineSpecificDatasource : SHDReporterSpecificDatasource

@property (nonatomic, assign) BOOL trackersLoadingRequestFailed;
- (NSInteger)issueTrackerIdForName:(NSString *)name;

@end
