//
//  SHDShakedownRedmineReporter.m
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/22/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "SHDShakedownRedmineReporter.h"
#import "NSURLResponse+Shakedown.h"

typedef void (^CompletionHandler) (NSURLResponse *response, NSData *data, NSError *error);
typedef void (^AttacmentsUploadedHandler) (NSMutableArray * tokens, NSError *error);

NSString * createIssueUrlAppendix = @"/issues.json";
NSString * uploadAttachmentUrlAppendix = @"/uploads.json";
NSString * redmineApiKeyHeaderKey = @"X-Redmine-API-Key";

@implementation SHDShakedownRedmineReporter

- (id)initWithApiUrl:(NSString *)apiUrl {
    self = [super init];
    if (self) {
        self.apiURL = apiUrl;
    }
    return self;
}

- (void)reportBug:(SHDBugReport *)bugReport {
    [self uploadToRedmineAttachments:bugReport.screenshots attacmentsUploadedHandler:^(NSMutableArray *tokens, NSError *error) {
        [self uploadBugReportToRedmine:bugReport attachmentsTokens:tokens completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSInteger statusCode = response.statusCodeIfHttpResponce;
            if (statusCode == 201)
                [self.delegate shakedownFiledBugSuccessfullyWithLink:response.URL];
            else
                [self.delegate shakedownFailedToFileBug:[NSString stringWithFormat:@"Failed to create issue on redmine with status code: %i", statusCode]];
        }];
    }];
}

- (void)uploadBugReportToRedmine:(SHDBugReport *)bugReport attachmentsTokens:(NSArray *)attachmentsTokens completionHandler:(CompletionHandler)completionHandler
{
    NSMutableArray * uploadsArray = [NSMutableArray array];
    for (int i = 0; i < attachmentsTokens.count; i ++) {
        NSString * token = attachmentsTokens[i];
        NSString * fileName = [NSString stringWithFormat:@"screenshot_%i", i];
        NSDictionary *uploadDictionary = @{@"token" : token,
                                           @"filename" : fileName,
                                           @"content_type" : @"image/png"};
        [uploadsArray addObject:uploadDictionary];
    }
    
    NSMutableDictionary * issueInfoDictionary = [NSMutableDictionary dictionary];
    if (bugReport.trackerId > 0)
        [issueInfoDictionary setObject:@(bugReport.trackerId) forKey:@"tracker_id"];
    if (bugReport.statusId > 0) [issueInfoDictionary setObject:@(bugReport.statusId) forKey:@"status_id"];
    if (bugReport.title.length > 0) [issueInfoDictionary setObject:bugReport.title forKey:@"subject"];
    if (bugReport.formattedReport.length > 0) [issueInfoDictionary setObject:bugReport.formattedReport forKey:@"description"];
    if (uploadsArray.count > 0) [issueInfoDictionary setObject:uploadsArray forKey:@"uploads"];
    
    NSAssert(self.projectId != 0, @"PROJECT ID SHOULD BE SETTED BEFOR ISSUE CREATION!!!");
    [issueInfoDictionary setObject:@(self.projectId) forKey:@"project_id"];
    
    NSDictionary * resultDictionary = [NSDictionary dictionaryWithObject:issueInfoDictionary forKey:@"issue"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData.length || error != nil)
        [NSException raise:@"COULD NOT CREATE JSON FROM DICT" format:@""];
    
    [self sendAsynchronousRequestToRedmineWithUrlAppendex:createIssueUrlAppendix contentType:@"application/json" body:jsonData completionHandler:completionHandler];
}

- (void)uploadToRedmineAttachments:(NSMutableArray *)attachments
         attacmentsUploadedHandler:(AttacmentsUploadedHandler)attacmentsUploadedHandler
{
    NSMutableArray * attachmentsTokens = [NSMutableArray array];
    [self uploadToRedmineAttachments:attachments
                   attachmentsTokens:attachmentsTokens
           attacmentsUploadedHandler:attacmentsUploadedHandler];
}

- (void)uploadToRedmineAttachments:(NSMutableArray *)attachments
                 attachmentsTokens:(NSMutableArray *)attachmentsTokens
         attacmentsUploadedHandler:(AttacmentsUploadedHandler)attacmentsUploadedHandler
{
    for (UIImage * image in attachments)
    {
        NSData * attachmentData = UIImagePNGRepresentation(image);
        [self sendAsynchronousRequestToRedmineWithUrlAppendex:uploadAttachmentUrlAppendix contentType:@"application/octet-stream" body:attachmentData completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSInteger statusCode = response.statusCodeIfHttpResponce;
            if (statusCode == 201) {
                [attachmentsTokens addObject:[self attachmentTokenFromResponceData:data]];
                [attachments removeObject:image];
                if (attachments.count == 0 && attacmentsUploadedHandler != nil)
                    attacmentsUploadedHandler(attachmentsTokens, error);
                else
                    [self uploadToRedmineAttachments:attachments attachmentsTokens:attachmentsTokens attacmentsUploadedHandler:attacmentsUploadedHandler];
            }
            else {
                if(attacmentsUploadedHandler != nil)
                    attacmentsUploadedHandler(attachmentsTokens, error);
            }
        }];
    }
}

- (void)sendAsynchronousRequestToRedmineWithUrlAppendex:(NSString *)urlAppendex contentType:(NSString *)contentType body:(NSData *)body completionHandler:(CompletionHandler)completionHandler
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.apiURL, urlAppendex]];
    
    NSMutableURLRequest *createIssueRequest = [NSMutableURLRequest requestWithURL:url];
    [createIssueRequest setHTTPBody:body];
    [createIssueRequest setHTTPMethod:@"POST"];

    NSAssert(self.userApiToken.length != 0, @"USER API TOKEN SHOULD BE SETTED BEFORE REQUEST!!!");
    [createIssueRequest setValue:self.userApiToken forHTTPHeaderField:redmineApiKeyHeaderKey];
    [createIssueRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:createIssueRequest queue:[NSOperationQueue mainQueue] completionHandler:completionHandler];
}

- (NSString *)attachmentTokenFromResponceData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary * attachmentDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString * attachmentToken = nil;
    if (attachmentDictionary && error == nil)
        attachmentToken = [[attachmentDictionary objectForKey:@"upload"] objectForKey:@"token"];
    else
        NSLog(@"ERROR WHILE PROCESSING ATTACHMENT ADDING RESPONCE.");
    return attachmentToken;
}

@end
