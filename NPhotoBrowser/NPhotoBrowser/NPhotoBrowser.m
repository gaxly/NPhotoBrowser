//
//  NPhotoBrowser.m
//  NPhotoBrowser
//
//  Created by gaxly on 2017/1/7.
//  Copyright © 2017年 gaxly. All rights reserved.
//

#import "NPhotoBrowser.h"
#import "NPhotoView.h"
#import <YYWebImage/YYWebImage.h>

static const NSTimeInterval animationDuration = 0.3;
//static const NSTimeInterval springAnimationDuration = 0.5;

@interface NPhotoBrowser () <UIScrollViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate>
{
    CGPoint _startLocation;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableSet *reusableViews;
@property (nonatomic, strong) NSMutableArray *visibleViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, assign) BOOL presented;

@end

@implementation NPhotoBrowser

+ (instancetype)browserWithPhoto:(NSArray<NPhoto *> *)photo selectedIndex:(NSUInteger)selectedIndex {
    return [[self alloc] initWithPhoto:photo selectedIndex:selectedIndex];
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithMediaItems: instead.");
    return nil;
}

- (instancetype)initWithPhoto:(NSArray<NPhoto *> *)photo selectedIndex:(NSUInteger)selectedindex {
    if (self = [super init]) {
        _photos = [NSMutableArray arrayWithArray:photo];
        _currentPage = selectedindex;
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _reusableViews = [[NSMutableSet alloc] init];
        _visibleViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.alpha = 0.0;
    [self.view addSubview:_backgroundView];

    CGRect rect = self.view.bounds;
    rect.origin.x -= photoViewPadding;
    rect.size.width += 2 * photoViewPadding;
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 20)];
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.font = [UIFont systemFontOfSize:16.0];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    [self setupPageLabelWithCurrentPage:_currentPage];
    [self.view addSubview:_pageLabel];

    CGSize contentSize = CGSizeMake(rect.size.width * _photos.count, rect.size.height);
    _scrollView.contentSize = contentSize;
    
    [self addGestureRecongnizer];
    
    CGPoint contentOffset = CGPointMake(_scrollView.frame.size.width * _currentPage, 0);
    [_scrollView setContentOffset:contentOffset animated:NO];
    if (contentOffset.x == 0) {
        [self scrollViewDidScroll:_scrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NPhoto *photo = [_photos objectAtIndex:_currentPage];
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:photo.imageUrl];
    if ([manager.cache getImageForKey:key withType:YYImageCacheTypeMemory]) {
        [self configPhotoView:photoView withPhoto:photo];
    } else {
        photoView.imageView.image = photo.thumbImage;
        [photoView resizeImageView];
    }
    
    CGRect endRect = photoView.imageView.frame;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [photo.sourceView.superview convertRect:photo.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [photo.sourceView.superview convertRect:photo.sourceView.frame toView:photoView];
    }
    photoView.imageView.frame = sourceRect;
    
    [UIView animateWithDuration:animationDuration animations:^{
        photoView.imageView.frame = endRect;
        self.view.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        [self configPhotoView:photoView withPhoto:photo];
        _presented = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self setNeedsStatusBarAppearanceUpdate];
        
    }];
}


#pragma mark - StatusBar change

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
//
//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
//    return UIStatusBarAnimationFade;
//}


#pragma mark - Public

- (void)showFromViewController:(UIViewController *)vc {
    [vc presentViewController:self animated:NO completion:nil];
}

#pragma mark - Private

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (NPhotoView *)photoViewForCurrentPage:(NSUInteger)currentPage {
    for (NPhotoView *photoView in _visibleViews) {
        if (photoView.tag == currentPage) {
            return photoView;
        }
    }
    return nil;
}

- (NPhotoView *)dequeueReusableView {
    NPhotoView *photoView = [_reusableViews anyObject];
    if (photoView == nil) {
        photoView = [[NPhotoView alloc] initWithFrame:_scrollView.bounds];
    } else {
        [_reusableViews removeObject:photoView];
    }
    photoView.tag = -1;
    return photoView;
}

- (void)updatetReusableView {
    NSMutableArray *photosForRemove = @[].mutableCopy;
    for (NPhotoView *photoView in _visibleViews) {
        if (photoView.frame.origin.x + photoView.frame.size.width < _scrollView.contentOffset.x - _scrollView.frame.size.width || photoView.frame.origin.x > _scrollView.contentOffset.x + 2 *_scrollView.frame.size.width) {
            [photoView removeFromSuperview];
            [self configPhotoView:photoView withPhoto:nil];
            [photosForRemove addObject:photoView];
            [_reusableViews addObject:photoView];
        }
    }
    [_visibleViews removeObjectsInArray:photosForRemove];
}

