//
//  ShapeGestureRecognizer.m
//  CrazyGestureRecognizer
//
//  Created by Rafael Fantini da Costa on 9/19/15.
//  Copyright © 2015 Rafael Fantini da Costa. All rights reserved.
//

#import "ShapeGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

static inline CGFloat CGPointLength(CGPoint p) {
    return sqrtf(p.x * p.x + p.y * p.y);
}

static inline CGPoint CGPointSubtract(CGPoint lhs, CGPoint rhs) {
    return CGPointMake(lhs.x - rhs.x, lhs.y - rhs.y);
}

static inline CGFloat CGPointDistance(CGPoint lhs, CGPoint rhs) {
    return CGPointLength(CGPointSubtract(lhs, rhs));
}

@interface ShapeGestureRecognizer ()

@property (nonatomic, strong, readonly) NSMutableArray<NSValue *> *touchLocations;
@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readwrite) CGFloat radius;

@end

@implementation ShapeGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        _touchLocations = [NSMutableArray new];
        _tolerance = 0.15f;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    CGPoint location = [[touches anyObject] locationInView:self.view];
    [self.touchLocations addObject:[NSValue valueWithCGPoint:location]];
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    self.state = [self touchesFormACircle]
        ? UIGestureRecognizerStateEnded
        : UIGestureRecognizerStateFailed;
}

- (BOOL)touchesFormACircle {
    CGPoint center = CGPointZero;
    NSInteger touchCount = self.touchLocations.count;
    for (NSValue *value in self.touchLocations) {
        CGPoint touchLocation = value.CGPointValue;
        center.x += touchLocation.x;
        center.y += touchLocation.y;
    }
    center.x /= touchCount;
    center.y /= touchCount;
    
    CGFloat radius = 0.0f;
    for (NSValue *value in self.touchLocations) {
        CGPoint touchLocation = value.CGPointValue;
        CGFloat distance = CGPointDistance(center, touchLocation);
        radius += distance;
    }
    radius /= touchCount;
    
    CGFloat error = 0.0f; // mean square error
    for (NSValue *value in self.touchLocations) {
        CGPoint touchLocation = value.CGPointValue;
        CGFloat distance = CGPointDistance(center, touchLocation);
        error += fabs(distance - radius);
    }
    error = (error / touchCount) / radius; // Normalize error by radius
    
    if (error < self.tolerance) {
        self.radius = radius;
        self.center = center;
        return YES;
    } else {
        return NO;
    }
}

- (void)reset {
    [super reset];
    [self.touchLocations removeAllObjects];
    self.center = CGPointZero;
    self.radius = 0.0f;
    self.state = UIGestureRecognizerStatePossible;
}

@end
