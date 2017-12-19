//
//  DragCardView.h
//  DragCardsView
//
//  Created by Jiang on 2017/11/22.
//  Copyright © 2017年 Jim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JIMSlipCardView;

@protocol SlipCardViewDelegate <NSObject>
@required
//创建cardView
- (UIView *)slipCardViewCreateCardView:(JIMSlipCardView *)view;
//加载cardView数据
- (void)slipCardView:(JIMSlipCardView *)slipView loadCardView:(UIView *)cardView index:(NSUInteger)index;

@optional
- (void)slipCardView:(JIMSlipCardView *)slipView completed:(UIView *)cardView index:(NSUInteger)index isRight:(BOOL)isRight;
- (void)slipCardView:(JIMSlipCardView *)slipView canceled:(UIView *)cardView index:(NSUInteger)index isRight:(BOOL)isRight;
- (void)slipCardView:(JIMSlipCardView *)slipView cardView:(UIView *)cardView index:(NSUInteger)index progress:(CGFloat)progress isRight:(BOOL)isRight;
//tap手势,可通过tapGestureEnable禁用
- (void)slipCardView:(JIMSlipCardView *)slipView tapCardView:(UIView *)cardView index:(NSUInteger)index;
//判断当前拖拽位置，是否能显示下一个
- (BOOL)slipCardView:(JIMSlipCardView *)slipView canSlipNextForCurrentIndex:(NSUInteger)index;

@end

//如果未设置view的frame,会默认使用screen.bounds
@interface JIMSlipCardView : UIView
@property (nonatomic, weak)id <SlipCardViewDelegate> delegate;
@property (nonatomic, assign)NSUInteger maxShowCount;  //可见的个数 默认为3
@property (nonatomic, assign)NSUInteger preloadCount;  //预加载个数(背后隐藏的个数) 默认为2
@property (nonatomic, assign)CGFloat offsetY;         //每个卡片向下的位移 比如10  前三个: 0.9*10 0.9*0.9*10 0.9*0.9*0.9*10
@property (nonatomic, assign)CGFloat scaleRatio;      //缩放比例 比如0.9  前三个: 0.9 0.9*0.9 0.9*0.9*0.9
@property (nonatomic, assign)CGRect  cardFrame;       //默认为 center,300 * 400
@property (nonatomic, assign)CGFloat limit;           //判断成功失败的界限 默认为150,cardSize.width(300)的一半
@property (nonatomic, assign)CGFloat maxAngle;        //动画最大倾斜的角度
@property (nonatomic, assign)BOOL tapGestureEnable;

- (instancetype)initWithDelegate:(id<SlipCardViewDelegate>)delegate;

- (void)reload;

- (void)dragToLeft;
- (void)dragToRight;
@end


