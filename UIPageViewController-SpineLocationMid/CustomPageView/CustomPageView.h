//
//  CustomPageView.h
//  UIPageViewController-SpineLocationMid
//
//  Created by lyn on 2019/3/18.
//  Copyright © 2019年 lyn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomPageView : UIView
@property (nonatomic,strong) NSArray *imageArray;
/*
 UIViewContentModeScaleToFill,拉伸适配
 UIViewContentModeScaleAspectFit, 缩放图片使得整张图片显示，但保持图片宽高比例
 UIViewContentModeScaleAspectFill, 缩放图片保持图片宽高比例，超出部分会被裁剪
 */
@property (nonatomic,assign) UIViewContentMode contentMode;
+ (CustomPageView *)pageViewWithFrame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
