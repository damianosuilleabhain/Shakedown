//
//  SHDShakedownRedmineReporter.h
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/22/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "SHDShakedownReporter.h"

@interface SHDShakedownRedmineReporter : SHDShakedownReporter

- (id)initWithApiUrl:(NSString *)apiUrl;

@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, strong) NSString *userApiToken;

@property (nonatomic, assign) NSInteger project_id;
@property (nonatomic, assign) NSInteger tracker_id;
@property (nonatomic, assign) NSInteger status_id;
@property (nonatomic, assign) NSInteger category_id;
@property (nonatomic, assign) NSInteger assigned_to_id;
@property (nonatomic, assign) NSInteger parent_issue_id;
//-custom_fields - See Custom fields
@property (nonatomic, assign) NSArray * watcher_user_ids;

//Parameters:
//
//issue - A hash of the issue attributes:
//
//-project_id
//-tracker_id
//-status_id
//-subject
//-description
//-category_id
//-assigned_to_id - ID of the user to assign the issue to (currently no mechanism to assign by name)
//-parent_issue_id - ID of the parent issue
//-custom_fields - See Custom fields
//-watcher_user_ids - Array of user ids to add as watchers (since 2.3.0)
//
//POST /issues.json
//{
//    "issue": {
//        "project_id": 1,
//        "subject": "Example",
//        "priority_id": 4
//    }
//}

@end
