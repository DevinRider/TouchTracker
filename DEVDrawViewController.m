//
//  DEVDrawViewController.m
//  TouchTracker
//
//  Created by Devin on 6/12/14.
//  Copyright (c) 2014 Devin Rider. All rights reserved.
//

#import "DEVDrawViewController.h"
#import "DEVDrawView.h"

@implementation DEVDrawViewController

- (void)loadView
{
    self.view = [[DEVDrawView alloc] initWithFrame:CGRectZero];
}

@end