- (void)configPhotoViews {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i < 0 || i >= _photos.count) {
            continue;
        }
        NPhotoView *photoView = [self photoViewForCurrentPage:i];
        if (photoView == nil) {
            photoView = [self dequeueReusableView];
            CGRect rect = _scrollView.bounds;
            rect.origin.x = i * _scrollView.bounds.size.width;
            photoView.frame = rect;
            photoView.tag = i;
            [_scrollView addSubview:photoView];
            [_visibleViews addObject:photoView];
        }
        if (photoView.photo == nil && _presented) {
            NPhoto *photo = [_photos objectAtIndex:i];
            [self configPhotoView:photoView withPhoto:photo];
        }
    }
    
    if (page != _currentPage && _presented) {
        _currentPage = page;
        [self setupPageLabelWithCurrentPage:_currentPage];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    for (NPhotoView *photoView in _visibleViews) {
        [photoView cancelCurrentImageLoad];
    }
    NPhoto *photo = [_photos objectAtIndex:_currentPage];
    if (animated) {
        [UIView animateWithDuration:animationDuration animations:^{
            photo.sourceView.alpha = 1;
        }];
    } else {
        photo.sourceView.alpha = 1;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}



- (void)preformSliderWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSliderCompletionAnimationFromPoint:point];
            } else {
                [self showCancelLocationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)showSliderCompletionAnimationFromPoint:(CGPoint)point {
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = -self.view.frame.size.height;
    } else {
        toTranslationY = self.view.frame.size.height;
    }
    [UIView animateWithDuration:animationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:YES];
    }];
}

- (void)showDismissAnimation {
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    NPhoto *photo = [_photos objectAtIndex:_currentPage];
    [photoView cancelCurrentImageLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    photoView.progressLayer.hidden = YES;
    photo.sourceView.alpha = 0;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [photo.sourceView.superview convertRect:photo.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [photo.sourceView.superview convertRect:photo.sourceView.frame toView:photoView];
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        photoView.imageView.frame = sourceRect;
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:NO];
    }];
}


/**
 图片收回动画
 */
- (void)showCancelLocationAnimation {
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    NPhoto *photo = [_photos objectAtIndex:_currentPage];
    photo.sourceView.alpha = 1;
    if (!photo.finished) {
        photoView.progressLayer.hidden = NO;
    }

        [UIView animateWithDuration:animationDuration animations:^{
            photoView.imageView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            [self configPhotoView:photoView withPhoto:photo];
        }];
}

- (void)handlePanBegin {
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    NPhoto *photo = [_photos objectAtIndex:_currentPage];
    [UIApplication sharedApplication].statusBarHidden = NO;
    photoView.progressLayer.hidden = YES;
    photo.sourceView.alpha = 0;
}

- (void)setupPageLabelWithCurrentPage:(NSUInteger)currentPage {
    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",currentPage+1,_photos.count];
}


- (void)configPhotoView:(NPhotoView *)photoView withPhoto:(NPhoto *)photo {
    [photoView setPhoto:photo determinate:YES];
}



#pragma mark - 添加图片点击收手势

- (void)addGestureRecongnizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
}


/**
 双击图片变大变小
 */
- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    NPhoto *photo = [_photos objectAtIndex:_currentPage];
    if (!photo.finished) {
        return;
    }
    if (photoView.zoomScale > 1) {
        [photoView setZoomScale:1 animated:YES];
    } else {
        CGPoint location = [tap locationInView:self.view];
        CGFloat maxZoomScale = photoView.maximumZoomScale;
        CGFloat width = self.view.bounds.size.width / maxZoomScale;
        CGFloat height = self.view.bounds.size.height / maxZoomScale;
        [photoView zoomToRect:CGRectMake(location.x - width/2, location.y - height/2, width, height) animated:YES];
    }
}


/**
 单击收回图片
 */
- (void)didSingleTap:(UITapGestureRecognizer *)tap {
    [self showDismissAnimation];
}


/**
 长按分享图片
 */
- (void)didLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    UIImage *image = photoView.imageView.image;
    if (!image) {
        return;
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


/**
 长按拖动图片
 */
- (void)didPan:(UIPanGestureRecognizer *)pan {
    NPhotoView *photoView = [self photoViewForCurrentPage:_currentPage];
    if (photoView.zoomScale > 1.1) {
        return;
    }
    [self preformSliderWithPan:pan];
}


#pragma mark - Animation Delegate

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
//        [self dismissAnimated:YES];
//    }
//}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatetReusableView];
    [self configPhotoViews];
}



@end
