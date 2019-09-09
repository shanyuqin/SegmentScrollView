//
//  ContainView.h
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentPageChildViewController;

NS_ASSUME_NONNULL_BEGIN

@interface ContainView : UIView

@property (nonatomic, weak) UIViewController<SegmentPageChildViewController> * viewController;

@property (nonatomic, assign) BOOL isEmpty;

- (BOOL)displayingIn:(UIView *)view containView:(UIView *)containView;
@end

NS_ASSUME_NONNULL_END
