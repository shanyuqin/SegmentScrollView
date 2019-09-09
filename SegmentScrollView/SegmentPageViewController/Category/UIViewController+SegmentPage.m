//
//  UIViewController+SegmentPage.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "UIViewController+SegmentPage.h"

@implementation UIViewController (SegmentPage)

- (void)clearFromParent {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
