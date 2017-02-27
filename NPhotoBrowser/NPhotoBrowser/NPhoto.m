//
//  NPhoto.m
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import "NPhoto.h"

@implementation NPhoto

- (instancetype)initWithSourceView:(UIView *)view thumbImage:(UIImage *)thumbImage imageUrl:(NSURL *)imageUrl {
    if (self = [super init]) {
        _sourceView = view;
        _thumbImage = thumbImage;
        _imageUrl = imageUrl;
    }
    return self;
}

+ (instancetype)photoWithSourceView:(UIView *)view thumbImage:(UIImage *)thumbImage imageUrl:(NSURL *)imageUrl {
    return [[self alloc] initWithSourceView:view thumbImage:thumbImage imageUrl:imageUrl];
}

- (instancetype)initWithSourceView:(UIImageView *)imageView imageUrl:(NSURL *)imageUrl {
    return [self initWithSourceView:imageView thumbImage:imageView.image imageUrl:imageUrl];
}

+ (instancetype)photoWithSourceView:(UIImageView *)imageView imageUrl:(NSURL *)imageUrl {
    return [[self alloc] initWithSourceView:imageView imageUrl:imageUrl];
}

@end
