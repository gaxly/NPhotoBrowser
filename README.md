# NPhotoBrowser
一个可上下滑动收回图片的图片浏览器


# 效果展示
![](http://wx4.sinaimg.cn/mw690/b9adaf5dgy1fd52esoif0g20ae0j4u11.gif)



# 使用

添加测试数据
```objc
    _urls = @[@"http://wx3.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9qucv9j20go0ciwfh.jpg",
              @"http://wx2.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9r1r62j20go0p0q4b.jpg",
              @"http://wx3.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9r73p5j20go0p0goa.jpg",
              @"http://wx3.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9rw2dsj20w40zkdlg.jpg",
              @"http://wx2.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9slqsij20go0m8tbn.jpg",
              @"http://wx4.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9th6s6j20zk0nodlw.jpg",
              @"http://wx4.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9ufjsfj20zk0qon2i.jpg",
              @"http://wx3.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9pzrbxj23402c0e83.jpg",
              @"http://wx4.sinaimg.cn/thumb150/b9adaf5dgy1fd0e9vfhclj20xh2klgqg.jpg"];
    
    CGFloat top = 64;
    CGFloat gap = 5;
    NSInteger count = 3;
    CGFloat width = (self.view.frame.size.width - gap * (count + 1)) / count;
    CGFloat height = width;
    _imageViews = @[].mutableCopy;
    for (int i = 0; i < _urls.count; i++) {
        CGFloat x = gap + (width + gap) * (i % count);
        CGFloat y = top + gap + (height + gap) * (i / count);
        CGRect rect = CGRectMake( x, y, width, height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.yy_imageURL = [NSURL URLWithString:_urls[i]];
        imageView.clipsToBounds = YES;
        imageView.tag = i;
        imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self.view addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:tap];
        [_imageViews addObject:imageView];
    }
```

点击查看图片
```objc
- (void)imageViewTapped:(UITapGestureRecognizer *)tap {
    NSMutableArray *photos = @[].mutableCopy;
    for (int i = 0; i < _imageViews.count; i++) {
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumb150" withString:@"mw690"];
        UIImageView *imageView = _imageViews[i];
        
        NPhoto *photo = [NPhoto photoWithSourceView:imageView imageUrl:[NSURL URLWithString:url]];
        [photos addObject:photo];
    }
    NPhotoBrowser *browser = [NPhotoBrowser browserWithPhoto:photos selectedIndex:tap.view.tag];
    [browser showFromViewController:self];
}
```

长按可保存图片
```objc
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
```
