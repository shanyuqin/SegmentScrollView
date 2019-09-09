//
//  SegmentPageViewController.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "SegmentPageViewController.h"
#import "MainScrollView.h"
#import "UIScrollView+SegmentPage.h"
#import "UIViewController+SegmentPage.h"
#import "ContainView.h"


@interface SegmentPageViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger originIndex;
@property (nonatomic, strong) UIScrollView * contentScrollView;
@property (nonatomic, strong) UIStackView * contentStackView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) UIView * headerContentView;
@property (nonatomic, strong) UIView * menuContentView;
@property (nonatomic, assign) CGFloat menuViewHeight;
@property (nonatomic, assign) CGFloat menuViewPinHeight;
@property (nonatomic, assign) CGFloat sillValue;
@property (nonatomic, assign) NSInteger childControllerCount;
@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIView * menuView;
@property (nonatomic, strong) NSMutableArray<ContainView *> * containViews;
@property (nonatomic, strong) UIScrollView * currentChildScrollView;
@property (nonatomic, strong) NSArray * childScrollViews;
@property (nonatomic, strong) NSCache<NSString*, UIViewController<SegmentPageChildViewController>*> * memoryCache;
@property (nonatomic, strong) UIViewController<SegmentPageChildViewController> * _Nullable currentViewController;
@property (nonatomic, weak) id<SegmentPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<SegmentPageViewControllerDelegate> delegate;

@property (nonatomic, strong) UIScrollView * observerScrollView;

@end

@implementation SegmentPageViewController

#pragma mark - init -

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = self;
        _delegate = self;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dataSource = self;
        _delegate = self;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSource = self;
        _delegate = self;
    }
    return self;
}

#pragma mark - lifeCycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self obtainDataSource];
    [self setupOriginContent];
    [self setupDataSource];
    [self.view layoutIfNeeded];
    if (self.originIndex > 0) {
        [self setSelect:self.originIndex animation:NO];
    }else {
        [self showChildViewContollerAt:self.originIndex];
        [self didDisplayViewControllerAt:self.originIndex];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.mainScrollView.scrollEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.mainScrollView.scrollEnabled = NO;
}

- (void)dealloc {
    [self.observerScrollView removeObserver:self forKeyPath:@"contentOffset"];
}
#pragma mark - private method -

- (void)obtainDataSource {
    self.originIndex = [self originIndexFor:self];
    
    self.headerView = [self headerViewFor:self];
    self.headerViewHeight = [self headerViewHeightFor:self];
    
    self.menuView = [self menuViewFor:self];
    self.menuViewHeight = [self menuViewHeightFor:self];
    self.menuViewPinHeight = [self menuViewPinHeightFor:self];
    
    self.childControllerCount = [self numberOfViewControllersIn:self];
    self.sillValue = self.headerViewHeight - self.menuViewPinHeight;
}

- (void)setupOriginContent {
    self.mainScrollView.headerViewHeight = self.headerViewHeight;
    self.mainScrollView.menuViewHeight = self.menuViewHeight;
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.trailing.equalTo(self.view);
    }];
    
    [self.mainScrollView addSubview:self.headerContentView];
    self.headerContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.mainScrollView);
        make.height.equalTo(@(self.headerViewHeight));
    }];
    
    [self.mainScrollView addSubview:self.menuContentView];
    self.menuContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.menuContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.width.equalTo(self.mainScrollView);
        make.height.equalTo(@(self.menuViewHeight));
        make.top.equalTo(self.headerContentView.mas_bottom);
    }];
    
    [self.mainScrollView addSubview:self.contentScrollView];
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.width.equalTo(self.mainScrollView);
        make.top.equalTo(self.menuContentView.mas_bottom);
        make.height.equalTo(self.mainScrollView.mas_height).offset(-self.menuViewHeight - self.menuViewPinHeight);
    }];
    
    [self.contentScrollView addSubview:self.contentStackView];
    [self.contentStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.height.equalTo(self.contentScrollView);
    }];
}

- (void)updateOriginContent {
    self.mainScrollView.headerViewHeight = self.headerViewHeight;
    self.mainScrollView.menuViewHeight = self.menuViewHeight;
    [self.headerContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.headerViewHeight));
    }];
    
    [self.contentScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mainScrollView.mas_height).offset(-self.menuViewHeight - self.menuViewPinHeight);
    }];
}

- (void)clear {
    self.originIndex = 0;
    
    self.mainScrollView.segPage_isCanScroll = YES;
    
    self.childControllerCount = 0;
    
    self.currentViewController = nil;
    self.currentChildScrollView = nil;
    [self.headerView removeFromSuperview];
    [self.contentScrollView setContentOffset:CGPointZero animated:NO];
    
    for (UIView *view in self.contentStackView.subviews) {
        [view removeFromSuperview];
    }
    [self.containViews removeAllObjects];
    [self.memoryCache removeAllObjects];
    
    for (ContainView * view in self.containViews) {
        [view.viewController clearFromParent];
    }
}


