//
//  ViewController.m
//  Gomoku
//
//  Created by Sekorm on 16/7/25.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "ViewController.h"
#import "CheckerboardView.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
@property (nonatomic,weak) CheckerboardView * boardView;
@property (nonatomic,weak) UIButton * backButton;
@property (nonatomic,weak) UIButton * reStartBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}


- (void)setUp{
    
    //添加棋盘
    CheckerboardView * boardView = [[CheckerboardView alloc]initWithFrame:CGRectMake(20, 30, ScreenW * 0.95, CGFLOAT_MAX)];
    boardView.center = self.view.center;
    [self.view addSubview:boardView];
    self.boardView = boardView;
    
    //悔棋
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"悔棋" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    backButton.backgroundColor = [UIColor colorWithRed:200/255.0 green:160/255.0 blue:130/255.0 alpha:1];
    backButton.frame = CGRectMake(CGRectGetMinX(boardView.frame), CGRectGetMaxY(boardView.frame) + 20, CGRectGetWidth(boardView.frame) * 0.45, 35);
    backButton.layer.cornerRadius = 4;
    [self.view addSubview:backButton];
    self.backButton = backButton;
    [backButton addTarget:self action:@selector(backOneStep:) forControlEvents:UIControlEventTouchUpInside];
    
    //新游戏
    UIButton * reStartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reStartBtn setTitle:@"新游戏" forState:UIControlStateNormal];
    reStartBtn.backgroundColor = [UIColor colorWithRed:200/255.0 green:160/255.0 blue:130/255.0 alpha:1];
    reStartBtn.frame = CGRectMake(CGRectGetMaxX(boardView.frame) - CGRectGetWidth(boardView.frame) * 0.45, CGRectGetMaxY(boardView.frame) + 20, CGRectGetWidth(boardView.frame) * 0.45, 35);
    reStartBtn.layer.cornerRadius = 4;
    [self.view addSubview:reStartBtn];
    self.reStartBtn = reStartBtn;
    [reStartBtn addTarget:self action:@selector(newGame) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backOneStep:(UIButton *)sender{
    [self.boardView backOneStep:(UIButton *)sender];
}

- (void)newGame{
    
    [self.boardView newGame];
}


@end
