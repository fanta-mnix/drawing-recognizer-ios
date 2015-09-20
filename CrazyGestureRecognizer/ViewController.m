//
//  ViewController.m
//  CrazyGestureRecognizer
//
//  Created by Rafael Fantini da Costa on 9/19/15.
//  Copyright © 2015 Rafael Fantini da Costa. All rights reserved.
//

#import "ViewController.h"
#import "ShapeGestureRecognizer.h"

@interface ViewController ()

@property (nonatomic, strong) ShapeGestureRecognizer *shapeRecognizer;
@property (nonatomic) CGContextRef drawingContext;
@property (nonatomic) CALayer *drawingLayer;
@property (nonatomic) CGPoint lastLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shapeRecognizer = [[ShapeGestureRecognizer alloc] initWithTarget:self action:@selector(circled:)];
    [self.view addGestureRecognizer:self.shapeRecognizer];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGSize viewSize = self.view.frame.size;
    self.drawingContext = CGBitmapContextCreate(NULL, viewSize.width, viewSize.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    self.drawingLayer = [CALayer layer];
    self.drawingLayer.frame = self.view.layer.bounds;
    self.drawingLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.drawingLayer.delegate = self;
    [self.view.layer addSublayer:self.drawingLayer];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)dealloc {
    if (self.drawingContext != NULL) {
        CGContextRelease(self.drawingContext);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGImageRef drawingImage = CGBitmapContextCreateImage(self.drawingContext);
    CGContextDrawImage(ctx, layer.bounds, drawingImage);
    CGImageRelease(drawingImage);
}

- (void)circled:(ShapeGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastLocation = [gestureRecognizer locationInView:self.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gestureRecognizer locationInView:self.view];
        CGContextSetLineWidth(self.drawingContext, 1.0f);
        CGContextSetLineCap(self.drawingContext, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(self.drawingContext, [UIColor blackColor].CGColor);
        CGContextMoveToPoint(self.drawingContext, self.lastLocation.x, self.lastLocation.y);
        CGContextAddLineToPoint(self.drawingContext, location.x, location.y);
        CGContextStrokePath(self.drawingContext);
        
        self.lastLocation = location;
        
        [self.drawingLayer setNeedsDisplay];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat radius =  gestureRecognizer.radius;
        CGSize circleSize = CGSizeMake(2 * radius, 2 * radius);
        UIView *circleView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, circleSize }];
        circleView.center = gestureRecognizer.center;
        circleView.backgroundColor = [UIColor redColor];
        circleView.layer.cornerRadius = radius;
        [self.view addSubview:circleView];
        NSLog(@"Found!");
    }
}

@end