- (void)setupDataSource {
    self.memoryCache.countLimit = self.childControllerCount;
    if (self.headerView) {
        [self.headerContentView addSubview:self.headerView];
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.headerContentView);
        }];
    }
    
    if (self.menuView) {
        [self.menuContentView addSubview:self.menuView];
        self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.leading.trailing.top.bottom.equalTo(self.menuContentView);
        }];
    }
    
    
    for (int i = 0; i < self.childControllerCount; i++) {
        ContainView *containView = [ContainView new];
        
        containView.backgroundColor = [UIColor colorWithRed:(arc4random()%256)/255.0 green:(arc4random()%256)/255.0 blue:(arc4random()%256)/255.0 alpha:1];
        [self.contentStackView addArrangedSubview:containView];
        [containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(self.contentScrollView);
        }];
        [self.containViews addObject:containView];
    }
    
  
    
}

- (void)showChildViewContollerAt:(NSInteger)index {
    if (self.childControllerCount <= 0 ||
        index < 0 ||
        index >= self.childControllerCount ||
        self.containViews.count == 0) {
        return;
    }
    ContainView *containView = self.containViews[index];
    if (!containView.isEmpty) {
        return;
    }
    
    UIViewController<SegmentPageChildViewController> * cachedViewContoller = [self.memoryCache objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    UIViewController<SegmentPageChildViewController> * targetViewController = cachedViewContoller != nil ? cachedViewContoller : [self segmentPageController:self viewControllerAt:index];
    
    if (targetViewController == nil) {
        return;
    }
    
    
    [self segmentPageViewController:self willDisplay:targetViewController forItemAt:index];
    
    [self addChildViewController:targetViewController];
    [containView addSubview:targetViewController.view];
    targetViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [targetViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(containView);
    }];
    [targetViewController didMoveToParentViewController:self];
    containView.viewController = targetViewController;
    
    UIScrollView *scrollView = targetViewController.childScrollView;
    if (self.mainScrollView.contentOffset.y<self.sillValue) {
        [scrollView setContentOffset:CGPointZero animated:NO];
        scrollView.segPage_isCanScroll = NO;
        self.mainScrollView.segPage_isCanScroll = YES;
    }
    
        
    [self.observerScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    self.observerScrollView = scrollView;
}

- (void)didDisplayViewControllerAt:(NSInteger)index {
    if (self.childControllerCount <= 0 ||
        index < 0 ||
        index >= self.childControllerCount ||
        self.containViews.count == 0) {
        return;
    }
    ContainView * containView = self.containViews[index];
    self.currentViewController = containView.viewController;
    self.currentChildScrollView = self.currentViewController.childScrollView;
    self.currentIndex = index;
    UIViewController<SegmentPageChildViewController> *vc = containView.viewController;
    if (vc) {
        [self segmentPageViewController:self didDisplay:vc forItemAt:index];
    }
}

- (void)removeChildViewControllerAt:(NSInteger)index {
    if (self.childControllerCount <= 0 ||
        index < 0 ||
        index >= self.childControllerCount ||
        self.containViews.count == 0) {
        return;
    }
    
    ContainView *containView = self.containViews[index];
    if (containView.isEmpty || containView.viewController == nil) {
        return;
    }
    [containView.viewController clearFromParent];
    if ([self.memoryCache objectForKey:[NSString stringWithFormat:@"%ld",(long)index]] == nil) {
        [self segmentPageViewController:self willCache:containView.viewController forItemAt:index];
        [self.memoryCache setObject:containView.viewController forKey:[NSString stringWithFormat:@"%ld",(long)index]];
    }

}

- (void)layoutChildViewControlls {
    
    for (int index = 0; index < self.childControllerCount; index++) {
        ContainView *containView = self.containViews[index];
        BOOL isDisplaying = [containView displayingIn:self.view containView:self.contentScrollView];
        if (isDisplaying) {
            [self showChildViewContollerAt:index];
        }else {
            [self removeChildViewControllerAt:index];
        }
    }
}

- (void)contentScrollViewDidEndScroll:(UIScrollView *)scrollView {
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    if (scrollViewWidth <= 0)
        return;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    int index = (int)offsetX/scrollViewWidth;
    [self didDisplayViewControllerAt:index];
    [self segmentPageViewController:self contentScrollViewDidEndScroll:self.contentScrollView];
    
}

- (void)childScrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.segPage_isCanScroll == NO) {
        scrollView.contentOffset = CGPointZero;
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        scrollView.contentOffset = CGPointZero;
        scrollView.segPage_isCanScroll = NO;
        self.mainScrollView.segPage_isCanScroll = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[UIScrollView class]]) {
        
        CGPoint newPoint=[((NSValue *)[change  valueForKey:@"new"]) CGPointValue];
        CGPoint oldPoint=[((NSValue *)[change  valueForKey:@"old"]) CGPointValue];
        

        if (newPoint.y != oldPoint.y) {
            [self childScrollViewDidScroll:(UIScrollView *)object];
        }
    }
}

