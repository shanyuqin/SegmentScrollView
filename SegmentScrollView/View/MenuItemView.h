//
//  MenuItemView.h
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuItemView : UILabel

@property (nonatomic, assign) CGFloat rate;
- (instancetype)initWithTextFont:(UIFont *)font normalTextColor:(UIColor *)normalTextColor selectedTextColor:(UIColor *)selectedTextColor;
@end

NS_ASSUME_NONNULL_END
