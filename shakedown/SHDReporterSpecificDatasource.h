//
//  SHDReporterSpecificDatasource.h
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/24/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UpdateCompletionHandler) (NSError * error);

@interface SHDReporterSpecificDatasource : NSObject

- (NSArray *)issueTrackersNames;
- (void)updateDatasourceIfNeededWithCompletionHandler:(UpdateCompletionHandler)completionHandler;

@end
