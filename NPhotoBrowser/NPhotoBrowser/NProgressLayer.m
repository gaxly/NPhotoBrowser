//
//  NProgressLayer.m
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import "NProgressLayer.h"

@interface NProgressLayer ()<CAAnimationDelegate>

@property (nonatomic, assign) BOOL isSpinning;

@end

@implementation NProgressLayer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self.frame = frame;
        self.cornerRadius = 20;
        self.fillColor = [UIColor clearColor].CGColor;
        self.strokeColor = [UIColor whiteColor].CGColor;
        self.lineWidth = 4.0;
        self.lineCap = kCALineCapRound;
        self.strokeStart = 0.0;
        self.strokeEnd = 0.01;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(self.bounds, 2, 2) cornerRadius:20-2];
        self.path = path.CGPath;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)noti {
    if (self.isSpinning) {
        [self startSpin];
    }
}

- (void)startSpin {
    self.isSpinning = YES;
    [self spinWithAngle:M_PI];
}

- (void)spinWithAngle:(CGFloat)angle {
    self.strokeEnd = 0.33;
    CABasicAnimation *rotationAniation;
    rotationAniation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAniation.toValue = @(M_PI - 0.5);
    rotationAniation.duration = 0.4;
    rotationAniation.cumulative = YES;
    rotationAniation.repeatCount = HUGE;
    [self addAnimation:rotationAniation forKey:nil];
}

- (void)stopSpin {
    self.isSpinning = NO;
    [self removeAllAnimations];
}

@end
