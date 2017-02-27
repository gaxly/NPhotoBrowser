//
//  NPhotoView.h
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NProgressLayer.h"

extern const CGFloat photoViewPadding;

@class NPhoto, YYAnimatedImageView;

@interface NPhotoView : UIScrollView

@property (nonatomic, strong, readonly) YYAnimatedImageView *imageView;
@property (nonatomic, strong, readonly) NProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) NPhoto *photo;

- (void)setPhoto:(NPhoto *)photo determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end
