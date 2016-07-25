
//
//  CheckerboardView.m
//  Gomoku
//
//  Created by Sekorm on 16/7/25.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "CheckerboardView.h"
#import "UIView+Frame.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
static const NSInteger kGridCount = 9;
static const CGFloat kChessmanSizeRatio = 0.8; //棋子宽高占格子宽高的百分比,大于0,小于1
static const CGFloat kBoardSpace = 20;

typedef enum : NSUInteger {
    GmkHorizontal,
    GmkVertical,
    GmkObliqueDown, //斜向下
    GmkObliqueUp //斜向上
} GmkDirection;

@interface CheckerboardView ()
@property (nonatomic,assign) CGFloat gridWidth;
@property (nonatomic,assign) CGFloat isBlack;
@property (nonatomic,assign) NSInteger maxLineCount; //一条线上的同颜色的棋子个数
@property (nonatomic,strong) NSMutableDictionary * chessmanDict; //存放棋子字典的字典
@property (nonatomic,strong) NSString * lastKey; //上一个棋子字典的key值
@end

@implementation CheckerboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{

    CGSize size = frame.size;
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, MIN(size.width, size.height), MIN(size.width, size.height))];
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化设置
        [self setUp];
    });
    
}

- (void)setUp{
    
    self.backgroundColor = [UIColor colorWithRed:200/255.0 green:160/255.0 blue:130/255.0 alpha:1];
    [self drawBackground:self.size];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBoard:)]];
    
}

#pragma mark - 绘制棋盘
- (void)drawBackground:(CGSize)size{
    
    self.gridWidth = (size.width - 2 * kBoardSpace) / kGridCount;
    
    //1.开启图像上下文
    UIGraphicsBeginImageContext(size);
    //2.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIColor blackColor]set];
    CGContextSetLineWidth(ctx, 0.8f);
    //3.1 画16条竖线
    for (int i = 0; i <= kGridCount; i ++) {
        CGContextMoveToPoint(ctx, kBoardSpace + i * self.gridWidth , kBoardSpace);
        CGContextAddLineToPoint(ctx, kBoardSpace + i * self.gridWidth , kBoardSpace + kGridCount * self.gridWidth);
    }
    //3.1 画16条横线
    for (int i = 0; i <= kGridCount; i ++) {
        CGContextMoveToPoint(ctx, kBoardSpace, kBoardSpace  + i * self.gridWidth );
        CGContextAddLineToPoint(ctx, kBoardSpace + kGridCount * self.gridWidth , kBoardSpace + i * self.gridWidth);
    }
    CGContextStrokePath(ctx);
    
    //4.获取生成的图片
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    //5.显示生成的图片到imageview
    UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
    [self addSubview:imageView];
    UIGraphicsEndImageContext();
}

//点击棋盘,下棋
- (void)tapBoard:(UITapGestureRecognizer *)tap{

    CGPoint point = [tap locationInView:tap.view];
    //计算下子的列号行号
    NSInteger col = (point.x - kBoardSpace + 0.5 * self.gridWidth) / self.gridWidth;
    NSInteger row = (point.y - kBoardSpace + 0.5 * self.gridWidth) / self.gridWidth;
    NSString * key = [NSString stringWithFormat:@"%ld-%ld",col,row];
    if (![self.chessmanDict.allKeys containsObject:key]) {
        UIView * chessman = [self chessman];
        chessman.center = CGPointMake(kBoardSpace + col * self.gridWidth, kBoardSpace + row * self.gridWidth);
        [self addSubview:chessman];
        [self.chessmanDict setValue:@(self.isBlack) forKey:key];
        self.lastKey = key;
        //检查游戏结果
        [self checkResult:col andRow:row andColor:self.isBlack];
        self.isBlack = !self.isBlack;
    }
}

- (UIView *)chessman{
    UIView * chessmanView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.gridWidth * kChessmanSizeRatio, self.gridWidth * kChessmanSizeRatio)];
    chessmanView.layer.cornerRadius = chessmanView.width * 0.5;
    chessmanView.backgroundColor = !self.isBlack ? [UIColor blackColor]:[UIColor whiteColor];
    return chessmanView;
}

- (NSMutableDictionary *)chessmanDict{
    if (!_chessmanDict) {
        _chessmanDict = [NSMutableDictionary dictionary];
    }
    return _chessmanDict;
}

#pragma mark - 私有方法
//检查此时游戏结果
- (void)checkResult:(NSInteger)col andRow:(NSInteger)row andColor:(BOOL)isBlack{
    
    [self checkResult:col andRow:row andColor:isBlack andDirection:GmkHorizontal];
    [self checkResult:col andRow:row andColor:isBlack andDirection:GmkVertical];
    [self checkResult:col andRow:row andColor:isBlack andDirection:GmkObliqueDown];
    [self checkResult:col andRow:row andColor:isBlack andDirection:GmkObliqueUp];
}

 //判断是否大于等于五个同色相连
