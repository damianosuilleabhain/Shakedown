//
//  NSString+Shakedown.m
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/29/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "NSString+Shakedown.h"

@implementation NSString (Shakedown)

+ (NSString *)shakedownDocumentsPath
{
    static NSString * path = nil;
    if (!path) {
        NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *resultDir = [libDir stringByAppendingPathComponent:@"ShakedownDocuments"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:resultDir isDirectory:NULL])
            [[NSFileManager defaultManager] createDirectoryAtPath:resultDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        path = resultDir;
    }
    return path;
}

+ (NSString *)trackersDocumentPath
{
    return [[NSString shakedownDocumentsPath] stringByAppendingPathComponent:@"issueTrackers.dat"];
}

@end
