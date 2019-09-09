//
//  MainScrollView.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "MainScrollView.h"

@implementation MainScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.view && [gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        
        UIScrollView *scrollView = (UIScrollView *)gestureRecognizer.view;
        CGFloat offsetY = self.headerViewHeight + self.menuViewHeight;
        CGSize contentSize = scrollView.contentSize;
        CGRect targetRect = CGRectMake(0,
                                       offsetY - [UIApplication sharedApplication].statusBarFrame.size.height,
                                       contentSize.width,
                                       contentSize.height - offsetY);
        CGPoint currentPoint = [gestureRecognizer locationInView:self];
        return CGRectContainsPoint(targetRect, currentPoint);
        
    }
    return NO;
    
}

@end
