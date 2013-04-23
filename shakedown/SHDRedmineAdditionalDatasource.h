//
//  SHDRedmineAdditionalDatasource.h
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/23/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UpdateCompletionHandler) (NSError * error);

@interface SHDRedmineAdditionalDatasource : NSObject

+ (SHDRedmineAdditionalDatasource *)sharedDatasource;

@property (nonatomic, assign) BOOL trackersLoadingRequestFailed;

- (NSArray *) issueTrackersNames;
- (NSInteger)issueTrackerIdForName:(NSString *)name;
- (void)updateDatasourceIfNeededWithCompletionHandler:(UpdateCompletionHandler)completionHandler;

@end
