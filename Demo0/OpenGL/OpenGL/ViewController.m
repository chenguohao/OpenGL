//
//  ViewController.m
//  OpenGL
//
//  Created by guohao on 3/8/2016.
//  Copyright © 2016 leomaster. All rights reserved.
//

#import "ViewController.h"

#import "ContentView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ContentView *cv = [[ContentView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:cv];

}



@end