- (BOOL)checkResult:(NSInteger)col andRow:(NSInteger)row andColor:(BOOL)isBlack andDirection:(GmkDirection)direction{

    switch (direction) {
        //水平方向检查结果
        case GmkHorizontal:{
            //向前遍历
            for (NSInteger i = col - 1; i > 0; i --) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",i,row];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack) break;
                self.maxLineCount ++;
            }
            //向后遍历
            for (NSInteger i = col + 1; i < kGridCount; i ++) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",i,row];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack) break;
                self.maxLineCount ++;
            }
            if (self.maxLineCount >= 4) {
                [self alertResult];
                self.maxLineCount = 0;
                return YES;
            }
            self.maxLineCount = 0;
        
            break;
        }
        case GmkVertical:{
            //向前遍历
            for (NSInteger i = row - 1; i > 0; i --) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",col,i];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack) break;
                self.maxLineCount ++;
            }
            //向后遍历
            for (NSInteger i = row + 1; i < kGridCount; i ++) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",col,i];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack) break;
                self.maxLineCount ++;
            }
            if (self.maxLineCount >= 4) {
                [self alertResult];
                self.maxLineCount = 0;
                return YES;
            }
            self.maxLineCount = 0;
            break;
        }
        case GmkObliqueDown:{
            //向前遍历
            NSInteger j = col - 1;
            for (NSInteger i = row - 1; i >= 0; i--,j--) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",j,i];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack || j < 0) break;
                self.maxLineCount ++;
            }
            //向后遍历
            j = col + 1;
            for (NSInteger i = row + 1 ; i < kGridCount; i++,j++) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",j,i];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack || j > kGridCount) break;
                self.maxLineCount ++;
            }
            if (self.maxLineCount >= 4) {
                [self alertResult];
                self.maxLineCount = 0;
                return YES;
            }
            self.maxLineCount = 0;
            
        break;
        }
            
        case GmkObliqueUp:{
            //向前遍历
            NSInteger j = col + 1;
            for (NSInteger i = row - 1; i >= 0; i--,j++) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",j,i];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack || j > kGridCount) break;
                self.maxLineCount ++;
            }
            //向后遍历
            j = col - 1;
            for (NSInteger i = row + 1 ; i < kGridCount; i++,j--) {
                NSString * key = [NSString stringWithFormat:@"%ld-%ld",j,i];
                if (![self.chessmanDict.allKeys containsObject:key] || [self.chessmanDict[key] boolValue] != isBlack || j < 0) break;
                self.maxLineCount ++;
            }
            if (self.maxLineCount >= 4) {
                [self alertResult];
                self.maxLineCount = 0;
                return YES;
            }
            self.maxLineCount = 0;
            
            break;
        }
    }
    return NO;
}

- (void)alertResult{

    UIAlertController * alertComtroller = [UIAlertController alertControllerWithTitle:@"游戏结束" message:self.isBlack?@"白方胜":@"黑方胜" preferredStyle:UIAlertControllerStyleAlert];
    [[self getCurrentViewController] presentViewController:alertComtroller animated:YES completion:nil];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"再来一盘" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self newGame];
    }];
    [alertComtroller addAction:action];
}

//获取当前View的控制器对象
-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

#pragma mark - 功能方法
- (void)newGame{
    
    [self.chessmanDict removeAllObjects];
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            continue;
        }
        [view removeFromSuperview];
    }
    self.isBlack = NO;
}

- (void)backOneStep:(UIButton *)sender{
    
    
    if (self.lastKey == nil) {
        sender.enabled = NO;
        UIView * tip = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 160, 100)];
        tip.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        tip.layer.cornerRadius = 8.0f;
        [self addSubview:tip];
        tip.center = CGPointMake(self.width * 0.5, self.height * 0.5);
        UILabel * label = [[UILabel alloc]init];
        label.text = @"只能悔一步棋!!!";
        [label sizeToFit];
        label.center = CGPointMake(tip.width * 0.5, tip.height * 0.5);
        [tip addSubview:label];
        
        
        self.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
            sender.enabled = YES;
            [tip removeFromSuperview];
            
        });
        return;
    }
    [self.chessmanDict removeObjectForKey:self.lastKey];
    [self.subviews.lastObject removeFromSuperview];
    self.isBlack = !self.isBlack;
    self.lastKey = nil;
}
@end
