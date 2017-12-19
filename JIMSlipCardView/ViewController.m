//
//  ViewController.m
//  SlipCardView
//
//  Created by Jiang on 2017/12/19.
//  Copyright © 2017年 Jim. All rights reserved.
//

#import "ViewController.h"
#import "JIMSlipCardView.h"
#import "CardView.h"

@interface ViewController ()<SlipCardViewDelegate>
@property (weak, nonatomic) IBOutlet JIMSlipCardView *slipView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width-300)/2;
    self.slipView.cardFrame = CGRectMake(x,10,300, 400);
    self.slipView.maxAngle = M_PI_4 * 0.25;
    self.slipView.limit = 150;
    self.slipView.delegate = self;
}

- (IBAction)dislike:(id)sender {
    [self.slipView dragToLeft];
}
- (IBAction)like:(id)sender {
    [self.slipView dragToRight];
}

- (UIView *)slipCardViewCreateCardView:(JIMSlipCardView *)view{
    CardView *cardView = [[CardView alloc] init];
    return cardView;
}

- (BOOL)slipCardView:(JIMSlipCardView *)slipView canSlipNextForCurrentIndex:(NSUInteger)index{
    return YES;
}

//使用数据加载cardView，预加载时调用
- (void)slipCardView:(JIMSlipCardView *)view loadCardView:(CardView *)cardView index:(NSUInteger)index{
    
    /*
     *  数组越界的情况应该在 ↑ slipCardView:canSlipNextForCurrentIndex: 方法中判断
     *  因为不会导致当前index增加
     */
    cardView.likeView.alpha = 0;
    cardView.dislikeView.alpha = 0;
}

//完成
- (void)slipCardView:(JIMSlipCardView *)slipView completed:(UIView *)cardView index:(NSUInteger)index isRight:(BOOL)isRight{
    
}
//进度
- (void)slipCardView:(JIMSlipCardView *)view cardView:(CardView *)cardView index:(NSUInteger)index progress:(CGFloat)progress isRight:(BOOL)isRight{
    if (isRight) {
        cardView.likeView.alpha = progress;
        cardView.dislikeView.alpha = 0;
    }else{
        cardView.dislikeView.alpha = progress;
        cardView.likeView.alpha = 0;
    }
}

//取消
- (void)slipCardView:(JIMSlipCardView *)view canceled:(CardView *)cardView index:(NSUInteger)index isRight:(BOOL)isRight{
    [UIView animateWithDuration:0.25 animations:^{
        if (isRight) {
            cardView.likeView.alpha = 0;
        }else{
            cardView.dislikeView.alpha = 0;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
