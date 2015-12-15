//
//  UIView+Animating.h
//  Jazzy
//
//  Created by Oszkó Tamás on 07/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const UIViewAnimationEnded;

@interface UIView (Animating)

-(void) startFadeAnimationFromRect:(CGRect)fromRect toRect:(CGRect)toRect fromAlpha:(CGFloat)fromAlpha toAlpha:(CGFloat)toAlpha duration:(NSTimeInterval)duration;

@end
