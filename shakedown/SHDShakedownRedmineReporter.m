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
    if (bugReport.trackerId > 0) [issueInfoDictionary setObject:@(bugReport.trackerId) forKey:@"tracker_id"];
    if (bugReport.statusId > 0) [issueInfoDictionary setObject:@(bugReport.statusId) forKey:@"status_id"];
    [issueInfoDictionary setObject:bugReport.title forKey:@"subject"];
    [issueInfoDictionary setObject:bugReport.formattedReport forKey:@"description"];

    NSAssert(self.projectId != 0, @"PROJECT ID SHOULD BE SETTED BEFOR ISSUE CREATION!!!");
    [issueInfoDictionary setObject:@(self.projectId) forKey:@"project_id"];

    NSDictionary * resultDictionary = [NSDictionary dictionaryWithObject:issueInfoDictionary forKey:@"issue"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData.length || error != nil)
        [NSException raise:@"COULD NOT CREATE JSON FROM DICT" format:@""];
    
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
