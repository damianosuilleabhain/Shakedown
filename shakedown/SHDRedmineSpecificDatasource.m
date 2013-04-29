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
#import "NSString+Shakedown.h"

NSString * trackersUrlAppendex = @"/trackers.json";

@interface SHDIssueTracker : NSObject <NSCoding>
@property (nonatomic, assign) NSInteger trackerId;
@property (nonatomic, strong) NSString *trackerName;
@end

@implementation SHDIssueTracker

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.trackerId = [aDecoder decodeIntegerForKey:@"trackerId"];
        self.trackerName = [aDecoder decodeObjectForKey:@"trackerName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.trackerId forKey:@"trackerId"];
    [aCoder encodeObject:self.trackerName forKey:@"trackerName"];
}

@end


@interface SHDRedmineSpecificDatasource ()
@property (nonatomic, strong) NSMutableArray * trackersArray;
@end

@implementation SHDRedmineSpecificDatasource

#pragma mark - Init methods

- (id)init
{
    if (self = [super init]) {
        [self loadCashedIssueTrackers];
    }
    return self;
}

- (void)loadCashedIssueTrackers
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString trackersDocumentPath] isDirectory:NULL]) {
        NSData *trackersData =  [[NSData alloc] initWithContentsOfFile:[NSString trackersDocumentPath]];
        NSArray * cashedTrackers = [NSKeyedUnarchiver unarchiveObjectWithData:trackersData];
        [self.trackersArray addObjectsFromArray:cashedTrackers];
    }
}

#pragma mark - Interface methods

- (NSArray *)issueTrackersNames
{
    NSMutableArray * trackerNames = [[self.trackersArray valueForKey:@"trackerName"] mutableCopy];
    if (trackerNames.count == 0) {
        [trackerNames addObject:@"Trakers not loaded yet"];
    }
    return trackerNames;
}

- (NSInteger)issueTrackerIdForName:(NSString *)name
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self.trackerName == %@", name];
    SHDIssueTracker * tracker = [[self.trackersArray filteredArrayUsingPredicate:predicate] lastObject];
    return tracker != nil ? tracker.trackerId : NSNotFound;
}

#pragma mark - Updating methods

- (void)updateDatasourceIfNeededWithCompletionHandler:(UpdateCompletionHandler)updateCompletionHandler
{
    if (self.trackersArray.count == 0)
        [self updateDatasourceWithCompletionHandler:updateCompletionHandler];
}

- (void)updateDatasourceWithCompletionHandler:(UpdateCompletionHandler)updateCompletionHandler
{
    SHDShakedownRedmineReporter * reporter = (SHDShakedownRedmineReporter *)[[SHDShakedown sharedShakedown] reporter];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", reporter.apiURL, trackersUrlAppendex]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:reporter.userApiToken forHTTPHeaderField:redmineApiKeyHeaderKey];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * responce, NSData * data, NSError * error) {
        if (responce.statusCodeIfHttpResponce == 200 && error == nil && data.length > 0) {
            [self processTrackersData:data];
            if (updateCompletionHandler) updateCompletionHandler(error);
        }
        else {
            NSLog(@"!!! ERROR WHILE TRACKERS LOADING. !!!");
        }
    }];
}

- (void)processTrackersData:(NSData *)data
{
    NSError * error = nil;
    NSDictionary * trackersDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSArray * trackersDictionariesArray = nil;
    if (trackersDictionary && error == nil)
        trackersDictionariesArray = [trackersDictionary objectForKey:@"trackers"];
    else
        NSLog(@"!!! ERROR WHILE PROCESSING TRACKERS. !!!");
    
    [self.trackersArray removeAllObjects];
    for (NSDictionary * trackerDictionary in trackersDictionariesArray) {
        SHDIssueTracker * issueTracker = [[SHDIssueTracker alloc] init];
        issueTracker.trackerName = [trackerDictionary objectForKey:@"name"];
        issueTracker.trackerId = [[trackerDictionary objectForKey:@"id"] intValue];
        [self.trackersArray addObject:issueTracker];
    }
    NSData *trackersData = [NSKeyedArchiver archivedDataWithRootObject:self.trackersArray];
    [trackersData writeToFile:[NSString trackersDocumentPath] atomically:YES];
}

#pragma mark - Getters

- (NSMutableArray *)trackersArray
{
    if (!_trackersArray) {
        _trackersArray = [NSMutableArray array];
    }
    return _trackersArray;
}

@end
