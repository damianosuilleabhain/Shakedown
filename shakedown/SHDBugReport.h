//
//  SHDBugReport.h
//  Shakedown
//
//  Created by Max Goedjen on 4/17/13.
//  Copyright (c) 2013 Max Goedjen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHDBugReport : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *generalDescription;
@property (nonatomic, strong) NSString *reproducability;
@property (nonatomic, strong) NSArray *steps;
@property (nonatomic, strong) NSMutableArray *screenshots;
@property (nonatomic, strong) NSDictionary *userInformation;
@property (nonatomic, readonly) NSDictionary *deviceDictionary;

@property (nonatomic, readonly) NSString *formattedReport;

#warning Redmine issue properties

@property (nonatomic, assign) NSString *issueTracker;
@property (nonatomic, assign) NSInteger statusId;
@property (nonatomic, assign) NSInteger categoryId;

@property (nonatomic, assign) NSInteger assignedToId;
@property (nonatomic, assign) NSInteger parentIssueId;
//-custom_fields - See Custom fields
@property (nonatomic, assign) NSArray * watcherUserIds;


@end
