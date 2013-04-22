//
//  SHDShakedownRedmineReporter.m
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/22/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "SHDShakedownRedmineReporter.h"

NSString * defaultApiUrl = @"http://www.redmine.org";
NSString * createIssueUrlAppendix = @"/issues.json";

NSString * redmineApiKeyHeaderKey = @"X-Redmine-API-Key";

@implementation SHDShakedownRedmineReporter

- (id)initWithApiUrl:(NSString *)apiUrl {
    self = [super init];
    if (self) {
        self.apiURL = apiUrl ?: defaultApiUrl;
    }
    return self;
}

- (void)reportBug:(SHDBugReport *)bugReport {

    NSMutableDictionary * issueInfoDictionary = [NSMutableDictionary dictionary];
//    [issueInfoDictionary setObject:@(self.project_id) forKey:@"project_id"];
//    [issueInfoDictionary setObject:@(self.tracker_id) forKey:@"tracker_id"];
//    [issueInfoDictionary setObject:@(self.status_id) forKey:@"status_id"];
    [issueInfoDictionary setObject:@(54) forKey:@"project_id"];
    [issueInfoDictionary setObject:@(1) forKey:@"tracker_id"];
    [issueInfoDictionary setObject:@(1) forKey:@"status_id"];
    
    [issueInfoDictionary setObject:bugReport.title forKey:@"subject"];
    [issueInfoDictionary setObject:bugReport.formattedReport forKey:@"description"];
    
    NSDictionary * resultDictionary = [NSDictionary dictionaryWithObject:issueInfoDictionary forKey:@"issue"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData || error != nil) {
        NSLog(@"Got an error: %@", error);
        [NSException raise:@"COULD NOT CREATE JSON FROM DICT" format:@""];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.apiURL, createIssueUrlAppendix]];

    NSMutableURLRequest *createIssueRequest = [NSMutableURLRequest requestWithURL:url];
    [createIssueRequest setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [createIssueRequest setHTTPMethod:@"POST"];
    [createIssueRequest setValue:self.userApiToken forHTTPHeaderField:redmineApiKeyHeaderKey];
    [createIssueRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:createIssueRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int statusCode = 500;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
            statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        if (statusCode == 201)
            [self.delegate shakedownFiledBugSuccessfullyWithLink:response.URL];
        else
            [self.delegate shakedownFailedToFileBug:[NSString stringWithFormat:@"Failed to create issue on redmine with status code: %i", statusCode]];
    }];
}

@end
