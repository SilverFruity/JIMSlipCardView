//
//  DragCardView.m
//  DragCardsView
//
//  Created by Jiang on 2017/11/22.
//  Copyright © 2017年 Jim. All rights reserved.
//


#import "JIMSlipCardView.h"
@interface JIMSlipCardView()<UIGestureRecognizerDelegate>
{
    BOOL hasLayout;
    NSMutableArray <NSValue*>* cardTransforms;
    NSMutableArray <NSValue*>* cardFrames;
    CGRect initialFrame;
    BOOL slipCardViewIsAnimation;
}
@property (nonatomic, assign) NSUInteger loadedIndex;
@property (nonatomic, strong) NSMutableArray <UIView *>*cards;
@property (nonatomic, weak) UITapGestureRecognizer *tapGesture;
@end

@implementation JIMSlipCardView
- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) [self setDefaultValues];
    return self;
}
- (instancetype)initWithDelegate:(id<SlipCardViewDelegate>)delegate{
    _delegate = delegate;
    self = [self initWithFrame:CGRectZero];
    if (self) [self setDefaultValues];
    return self;
}
- (void)setDefaultValues{
    _loadedIndex = 0;
    _maxShowCount = 3;
    _preloadCount = 2;
    _scaleRatio = 0.9;
    _cardFrame = CGRectZero;
    _limit = _cardFrame.size.width * 0.5;
    _maxAngle = M_PI_4 * 0.25;
    _offsetY = 5;
    _tapGestureEnable = YES;
    slipCardViewIsAnimation = NO;
}

- (NSUInteger)currentIndex{
    return self.loadedIndex - self.maxShowCount - self.preloadCount;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    NSAssert(self.delegate, @"未设置%@.delegate，请使用: initWithDelegate:",[self class]);
    NSAssert([self.delegate respondsToSelector:@selector(slipCardViewCreateCardView:)], @"slipCardViewCreateCardView:");
    NSAssert([self.delegate respondsToSelector:@selector(slipCardView:loadCardView:index:)], @"slipCardViewCreateCardView:");
    
    if (hasLayout) {
        return;
    }
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    
    UIGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragCard:)];
    dragGesture.delegate = self;
    [self addGestureRecognizer:dragGesture];
    
    if (self.tapGestureEnable) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCard:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        self.tapGesture = tapGesture;
    }
    if (CGRectEqualToRect(self.cardFrame, CGRectZero)) {
        CGFloat viewWidth = 300;
        CGFloat viewHeight = 300;
        CGFloat x = (self.frame.size.width - viewWidth)*0.5;
        CGFloat y = (self.frame.size.height - viewHeight)*0.5;
        self.cardFrame = CGRectMake(x, y, viewWidth, viewHeight);
    }
    CGFloat cardHeight = self.cardFrame.size.height;
    initialFrame = self.cardFrame;
    NSMutableArray *cards = [NSMutableArray array];
    for (NSUInteger index = 0; index < self.preloadCount+self.maxShowCount; index++) {
        UIView *card = [self.delegate slipCardViewCreateCardView:self];
        [self addSubview:card];
        [card layoutIfNeeded];
        [cards addObject:card];
        card.frame = initialFrame;
        [self sendSubviewToBack:card];
    }
    self.cards = cards;
    
    cardTransforms = [NSMutableArray array];
    cardFrames = [NSMutableArray array];
    self.loadedIndex = 0;
    for (NSUInteger index = 0; index < self.preloadCount+self.maxShowCount; index++) {
        UIView *card = self.cards[index];
        [self.delegate slipCardView:self loadCardView:card index:index];
        CGFloat currentRatio = pow(_scaleRatio, index);
        if (index < _maxShowCount) {
            CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, currentRatio, currentRatio);
            CGFloat transformY = 0;
            CGFloat overlayOffsetY = 0;
            for (NSUInteger next = 1; next <= index; next ++) {
                overlayOffsetY += pow(_scaleRatio, next)*_offsetY;
            }
            if (index != 0) {
                transformY = 0.5*cardHeight*(1-currentRatio)+overlayOffsetY;
            }
            transform = CGAffineTransformTranslate(transform, 0, transformY/currentRatio);
            card.transform = transform;
            [cardTransforms addObject:[NSValue valueWithCGAffineTransform:transform]];
            [cardFrames addObject:[NSValue valueWithCGRect:card.frame]];
        }else{
            card.transform = cardTransforms.lastObject.CGAffineTransformValue;
        }
        self.loadedIndex++;
        
    }
    hasLayout = YES;
}

