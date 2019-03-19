//
//  PageView.m
//  UIPageViewController-SpineLocationMid
//
//  Created by lyn on 2019/3/18.
//  Copyright © 2019年 lyn. All rights reserved.
//

#import "CustomPageView.h"
#import "iCarousel.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface CustomPageView()<iCarouselDataSource,iCarouselDelegate>
@property (nonatomic,strong) UIImageView *firstImageView;
@property (nonatomic,strong) iCarousel *carouselView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@end
@implementation CustomPageView
- (UIImageView *) firstImageView{
    if (!_firstImageView) {
        _firstImageView = [UIImageView new];
        _firstImageView.frame = CGRectMake(0, 0, kScreenWidth * 0.5, kScreenHeight);
        _firstImageView.contentMode = self.contentMode;
    }
    return _firstImageView;
}
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        for (NSString *imageName in self.imageArray) {
            NSArray *imageArray = [self splitImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]]];
            [_dataSource addObjectsFromArray:imageArray];
        }
    }
    return _dataSource;
}
- (iCarousel *)carouselView{
    if (!_carouselView) {
        iCarousel *mainView = [iCarousel new];
        mainView.delegate = self;
        mainView.dataSource = self;
        mainView.scrollToItemBoundary = NO;
        mainView.stopAtItemBoundary = NO;
        mainView.bounces = NO;
        mainView.type = iCarouselTypeCustom;
        mainView.frame = self.bounds;
        mainView.pagingEnabled = YES;
        _carouselView = mainView;
    }
    return _carouselView;
}
+ (CustomPageView *)pageViewWithFrame:(CGRect)frame{
    CustomPageView *instance = [[self alloc] initWithFrame:frame];
    return instance;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:self.firstImageView];
    [self addSubview:self.carouselView];
}
/**
 * 图片切割：传一张图，从中间剪切成两张图片，返回图片数组
 */
- (NSArray<UIImage *>*)splitImage:(UIImage *)image{
    if (!image) {
        return nil;
    }
    
    CGRect leftRect = CGRectZero;
    CGRect rightRect = CGRectZero;
    CGFloat imageRatio = image.size.width / image.size.height;
    CGFloat screenRatio =  CGRectGetWidth(self.bounds) / CGRectGetHeight(self.bounds);
    
    if (self.contentMode == UIViewContentModeScaleAspectFit){
        CGFloat x = 0;
        CGFloat y = 0;
        if(imageRatio >= screenRatio){
            x = 0;
            y = (1.0/screenRatio * image.size.width-image.size.height) * 0.5;
            UIGraphicsBeginImageContext(CGSizeMake(image.size.width, 1.0/screenRatio * image.size.width));
            [[UIColor blackColor] setFill];
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, image.size.width, 1.0/screenRatio * image.size.width)];
            [path fill];
            [image drawInRect:CGRectMake(x, y, image.size.width,image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }else{
            x = (screenRatio * image.size.height - image.size.width)*0.5;
            y = 0;
            UIGraphicsBeginImageContext(CGSizeMake(screenRatio * image.size.height,image.size.height));
            [[UIColor blackColor] setFill];
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, screenRatio * image.size.height,image.size.height)];
            [path fill];
            [image drawInRect:CGRectMake(x, y, image.size.width,image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }else if (self.contentMode == UIViewContentModeScaleAspectFill){
        
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat ratio = MIN(width/self.bounds.size.width,height/self.bounds.size.height);
        CGFloat screenWidth = width * ratio;
        CGFloat screenHeight = height * ratio;
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(MAX(0,-(screenWidth - width)*0.5), MAX(0, -(screenHeight - height) * 0.5), width,height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    leftRect = CGRectMake(0, 0, image.size.width * 0.5, image.size.height);
    rightRect = CGRectMake(image.size.width*0.5, 0, image.size.width*0.5, image.size.height);
    CGImageRef leftImage =CGImageCreateWithImageInRect(image.CGImage, leftRect);
    CGImageRef rightImage =CGImageCreateWithImageInRect(image.CGImage, rightRect);
    UIImage *left = [UIImage imageWithCGImage:leftImage scale:image.scale orientation:image.imageOrientation];
    UIImage *right = [UIImage imageWithCGImage:rightImage scale:image.scale orientation:image.imageOrientation];
    return @[left,right];
}

#pragma mark- iCarousel Delegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return self.dataSource.count * 0.5;
}
- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    transform.m34=-3/2000;//透视效果
    double angle = 0;
    double translateZ = -1;
    NSArray *visibleViews = [carousel visibleItemViews];
    for (UIView *currentView in visibleViews) {
        CGFloat offset = [carousel offsetForItemAtIndex:[carousel indexOfItemView:currentView]];
        UIImageView *backImageView =  currentView.subviews[0];
        UIImageView *frontImageView =  currentView.subviews[1];
        if (offset > -0.5) {
            frontImageView.layer.zPosition = 1;
            backImageView.layer.zPosition = 0;
        }else{
            backImageView.layer.zPosition = 1;
            frontImageView.layer.zPosition = 0;
        }
    }
    if (offset >=-1 && offset <= 0) {
        angle = -M_PI * offset ;
        translateZ = offset;
        
    }else if(offset < -1){
        angle = -M_PI;
    }
    transform=CATransform3DRotate(CATransform3DTranslate(transform, 0, 0, cos(M_PI_2 / self.dataSource.count * 0.5 * offset * 0.001)),angle ,0,-1,0);
    return transform;
}
-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    carousel.userInteractionEnabled = YES;
}
-(void)carouselDidEndDecelerating:(iCarousel *)carousel{
    carousel.userInteractionEnabled = YES;
}
- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate{
    
    carousel.userInteractionEnabled = NO;
    if (!decelerate) {
        NSArray *visibleViews = [carousel visibleItemViews];
        for (UIView *view in visibleViews) {
            CGFloat offset = [carousel offsetForItemAtIndex:[carousel indexOfItemView:view]];
            if (-1<offset && offset <= -0.5) {
                [carousel scrollToItemAtIndex:[carousel indexOfItemView:view]+1 animated:YES];
            }else if (-0.5<offset && offset < 0){
                [carousel scrollToItemAtIndex:[carousel indexOfItemView:view] animated:YES];
            }else{
                carousel.userInteractionEnabled = YES;
            }
        }
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    //封面
    if (index == 0) {
        self.firstImageView.image = self.dataSource[index];
    }
    if (view == nil)
    {
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width * 0.5, self.bounds.size.height)];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *imageViewBack = [UIImageView new];
        imageViewBack.contentMode = self.contentMode;
        [view addSubview:imageViewBack];
        imageViewBack.frame = CGRectMake(0, 0, self.bounds.size.width * 0.5, self.bounds.size.height);
        
        if (index*2+2 != self.dataSource.count) {
            imageViewBack.image = self.dataSource[index*2+2];
        }else{
            imageViewBack.image = nil;
        }
        imageViewBack.layer.transform = CATransform3DRotate(imageViewBack.layer.transform, M_PI, 0, 1, 0);
        
        UIImageView *imageViewFront = [UIImageView new];
        imageViewFront.contentMode = self.contentMode;
        [view addSubview:imageViewFront];
        imageViewFront.frame = CGRectMake(-0.5, 0, self.bounds.size.width * 0.5+0.5, self.bounds.size.height);
        imageViewFront.image = self.dataSource[index*2+1];
        
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.superview.layer.anchorPoint = CGPointMake(0.0, 0.5);
    });
    
    return view;
}

@end
