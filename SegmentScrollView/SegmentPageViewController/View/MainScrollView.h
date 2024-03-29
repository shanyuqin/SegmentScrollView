//
//  MainScrollView.h
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat menuViewHeight;

@end

NS_ASSUME_NONNULL_END
