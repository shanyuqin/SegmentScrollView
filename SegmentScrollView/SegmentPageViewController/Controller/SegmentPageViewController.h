//
//  SegmentPageViewController.h
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@class SegmentPageViewController;
@class SegmentPageChildViewController;

@protocol SegmentPageChildViewController <NSObject>

- (UIScrollView *)childScrollView;

@end

@protocol SegmentPageViewControllerDataSource <NSObject>

// question : swift 的返回类型 -> (UIViewController & AquamanChildViewController)  是什么意思？
@required

- (UIViewController<SegmentPageChildViewController> *)segmentPageController:(SegmentPageViewController *)segmentPageController viewControllerAt:(NSInteger)index;

- (UIView *)headerViewFor:(SegmentPageViewController *)segmentPageController;

- (NSInteger)numberOfViewControllersIn:(SegmentPageViewController *)segmentPageController;

- (CGFloat)headerViewHeightFor:(SegmentPageViewController *)segmentPageController;

- (UIView *)menuViewFor:(SegmentPageViewController *)segmentPageController;

- (CGFloat)menuViewHeightFor:(SegmentPageViewController *)segmentPageController;

- (CGFloat)menuViewPinHeightFor:(SegmentPageViewController *)segmentPageController;

- (NSInteger)originIndexFor:(SegmentPageViewController *)segmentPageController;

@end
@protocol SegmentPageViewControllerDelegate <NSObject>


/// Any offset changes in pageController's mainScrollView
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController mainScrollViewDidScroll:(UIScrollView *)scrollView;

/// Method call when contentScrollView did end scroll
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController contentScrollViewDidEndScroll:(UIScrollView *)scrollView;

/// Any offset changes in pageController's contentScrollView
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController contentScrollViewDidScroll:(UIScrollView *)scrollView;

/// Method call when viewController will cache
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController willCache:(UIViewController<SegmentPageChildViewController> *)viewController forItemAt:(NSInteger)index;

/// Method call when viewController will display
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController willDisplay:(UIViewController<SegmentPageChildViewController> *)viewController forItemAt:(NSInteger)index;

/// Method call when viewController did display
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController didDisplay:(UIViewController<SegmentPageChildViewController> *)viewController forItemAt:(NSInteger)index;

/// Method call when menuView is adsorption(吸附)
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController  menuView:(BOOL)isAdsorption;

@end

@interface SegmentPageViewController : UIViewController<SegmentPageViewControllerDataSource,SegmentPageViewControllerDelegate>

@property (nonatomic, strong) MainScrollView * mainScrollView;

- (void)setSelect:(NSInteger)index animation:(BOOL)animation;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END

