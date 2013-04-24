//
//  SHDReporterSpecificDatasource.m
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/24/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "SHDReporterSpecificDatasource.h"

@implementation SHDReporterSpecificDatasource

- (NSArray *)issueTrackersNames {
    return @[@"BUG", @"ISSUE"];
}

- (void)updateDatasourceIfNeededWithCompletionHandler:(UpdateCompletionHandler)completionHandler {
}

@end
