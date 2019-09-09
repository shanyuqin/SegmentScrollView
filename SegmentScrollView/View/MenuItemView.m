//
//  MenuItemView.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "MenuItemView.h"

@interface RGBAColorComment : NSObject

@property (nonatomic, assign) CGFloat r;
@property (nonatomic, assign) CGFloat g;
@property (nonatomic, assign) CGFloat b;
@property (nonatomic, assign) CGFloat a;

@property (nonatomic, strong) UIColor * color;

@end

@implementation RGBAColorComment

- (void)setColor:(UIColor *)color {
    _color = color;
    [color getRed:&_r green:&_g blue:&_b alpha:&_a];
}

@end


@interface MenuItemView ()

@property (nonatomic, strong) RGBAColorComment * normalColors;
@property (nonatomic, strong) RGBAColorComment * selectedColors;

@end

@implementation MenuItemView


- (void)setRate:(CGFloat)rate {
    _rate = rate;
    
    if (_rate<=0 || _rate>=1.0) {
        return;
    }
    
    CGFloat r = self.normalColors.r + (self.selectedColors.r - self.normalColors.r)*rate;
    CGFloat g = self.normalColors.g + (self.selectedColors.g - self.normalColors.g)*rate;
    CGFloat b = self.normalColors.b + (self.selectedColors.b - self.normalColors.b)*rate;
    CGFloat a = self.normalColors.a + (self.selectedColors.a - self.normalColors.a)*rate;
    self.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (instancetype)initWithTextFont:(UIFont *)font normalTextColor:(UIColor *)normalTextColor selectedTextColor:(UIColor *)selectedTextColor
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.font = font;
        self.normalColors.color = normalTextColor;
        self.selectedColors.color = selectedTextColor;
    }
    return self;
}

- (RGBAColorComment *)normalColors {
    if (!_normalColors) {
        _normalColors = [RGBAColorComment new];
    }
    return _normalColors;
}
- (RGBAColorComment *)selectedColors {
    if (!_selectedColors) {
        _selectedColors = [RGBAColorComment new];
    }
    return _selectedColors;
}


@end
