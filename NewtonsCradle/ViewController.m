//
//  ViewController.m
//  NewtonsCradle
//
//  Created by Evan Ische on 5/20/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "ViewController.h"
#import "HDPendulumView.h"

@interface ViewController ()
@end

@implementation ViewController {
    NSArray *_newtonsBalls;
    UIDynamicAnimator *_animator;
    UIPushBehavior *_pushBehavior;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds)/2, CGRectGetWidth(self.view.bounds)/2);
    HDPendulumView *view = [[HDPendulumView alloc] initWithFrame:bounds];
    view.center = self.view.center;
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