#pragma mark - 重载
- (void)reload{
    for (NSInteger index = 0; index < self.cards.count; index++) {
        if ([self.delegate respondsToSelector:@selector(slipCardView:loadCardView:index:)]) {
            [self.delegate slipCardView:self loadCardView:self.cards[index] index:self.currentIndex+index];
        }
    }
}

#pragma mark - 手势动画
- (void)dragCard:(UIPanGestureRecognizer *)gesture{
    CGFloat limit = self.limit;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [gesture setTranslation:CGPointZero inView:self];
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [gesture translationInView:self];
        UIView *card =  self.cards.firstObject;
        card.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGAffineTransform transform = CGAffineTransformIdentity;
        CGFloat progress = 0;
        progress = translation.x / limit;
        progress = fabs(progress) < 1 ? progress : progress/fabs(progress);
        CGFloat currentAngle = self.maxAngle*progress;
        transform = CGAffineTransformTranslate(transform,translation.x, translation.y);
        transform = CGAffineTransformRotate(transform, currentAngle);
        card.transform = transform;
        
        if ([self.delegate respondsToSelector:@selector(slipCardView:cardView:index:progress:isRight:)]) {
            [self.delegate slipCardView:self cardView:card index:self.currentIndex progress:fabs(progress) isRight:translation.x>0];
        }
        [self zoomShowViewsWithProgress:progress];
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        UIView *card =  self.cards.firstObject;
        CGFloat speed = [gesture velocityInView:self].x;
        CGFloat translation = [gesture translationInView:self].x;
        if ((fabs(speed) > 1000 && fabs(translation)>= limit*0.5)
            ||fabs(translation)>limit) {
            BOOL isRight = translation > 0;
            //判断是否还能继续滑动
            if ([self.delegate respondsToSelector:@selector(slipCardView:canSlipNextForCurrentIndex:)]) {
                BOOL candoNext = [self.delegate slipCardView:self canSlipNextForCurrentIndex:self.currentIndex];
                if (!candoNext) {
                    [self cancelDragCardView:card isRight:isRight];
                    return;
                }
            }
            [self compelteWithCardView:card isRight:isRight];
        }else{
            [self cancelDragCardView:card isRight:translation > 0];
        }
    }
}



#pragma mark - 卡片的缩放动画
- (void)zoomShowViewsWithProgress:(CGFloat)progress{
    for (NSUInteger index = 1; index < self.maxShowCount; index++) {
        UIView *view = self.cards[index];
        CGAffineTransform otherTransform = [cardTransforms objectAtIndex:index].CGAffineTransformValue;
        CGFloat toLastScale = 1.0/_scaleRatio - 1;
        CGFloat scale = toLastScale*fabs(progress) + 1;
        otherTransform = CGAffineTransformScale(otherTransform,scale,scale);
        
        CGFloat currentRatio = pow(_scaleRatio, index);
        
        //消除scale(放大)后带来的y偏移量
        //(当前缩放比例-初始缩放比例)*原始高度
        CGFloat avoidScaleTranslation = (otherTransform.a - currentRatio)*CGRectGetHeight(initialFrame);
        otherTransform = CGAffineTransformTranslate(otherTransform, 0, -avoidScaleTranslation*0.5/otherTransform.a);
        
        CGFloat toLastTranslation = _offsetY * fabs(progress) * currentRatio;
        otherTransform = CGAffineTransformTranslate(otherTransform, 0, -toLastTranslation/otherTransform.a);
        
        view.transform = otherTransform;
    
    }
}

