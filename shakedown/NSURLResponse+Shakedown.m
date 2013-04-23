//
//  NSURLResponse+Shakedown.m
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/23/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "NSURLResponse+Shakedown.h"

@implementation NSURLResponse (Shakedown)

- (NSInteger)statusCodeIfHttpResponce
{
    NSInteger statusCode = 500;
    if ([self isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse * httpResponce = (NSHTTPURLResponse *)self;
        statusCode = httpResponce.statusCode;
    }
    return statusCode;
}

@end
