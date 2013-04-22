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
@property (nonatomic, assign) NSInteger projectId;

@end