#pragma mark - 取消
- (void)cancelDragCardView:(UIView *)card isRight:(BOOL)isRight{

    if ([self.delegate respondsToSelector:@selector(slipCardView:canceled:index:isRight:)]) {
        [self.delegate slipCardView:self canceled:card index:self.currentIndex isRight:isRight];
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (NSUInteger index = 0; index < self.maxShowCount; index++) {
            self.cards[index].transform = cardTransforms[index].CGAffineTransformValue;
        }
    } completion:nil];
}

#pragma mark - 完成
- (void)compelteWithCardView:(UIView *)cardView isRight:(BOOL)isRight{
    if ([self.delegate respondsToSelector:@selector(slipCardView:completed:index:isRight:)]) {
        [self.delegate slipCardView:self completed:cardView index:self.currentIndex isRight:isRight];
    }
    
    self.loadedIndex ++;
    [self completeAnimatinWithIsRight:isRight card:cardView animateComplete:^(BOOL finished){
        [self.delegate slipCardView:self loadCardView:self.cards.lastObject index:self.loadedIndex];
        slipCardViewIsAnimation = NO;
    }];
    
}
#pragma mark  完成动画
- (void)completeAnimatinWithIsRight:(BOOL)isRight card:(UIView *)card animateComplete:(void(^)(BOOL finished))complete{
    
    [self zoomShowViewsWithProgress:1.0];
    [self.cards removeObject:card];
    [self.cards addObject:card];
    [card removeFromSuperview];
    card.layer.zPosition = 1000;
    [self insertSubview:card atIndex:0];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat value = isRight? 1 : -1;
        CGFloat translation = card.frame.size.width;
        card.layer.position = CGPointMake(card.layer.position.x+translation*value, card.layer.position.y);
    }completion:^(BOOL finished) {
        card.layer.zPosition = 0;
        card.transform = CGAffineTransformIdentity;
        card.frame = initialFrame;
        card.transform = cardTransforms.lastObject.CGAffineTransformValue;
        for (NSUInteger index = 0; index < self.maxShowCount; index++) {
            UIView *view = self.cards[index];
            view.transform = cardTransforms[index].CGAffineTransformValue;
        }
        complete(finished);
    }];
}

#pragma mark - 不使用手势的滑牌动画
- (void)dragToLeft{
    [self doDrag:NO];
}

-(void)dragToRight{
    [self doDrag:YES];
}

- (void)doDrag:(BOOL)isRight{
    
    UIView *topCard = self.cards.firstObject;
    
    if (slipCardViewIsAnimation) {
        return;
    }
    //判断是否还能继续滑动
    if ([self.delegate respondsToSelector:@selector(slipCardView:canSlipNextForCurrentIndex:)]) {
        BOOL candoNext = [self.delegate slipCardView:self canSlipNextForCurrentIndex:self.currentIndex];
        if (!candoNext) {
            [self cancelDragCardView:topCard isRight:isRight];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(slipCardView:cardView:index:progress:isRight:)]) {
        [self.delegate slipCardView:self cardView:topCard index:self.currentIndex progress:1.0 isRight:isRight];
    }
    
    slipCardViewIsAnimation = YES;
    CGFloat value = isRight? 1.0 : -1;
    //旋转
    CGFloat translation = topCard.frame.size.width;
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(value*self.maxAngle);
        transform = CGAffineTransformTranslate(transform, value*translation*cos(_maxAngle), -translation*sin(_maxAngle));
        topCard.transform = transform;
        [self zoomShowViewsWithProgress:1.0];
    }completion:^(BOOL finished) {
        [self compelteWithCardView:topCard isRight:isRight];
    }];
}

#pragma mark - tapGesture
- (void)setTapGestureEnable:(BOOL)tapGestureEnable{
    _tapGestureEnable = tapGestureEnable;
    if (_tapGesture) _tapGesture.enabled = _tapGestureEnable;
}
- (void)tapCard:(UITapGestureRecognizer *)tapGesture{
    if ([self.delegate respondsToSelector:@selector(slipCardView:tapCardView:index:)]) {
        [self.delegate slipCardView:self tapCardView:self.cards.firstObject index:self.currentIndex];
    }
}

#pragma mark - 手势有效范围
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    BOOL isContainTopCardView = CGRectContainsPoint(self.cards.firstObject.frame, [gestureRecognizer locationInView:self]);
    return isContainTopCardView;
}

@end

