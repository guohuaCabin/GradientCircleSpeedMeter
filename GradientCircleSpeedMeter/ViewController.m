//
//  ViewController.m
//  GradientCircleSpeedMeter
//
//  Created by qinguohua on 2019/8/10.
//  Copyright © 2019 qinguohua. All rights reserved.
//

#import "ViewController.h"
#import "TapeCircleView.h"
#import "GradientSemicirclePointerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView1];
    [self createView2];
}

-(void)createView1
{
    TapeCircleView *view =[[TapeCircleView alloc]initWithFrame:CGRectMake(30, 100, 140, 140)];
    [self.view addSubview:view];
    [view configData:nil];

}

-(void)createView2
{
    GradientSemicirclePointerView *view =[[GradientSemicirclePointerView alloc]initWithFrame:CGRectMake(30, 300, 120, 120)];
    [self.view addSubview:view];
    [view configData:nil];
}


@end
