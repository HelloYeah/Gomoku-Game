//
//  ViewController.m
//  Gomoku
//
//  Created by Sekorm on 16/7/25.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "ViewController.h"
#import "CheckerboardView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CheckerboardView * boardView = [[CheckerboardView alloc]initWithFrame:CGRectMake(20, 30, 320, 400)];
    boardView.frame = CGRectMake(20, 30, 320, 400);
    [self.view addSubview:boardView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
