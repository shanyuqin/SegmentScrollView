//
//  ContainView.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "ContainView.h"

@implementation ContainView

- (BOOL)isEmpty {
    return self.subviews.count == 0;
}

- (BOOL)displayingIn:(UIView *)view containView:(UIView *)containView {
    CGRect convertedFrame = [containView convertRect:self.frame toView:view];
    return CGRectIntersectsRect(view.frame, convertedFrame);
}

@end
