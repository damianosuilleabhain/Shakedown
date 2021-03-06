//
//  SHDShakedown.m
//  Shakedown
//
//  Created by Max Goedjen on 4/16/13.
//  Copyright (c) 2013 Max Goedjen. All rights reserved.
//

#import "SHDShakedown.h"
#import "SHDConstants.h"
#import "UIWindow+SHDShakeListener.h"
#import "SHDReporterViewController.h"
#import "SHDBugReport.h"
#import "SHDShakedownEmailReporter.h"

@interface SHDShakedown ()

@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation SHDShakedown

- (id)init {
    self = [super init];
    if (self) {
        [self resumeListeningForShakes];
        [self displayButton];
    }
    return self;
}

+ (SHDShakedown *)sharedShakedown {
    static dispatch_once_t onceToken;
    static SHDShakedown *instance = nil;
    dispatch_once(&onceToken, ^{
#if defined(DEBUG) || defined(ADHOC)
        instance = [[SHDShakedown alloc] init];
#endif
    });
    return instance;
}

#pragma mark - User info

- (void)attachUserInformation:(NSDictionary *)info {
    self.userInfo = info;
}

#pragma mark - Shake

- (void)stopListeningForShakes {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resumeListeningForShakes {
    [[NSNotificationCenter defaultCenter] addObserverForName:kSHDShakeEvent object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self _showReporter];
    }];
}

#pragma mark - Status Bar Button

- (void)displayButton {
}

- (void)hideButton {
}

#pragma mark - Programmatic Reporting

- (void)displayReporter {
    [self _showReporter];
}

- (void)setReporter:(SHDShakedownReporter *)reporter
{
    _reporter = reporter;
    [_reporter.reporterSpecificDatasource updateDatasourceIfNeededWithCompletionHandler:nil];
}

#pragma mark - Reporting

- (void)_showReporter {
    if (!self.reporter) {
        self.reporter = [[SHDShakedownEmailReporter alloc] init];
    }

    SHDBugReport *newBug = [[SHDBugReport alloc] init];
    SHDReporterSpecificDatasource * datasource = self.reporter.reporterSpecificDatasource;
    SHDReporterViewController *viewController = [[SHDReporterViewController alloc] initWithNibName:nil bundle:nil bugReport:newBug datasource:datasource];
    
    UIViewController *root = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
    UIViewController *presented = root;
    while (presented.presentedViewController) {
        presented = presented.presentedViewController;
    }
    if ([presented isMemberOfClass:[SHDReporterViewController class]] == NO) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [presented presentViewController:navController animated:YES completion:nil];

    }
    
}

@end
