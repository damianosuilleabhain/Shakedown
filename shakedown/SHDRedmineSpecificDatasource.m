//
//  SHDRedmineSpecificDatasource.h
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/23/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "SHDRedmineSpecificDatasource.h"
#import "SHDShakedown.h"
#import "SHDShakedownReporter.h"
#import "SHDShakedownRedmineReporter.h"
#import "NSURLResponse+Shakedown.h"

NSString * trackersUrlAppendex = @"/trackers.json";

@interface SHDIssueTracker : NSObject
@property (nonatomic, assign) NSInteger trackerId;
@property (nonatomic, strong) NSString *trackerName;
@end

@implementation SHDIssueTracker
@end


@interface SHDRedmineSpecificDatasource ()
@property (nonatomic, strong) NSMutableArray * trackersArray;
@end

@implementation SHDRedmineSpecificDatasource

- (NSArray *) issueTrackersNames
{
    return [self.trackersArray valueForKey:@"trackerName"];
}

- (NSInteger)issueTrackerIdForName:(NSString *)name
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self.trackerName == %@", name];
    SHDIssueTracker * tracker = [[self.trackersArray filteredArrayUsingPredicate:predicate] lastObject];
    return tracker != nil ? tracker.trackerId : 1;
}

- (void)updateDatasourceIfNeededWithCompletionHandler:(UpdateCompletionHandler)updateCompletionHandler
{
    if ([[[SHDShakedown sharedShakedown] reporter] isKindOfClass:[SHDShakedownRedmineReporter class]]) {
        SHDShakedownRedmineReporter * reporter = (SHDShakedownRedmineReporter *)[[SHDShakedown sharedShakedown] reporter];
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", reporter.apiURL, trackersUrlAppendex]];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setValue:reporter.userApiToken forHTTPHeaderField:redmineApiKeyHeaderKey];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * responce, NSData * data, NSError * error) {
            if (responce.statusCodeIfHttpResponce == 200 && error == nil && data.length > 0) {
                self.trackersLoadingRequestFailed = NO;
                [self processTrackersData:data];
                if (updateCompletionHandler) updateCompletionHandler(error);
            }
            else {
                NSLog(@"ERROR WHILE TRACKERS LOADING.");
                self.trackersLoadingRequestFailed = YES;
            }
        }];
    }
}

- (void)processTrackersData:(NSData *)data
{
    NSError * error = nil;
    NSDictionary * trackersDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSArray * trackersDictionariesArray = nil;
    if (trackersDictionary && error == nil)
        trackersDictionariesArray = [trackersDictionary objectForKey:@"trackers"];
    else
        NSLog(@"ERROR WHILE PROCESSING TRACKERS.");
    
    for (NSDictionary * trackerDictionary in trackersDictionariesArray) {
        SHDIssueTracker * issueTracker = [[SHDIssueTracker alloc] init];
        issueTracker.trackerName = [trackerDictionary objectForKey:@"name"];
        issueTracker.trackerId = [[trackerDictionary objectForKey:@"id"] intValue];
        [self.trackersArray addObject:issueTracker];
    }
}

- (NSMutableArray *)trackersArray
{
    if (!_trackersArray) {
        _trackersArray = [NSMutableArray array];
    }
    return _trackersArray;
}

@end
