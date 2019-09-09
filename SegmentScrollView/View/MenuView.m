//
//  MenuView.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "MenuView.h"
#import "MenuItemView.h"
#import "UIScrollView+SegmentPage.h"
@interface MenuView()

@property (nonatomic, strong) UIStackView * stackView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * progressView;
@property (nonatomic, strong) NSMutableArray<MenuItemView*> * menuItemViews;
@property (nonatomic, strong) UIFont * textFont;
@property (nonatomic, strong) UIColor * normalTextColor;
@property (nonatomic, strong) UIColor * selectedTextColor;
@property (nonatomic, strong) UIColor * progressColor;
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) CGFloat scrollRate;
@property (nonatomic, assign) CGFloat itemSpace;//两个titleLabel的centerX之间的距离
@property (nonatomic, assign) CGFloat widthDifference;
@property (nonatomic, assign) int nextIndex;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, strong) MenuItemView * currentLabel;
@property (nonatomic, strong) MenuItemView * nextLabel;

@end

@implementation MenuView


- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self defaultConfig];
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
        [self initialize];
    }
    return self;
}

- (void)defaultConfig {
    _progressView = [UIView new];
    _menuItemViews = [NSMutableArray new];
    _textFont = [UIFont systemFontOfSize:15];
    _normalTextColor = [UIColor darkGrayColor];
    _selectedTextColor = [UIColor redColor];
    _progressColor = [UIColor redColor];
    _progressHeight = 2.0;
    _progressView = [UIView new];
    _currentIndex = INT_MAX;//避免初始化时 因setCurrentIndex的初始值和设置值都为0 而return
}

- (void)initialize {
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(24.0);
        make.trailing.equalTo(self.mas_trailing).offset(-24.0);
        make.top.bottom.equalTo(self);
    }];
    
    
    self.stackView.spacing = 30.0;
    [self.scrollView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
    
    self.progressView.backgroundColor = self.progressColor;
    self.progressView.layer.cornerRadius = 1.0;
    [self.scrollView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(0));
        make.height.equalTo(@(self.progressHeight));
        make.centerX.equalTo(self.scrollView.mas_leading);
        make.bottom.equalTo(self.scrollView.mas_bottom);
    }];
    
}

- (void)clear {
    for (UIView *view in self.stackView.arrangedSubviews) {
        [view removeFromSuperview];
    }
    [self.menuItemViews removeAllObjects];
}

- (void)titleTapAction:(UITapGestureRecognizer *)tap {
    
    if (tap.view != nil) {
        NSInteger index = [self.stackView.arrangedSubviews indexOfObject:tap.view];
        [self.delegate menuView:self didSelectedItemAt:index];
    }
}

- (void)updateLayout:(UIScrollView *)externalScrollView {
    if (self.currentIndex < 0 || self.currentIndex >= self.titles.count) {
        return;
    }
    CGFloat scrollViewWidth = externalScrollView.bounds.size.width;
    CGFloat offsetX = externalScrollView.contentOffset.x;
    self.currentIndex = (int)(offsetX/scrollViewWidth);
    self.scrollRate = (offsetX - (CGFloat)(self.currentIndex)*scrollViewWidth)/(CGFloat)scrollViewWidth;
    CGFloat currentWidth = (self.stackView.arrangedSubviews[self.currentIndex]).bounds.size.width;
    CGFloat leadingMargin = CGRectGetMidX((self.stackView.arrangedSubviews[self.currentIndex]).frame);
    
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.widthDifference * self.scrollRate + currentWidth));
        make.centerX.equalTo(self.scrollView.mas_leading).offset(leadingMargin + self.itemSpace*self.scrollRate);
    }];
}

- (void)checkState {
    if (self.currentIndex < 0 || self.currentIndex >= self.titles.count || self.currentLabel == nil) {
        return;
    }
    for (MenuItemView *view in self.menuItemViews) {
        view.textColor = self.normalTextColor;
    }
    (self.menuItemViews[self.currentIndex]).textColor = self.selectedTextColor;
    [self.scrollView scrollToSuitable:self.currentLabel];
}


- (void)setScrollRate:(CGFloat)scrollRate {
    _scrollRate = scrollRate;
    self.currentLabel.rate = 1.0 - scrollRate;
    self.nextLabel.rate = self.scrollRate;
}

- (void)setTitles:(NSArray *)titles  {
    _titles = titles;
    for (UIView *view in self.stackView.arrangedSubviews) {
        [view removeFromSuperview];
    }
    [self.menuItemViews removeAllObjects];
    
    if (_titles.count<=0) {
        return;
    }
    
    for (NSString *str in _titles) {
        MenuItemView *item = [[MenuItemView alloc] initWithTextFont:self.textFont normalTextColor:self.normalTextColor selectedTextColor:self.selectedTextColor];
        item.text = str;
        item.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapAction:)];
        [item addGestureRecognizer:tap];
        [self.stackView addArrangedSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.stackView.mas_height);
        }];
        [self.menuItemViews addObject:item];
    }
    self.currentIndex = 0;
    [self.stackView layoutIfNeeded];
    CGFloat labelWidth = self.stackView.arrangedSubviews.firstObject.bounds.size.width  ?: 0.0;
    CGFloat offset = CGRectGetMidX(self.stackView.arrangedSubviews.firstObject.frame) ?: 0.0;
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(labelWidth));
        make.centerX.equalTo(self.scrollView.mas_leading).offset(offset);
    }];
    [self checkState];
    
}

- (CGFloat)itemSpace {
    if (self.currentLabel == nil || self.nextLabel == nil) {
        return 0.0;
    }
    return CGRectGetMinX(self.nextLabel.frame) - CGRectGetMidX(self.currentLabel.frame) + self.nextLabel.bounds.size.width * 0.5;
}

- (CGFloat)widthDifference {
    if (self.currentLabel == nil || self.nextLabel == nil) {
        return 0.0;
    }
    return self.nextLabel.bounds.size.width - self.currentLabel.bounds.size.width;
}

- (void)setNextIndex:(int)nextIndex {
    
    if (nextIndex >= self.titles.count || nextIndex < 0 || _nextIndex == nextIndex) {
        return;
    }
    
    _nextIndex = nextIndex;
    self.nextLabel = self.menuItemViews[_nextIndex];
}

- (void)setCurrentIndex:(int)currentIndex {
    if (currentIndex >= self.titles.count || currentIndex < 0 || _currentIndex == currentIndex) {
        return;
    }
    _currentIndex = currentIndex;
    self.nextIndex = _currentIndex + 1;
    self.currentLabel = self.menuItemViews[_currentIndex];
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [UIStackView new];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
    }
    return _stackView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.scrollsToTop = false;
        _scrollView.clipsToBounds = false;
    }
    return _scrollView;
}

- (NSMutableArray<MenuItemView *> *)menuItemViews {
    if (!_menuItemViews) {
        _menuItemViews = [NSMutableArray new];
    }
    return _menuItemViews;
}
@end
