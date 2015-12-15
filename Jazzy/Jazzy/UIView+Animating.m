//
//  UIView+Animating.m
//  Jazzy
//
//  Created by Oszkó Tamás on 07/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

#import "UIView+Animating.h"

NSString* const UIViewAnimationEnded = @"UIViewAnimationEnded";

@implementation UIView (Animating)

-(void) startFadeAnimationFromRect:(CGRect)fromRect toRect:(CGRect)toRect fromAlpha:(CGFloat)fromAlpha toAlpha:(CGFloat)toAlpha duration:(NSTimeInterval)duration {
    
    self.frame= fromRect;
    self.alpha = 0.0f;
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = fromAlpha;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.frame = toRect;
            self.alpha = toAlpha;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0f animations:^{
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [[NSNotificationCenter defaultCenter] postNotificationName:UIViewAnimationEnded object:self];
            }];
        }];
    }];
}


@end
