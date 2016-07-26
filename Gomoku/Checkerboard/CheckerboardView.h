//
//  CheckerboardView.h
//  Gomoku
//
//  Created by Sekorm on 16/7/25.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckerboardView : UIView

- (void)backOneStep:(UIButton *)sender;
- (void)newGame;
- (void)changeBoardLevel;
@end
