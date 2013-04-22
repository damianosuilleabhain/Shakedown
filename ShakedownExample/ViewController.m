//
//  ViewController.m
//  ShakedownExample
//
//  Created by Alexey Bahtin on 4/22/13.
//  Copyright (c) 2013 Brightstarsoftware. All rights reserved.
//

#import "ViewController.h"
#import "SHDShakedown.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logIssue:(id)sender {
    [[SHDShakedown sharedShakedown] displayReporter];
    
}
@end
