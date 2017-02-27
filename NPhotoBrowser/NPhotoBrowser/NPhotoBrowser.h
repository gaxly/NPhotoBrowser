//
//  NPhotoBrowser.h
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPhoto.h"

@interface NPhotoBrowser : UIViewController

+ (instancetype)browserWithPhoto:(NSArray<NPhoto *> *)photo selectedIndex:(NSUInteger)selectedIndex;

- (instancetype)initWithPhoto:(NSArray<NPhoto *> *)photo selectedIndex:(NSUInteger)selectedindex;

- (void)showFromViewController:(UIViewController *)vc;

@end
