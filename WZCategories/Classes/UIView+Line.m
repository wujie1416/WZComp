//
//  UIView+Line.m
//  magazineiosapp
//
//  Created by FU JUN on 16/3/28.
//  Copyright © 2016年 cmkj. All rights reserved.
//

#import "UIView+Line.h"
@implementation UIView (Line)

#define LineThick (1.0/[UIScreen mainScreen].scale)

- (void)addEdgeLine:(LineType)linetype
{
    [self private_addLine:linetype lineColor:[UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0] lineWidth:LineThick];
}

- (void)addEdgeLine:(LineType)linetype lineColor:(UIColor *) lineCorlor
{
    [self private_addLine:linetype lineColor:lineCorlor lineWidth:LineThick];
}

- (void)addEdgeLine:(LineType)linetype lineColor:(UIColor *)lineCorlor lineWidth:(CGFloat)lineWidth
{
    [self private_addLine:linetype lineColor:lineCorlor lineWidth:lineWidth];
}

- (void)private_addLine:(LineType)type lineColor:(UIColor *)color lineWidth:(CGFloat)width
{
    switch (type) {
        case LineLeft:
        {
            UIView *leftBorder = [[UIView alloc] init];
            [leftBorder setBackgroundColor:color];
            [self addSubview:leftBorder];
            leftBorder.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *leftC = [NSLayoutConstraint constraintWithItem:leftBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *centerYC = [NSLayoutConstraint constraintWithItem:leftBorder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
            NSLayoutConstraint *borderWidth = [NSLayoutConstraint constraintWithItem:leftBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:width];
            NSLayoutConstraint *borderHeight = [NSLayoutConstraint constraintWithItem:leftBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
            [leftBorder addConstraints:@[borderWidth]];
            [self addConstraints:@[leftC,centerYC,borderHeight]];
        }
            break;
        case LineBottom:
        {
            UIView *bottommBorder = [[UIView alloc] init];
            [bottommBorder setBackgroundColor:color];
            [self addSubview:bottommBorder];
            bottommBorder.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *bottomC = [NSLayoutConstraint constraintWithItem:bottommBorder attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            NSLayoutConstraint *centerXC = [NSLayoutConstraint constraintWithItem:bottommBorder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
            NSLayoutConstraint *borderWidth = [NSLayoutConstraint constraintWithItem:bottommBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
            NSLayoutConstraint *borderHeight = [NSLayoutConstraint constraintWithItem:bottommBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:width];
            [bottommBorder addConstraints:@[borderHeight]];
            [self addConstraints:@[bottomC,centerXC,borderWidth]];
        }
            break;
        case LineRight:
        {
            UIView *rightBorder = [[UIView alloc] init];
            [rightBorder setBackgroundColor:color];
            [self addSubview:rightBorder];
            rightBorder.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *rightC = [NSLayoutConstraint constraintWithItem:rightBorder attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSLayoutConstraint *centerYC = [NSLayoutConstraint constraintWithItem:rightBorder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
            NSLayoutConstraint *borderWidth = [NSLayoutConstraint constraintWithItem:rightBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:width];
            NSLayoutConstraint *borderHeight = [NSLayoutConstraint constraintWithItem:rightBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
            [rightBorder addConstraints:@[borderWidth]];
            [self addConstraints:@[rightC,centerYC,borderHeight]];
        }
            break;
        case LineTop:
        {
            UIView *topBorder = [[UIView alloc] init];
            [topBorder setBackgroundColor:color];
            [self addSubview:topBorder];
            topBorder.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *topC = [NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *centerXC = [NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
            NSLayoutConstraint *borderWidth = [NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
            NSLayoutConstraint *borderHeight = [NSLayoutConstraint constraintWithItem:topBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:width];
            [topBorder addConstraints:@[borderHeight]];
            [self addConstraints:@[topC,centerXC,borderWidth]];
        }
        default:
            break;
    }
}

@end
