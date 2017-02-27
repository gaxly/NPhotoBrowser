//
//  NProgressLayer.h
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NProgressLayer : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startSpin;
- (void)stopSpin;

@end
