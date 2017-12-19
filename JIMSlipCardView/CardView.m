//
//  CardView.m
//  SlipCardView
//
//  Created by Jiang on 2017/12/19.
//  Copyright © 2017年 Jim. All rights reserved.
//

#import "CardView.h"

@implementation CardView
- (instancetype)init{
    self = [[NSBundle mainBundle] loadNibNamed:@"CardView" owner:nil options:nil].firstObject;
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
