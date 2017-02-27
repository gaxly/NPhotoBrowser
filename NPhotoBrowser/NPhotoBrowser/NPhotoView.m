//
//  NPhotoView.m
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import "NPhotoView.h"
#import "NPhoto.h"
#import "NProgressLayer.h"
#import <YYWebImage/YYWebImage.h>

const CGFloat photoViewPadding = 10;
const CGFloat photoViewMaxScale = 3;

@interface NPhotoView () <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) YYAnimatedImageView *imageView;
@property (nonatomic, strong, readwrite) NProgressLayer *progressLayer;
@property (nonatomic, strong, readwrite) NPhoto *photo;

@end

@implementation NPhotoView

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.bouncesZoom = YES;
//        self.maximumZoomScale = photoViewMaxScale;
//        self.multipleTouchEnabled = YES;
//        self.showsVerticalScrollIndicator = YES;
//        self.showsHorizontalScrollIndicator = YES;
//        self.delegate = self;
//        
//        _imageView = [[YYAnimatedImageView alloc] init];
//        _imageView.backgroundColor = [UIColor darkGrayColor];
//        _imageView.contentMode = UIViewContentModeScaleAspectFill;
//        _imageView.clipsToBounds = YES;
//        [self addSubview:_imageView];
//        [self resizeImageView];
//        
//        _progressLayer = [[NProgressLayer alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//        _progressLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2);;
//        _progressLayer.hidden = YES;
//        [self.layer addSublayer:_progressLayer];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.maximumZoomScale = photoViewMaxScale;
        self.multipleTouchEnabled = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = self;
        
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.backgroundColor = [UIColor darkGrayColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self resizeImageView];
        
        _progressLayer = [[NProgressLayer alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _progressLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

//- (void)setPhoto:(NPhoto *)photo determinate:(BOOL)determinate {
//    _photo = photo;
//    [_imageView yy_cancelCurrentImageRequest];
//    if (photo) {
//        if (photo.image) {
//            _imageView.image = photo.image;
//            NSLog(@"-- %@",NSStringFromCGRect(_imageView.frame));
//            _photo.finished = YES;
//            [_progressLayer stopSpin];
//            _progressLayer.hidden = YES;
//            [self resizeImageView];
//            return;
//        }
//        __weak typeof(self) wself = self;
//        YYWebImageProgressBlock progressBlock = nil;
//        if (determinate) {
//            progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
//                __strong typeof(wself) sself = wself;
//                double progress = (double)receivedSize / expectedSize;
//                sself.progressLayer.hidden = NO;
//                sself.progressLayer.strokeEnd = MAX(progress, 0.01);
//            };
//        } else {
//            [_progressLayer startSpin];
//        }
//        _progressLayer.hidden = NO;
//        
//        _imageView.image = photo.thumbImage;
//        [_imageView yy_setImageWithURL:photo.imageUrl placeholder:photo.thumbImage options:kNilOptions progress:progressBlock transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
//            __strong typeof(wself) sself = wself;
//            if (stage == YYWebImageStageFinished) {
//                [sself resizeImageView];
//            }
//            [sself.progressLayer stopSpin];
//            sself.progressLayer.hidden = YES;
//            sself.photo.finished = YES;
//        }];
//    } else {
//        [_progressLayer stopSpin];
//        _progressLayer.hidden = YES;
//        _imageView.image = nil;
//    }
//    [self resizeImageView];
//}

- (void)setPhoto:(NPhoto *)photo determinate:(BOOL)determinate {
    _photo = photo;
    [_imageView yy_cancelCurrentImageRequest];
    if (photo) {
        if (photo.image) {
            _imageView.image = photo.image;
            NSLog(@"-- %@",NSStringFromCGRect(_imageView.frame));
            _photo.finished = YES;
            [_progressLayer stopSpin];
            _progressLayer.hidden = YES;
            [self resizeImageView];
            return;
        }
        __weak typeof(self) wself = self;
        YYWebImageProgressBlock progressBlock = nil;
        if (determinate) {
            progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
                __strong typeof(wself) sself = wself;
                double progress = (double)receivedSize / expectedSize;
                sself.progressLayer.hidden = NO;
                sself.progressLayer.strokeEnd = MAX(progress, 0.01);
            };
        } else {
            [_progressLayer startSpin];
        }
        _progressLayer.hidden = NO;
        
        _imageView.image = photo.thumbImage;
        [_imageView yy_setImageWithURL:photo.imageUrl placeholder:photo.thumbImage options:kNilOptions progress:progressBlock transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            __strong typeof(wself) sself = wself;
            if (stage == YYWebImageStageFinished) {
                [sself resizeImageView];
            }
            [sself.progressLayer stopSpin];
            sself.progressLayer.hidden = YES;
            sself.photo.finished = YES;
        }];
    } else {
        [_progressLayer stopSpin];
        _progressLayer.hidden = YES;
        _imageView.image = nil;
    }
    [self resizeImageView];
}

//- (void)resizeImageView {
//    if (_imageView.image) {
//        NSLog(@"-- %@",NSStringFromCGRect(_imageView.frame));
//        CGSize imageSize = _imageView.image.size;
//        CGFloat width = _imageView.frame.size.width;
//        CGFloat height = width * (imageSize.height / imageSize.width);
//        CGRect rect = CGRectMake(0, 0, width, height);
//        _imageView.frame = rect;
//        
//        // If image is very high, show top content.
//        if (height <= self.bounds.size.height) {
//            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//        } else {
//            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
//        }
//        
//        // If image is very wide, make sure user can zoom to fullscreen.
//        if (width / height > 2) {
//            self.maximumZoomScale = self.bounds.size.height / height;
//        } else {
//            CGFloat width = self.frame.size.width - 2 * photoViewPadding;
//            _imageView.frame = CGRectMake(0, 0, width, width * 2 / 3);
//            _imageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
//        }
//    }
//    self.contentSize = _imageView.frame.size;
//}

- (void)resizeImageView {
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = _imageView.frame.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        
        // If image is very high, show top content.
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // If image is very wide, make sure user can zoom to fullscreen.
        if (width / height > 2) {
            self.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        CGFloat width = self.frame.size.width - 2 * photoViewPadding;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    self.contentSize = _imageView.frame.size;
}

- (void)cancelCurrentImageLoad {
    [_imageView yy_cancelCurrentImageRequest];
    [_progressLayer stopSpin];
}

#pragma mark - scrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}



@end
