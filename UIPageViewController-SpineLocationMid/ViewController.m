//
//  ViewController.m
//  UIPageViewController-SpineLocationMid
//
//  Created by lyn on 2019/3/15.
//  Copyright © 2019年 lyn. All rights reserved.
//

#import "ViewController.h"
#import "CustomPageView.h"
@interface ViewController ()
@property (nonatomic,strong) CustomPageView *pageView;
@property (nonatomic,strong) NSArray *imageArray;
@end

@implementation ViewController
- (NSArray *)imageArray{
    if (!_imageArray) {
        _imageArray = @[@"1_book_picture.jpg",@"2_book_picture.jpg",@"3_book_picture.jpg",@"4_book_picture.jpg"];
    }
    return _imageArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageView = [CustomPageView pageViewWithFrame:self.view.bounds];
    self.pageView.contentMode = UIViewContentModeScaleAspectFit;
    self.pageView.imageArray = self.imageArray;
    [self.view addSubview:self.pageView];
}


@end