#pragma mark - public method -

- (void)setSelect:(NSInteger)index animation:(BOOL)animation {
    CGPoint offset = CGPointMake(self.contentScrollView.frame.size.width * index, self.contentScrollView.contentOffset.y);
    [self.contentScrollView setContentOffset:offset animated:animation];
    if (animation == NO) {
        [self contentScrollViewDidEndScroll:self.contentScrollView];
    }
}

- (void)reloadData {
    self.mainScrollView.userInteractionEnabled = NO;
    [self clear];
    [self obtainDataSource];
    [self updateOriginContent];
    [self setupDataSource];
    [self.view layoutIfNeeded];
    if (self.originIndex > 0) {
        [self setSelect:self.originIndex animation:NO];
    }else {
        [self showChildViewContollerAt:self.originIndex];
        [self didDisplayViewControllerAt:self.originIndex];
    }
    self.mainScrollView.userInteractionEnabled = YES;
}

#pragma mark - SegmentPageViewControllerDelegate -
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController mainScrollViewDidScroll:(UIScrollView *)scrollView {}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController contentScrollViewDidEndScroll:(UIScrollView *)scrollView {}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController contentScrollViewDidScroll:(UIScrollView *)scrollView {}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController willCache:(UIViewController<SegmentPageChildViewController> *)viewController forItemAt:(NSInteger)index {}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController willDisplay:(UIViewController<SegmentPageChildViewController> *)viewController forItemAt:(NSInteger)index {}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController didDisplay:(UIViewController<SegmentPageChildViewController> *)viewController forItemAt:(NSInteger)index {}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController  menuView:(BOOL)isAdsorption {}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        [self segmentPageViewController:self mainScrollViewDidScroll:scrollView];
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY >= self.sillValue) {
            scrollView.contentOffset = CGPointMake(0, self.sillValue);
            self.currentChildScrollView.segPage_isCanScroll = YES;
            scrollView.segPage_isCanScroll = NO;
            [self segmentPageViewController:self menuView:!scrollView.segPage_isCanScroll];
        }else {
            if (scrollView.segPage_isCanScroll == NO) {
                [self segmentPageViewController:self menuView:YES];
                scrollView.contentOffset = CGPointMake(0, self.sillValue);
            }else {
                [self segmentPageViewController:self menuView:NO];
            }
        }
    }else {
        [self segmentPageViewController:self contentScrollViewDidScroll:scrollView];
        [self layoutChildViewControlls];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        self.mainScrollView.scrollEnabled = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.contentScrollView) {
        self.mainScrollView.scrollEnabled = YES;
        if (decelerate == NO) {
            [self contentScrollViewDidEndScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        [self contentScrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        [self contentScrollViewDidEndScroll:scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        [self.currentChildScrollView setContentOffset:CGPointZero animated:YES];
        return true;
    }
    return NO;
}

#pragma mark - lazy load -

- (MainScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[MainScrollView alloc] init];
        _mainScrollView.delegate = self;
        _mainScrollView.segPage_isCanScroll = YES;
        _mainScrollView.scrollsToTop = YES;
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _mainScrollView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.delegate = self;
        _contentScrollView.bounces = NO;
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.scrollsToTop = YES;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        UIGestureRecognizer *popGesture = self.navigationController.interactivePopGestureRecognizer;
        [_contentScrollView.panGestureRecognizer requireGestureRecognizerToFail:popGesture];
    }
    return _contentScrollView;
}


- (UIStackView *)contentStackView {
    if (!_contentStackView) {
        _contentStackView = [[UIStackView alloc] init];
        _contentStackView.alignment = UIStackViewAlignmentFill;
        _contentStackView.distribution = UIStackViewDistributionFillEqually;
        _contentStackView.axis = UILayoutConstraintAxisHorizontal;
        _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentStackView;
}

- (UIView *)menuContentView {
    if (!_menuContentView) {
        _menuContentView = [UIView new];
    }
    return _menuContentView;
}

- (UIView *)headerContentView {
    if (!_headerContentView) {
        _headerContentView = [UIView new];
    }
    return _headerContentView;
}

- (NSMutableArray<ContainView *> *)containViews {
    if (!_containViews) {
        _containViews = [NSMutableArray array];
    }
    return _containViews;
}
@end
