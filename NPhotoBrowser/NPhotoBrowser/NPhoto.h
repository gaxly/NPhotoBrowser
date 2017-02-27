//
//  NPhoto.h
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NPhoto : NSObject

@property (nonatomic, strong, readonly) UIView *sourceView;
@property (nonatomic, strong, readonly) UIImage *thumbImage;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSURL *imageUrl;
@property (nonatomic, assign) BOOL finished;

- (instancetype)initWithSourceView:(UIView *)view thumbImage:(UIImage *)thumbImage imageUrl:(NSURL *)imageUrl;
+ (instancetype)photoWithSourceView:(UIView *)view thumbImage:(UIImage *)thumbImage imageUrl:(NSURL *)imageUrl;

- (instancetype)initWithSourceView:(UIImageView *)imageView imageUrl:(NSURL *)imageUrl;
+ (instancetype)photoWithSourceView:(UIImageView *)imageView imageUrl:(NSURL *)imageUrl;




@end
