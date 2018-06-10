//
//  XDViewController.m
//  XDSecurityDefense
//
//  Created by shixiaoda on 06/09/2018.
//  Copyright (c) 2018 shixiaoda. All rights reserved.
//

#import "XDViewController.h"
#import "XDSecurityDefenseManager.h"

@interface XDViewController ()

@end

@implementation XDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [XDSecurityDefenseManager initWithClassPrefix:@[@"XD"] ignoreFragment:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customFunc2
{
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidAppear {
    
}

- (void)viewDidAppear2 {
    
}
@end
