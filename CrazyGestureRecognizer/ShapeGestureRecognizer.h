//
//  ShapeGestureRecognizer.h
//  CrazyGestureRecognizer
//
//  Created by Rafael Fantini da Costa on 9/19/15.
//  Copyright © 2015 Rafael Fantini da Costa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeGestureRecognizer : UIGestureRecognizer

@property (nonatomic) CGFloat tolerance;

@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) CGFloat radius;

@end
