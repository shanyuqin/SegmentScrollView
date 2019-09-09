//
//  UIScrollView+SegmentPage.h
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SegmentPage)
@property (nonatomic, assign) BOOL segPage_isCanScroll;


/**
 MenuView 滑到后边的item时希望menuView的位置能够适配当前的屏幕位置。
 */
- (void)scrollToSuitable:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
