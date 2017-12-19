//
//  CardView.h
//  SlipCardView
//
//  Created by Jiang on 2017/12/19.
//  Copyright © 2017年 Jim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *dislikeView;
@property (weak, nonatomic) IBOutlet UIImageView *likeView;

@end
