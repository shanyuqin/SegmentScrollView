//
//  TestSegPageViewController.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "TestSegPageViewController.h"
#import "MJRefresh.h"
#import "MenuView.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface TestSegPageViewController ()<MenuViewDelegate>

@property (nonatomic, strong) UIView * navBar;
@property (nonatomic, strong) MenuView * menuView;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat menuViewHeight;

@end

@implementation TestSegPageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.headerViewHeight = 200;
        self.menuViewHeight = 44;
        self.count = 3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0,*)) {
        self.mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navBar = [UIView new];
    self.navBar.alpha = 0.0;
    self.navBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view);
        make.height.equalTo(@([UIApplication sharedApplication].statusBarFrame.size.height+44));
    }];
    
    self.menuView.titles = @[@"Superman",@"Batman",@"Wonder Woman"];
    self.count = self.menuView.titles.count;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(updateData)];
    self.mainScrollView.mj_header = header;
    self.menuView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)updateData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.menuView.titles = @[@"superman",@"batman",@"wonder woman",@"iron man"];
        self.count = self.menuView.titles.count;
        self.headerViewHeight = 120;
        self.menuViewHeight = 50;
        [self reloadData];
        [self setSelect:2 animation:NO];
        if (self.mainScrollView.mj_header.isRefreshing) {
            [self.mainScrollView.mj_header endRefreshing];
        }
    });
    
    
}


- (MenuView *)menuView {
    if (!_menuView) {
        _menuView = [[MenuView alloc] init];
    }
    return _menuView;
}

- (void)menuView:(MenuView *)menuView didSelectedItemAt:(NSInteger)index {
    if (index >= self.count) {
        return;
    }
    [self setSelect:index animation:YES];
}


- (UIView *)headerViewFor:(SegmentPageViewController *)segmentPageController {
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor blueColor];
    return headerView;
}

- (CGFloat)headerViewHeightFor:(SegmentPageViewController *)segmentPageController {
    return self.headerViewHeight;
}

- (NSInteger)numberOfViewControllersIn:(SegmentPageViewController *)segmentPageController {
    return self.count;
}

- (UIViewController<SegmentPageChildViewController> *)segmentPageController:(SegmentPageViewController *)segmentPageController viewControllerAt:(NSInteger)index {
    if (index == 0) {
        return [[FirstViewController alloc] initWithNibName:NSStringFromClass([FirstViewController class]) bundle:nil];
    }else if (index == 1) {
        return [[SecondViewController alloc] initWithNibName:NSStringFromClass([SecondViewController class]) bundle:nil];
    }else {
        return [[ThirdViewController alloc] initWithNibName:NSStringFromClass([ThirdViewController class]) bundle:nil];
    }
}

- (UIView *)menuViewFor:(SegmentPageViewController *)segmentPageController {
    return self.menuView;
}

- (CGFloat)menuViewHeightFor:(SegmentPageViewController *)segmentPageController {
    return self.menuViewHeight;
}

- (CGFloat)menuViewPinHeightFor:(SegmentPageViewController *)segmentPageController {
    return [UIApplication sharedApplication].statusBarFrame.size.height + 44.0;
}

- (NSInteger)originIndexFor:(SegmentPageViewController *)segmentPageController {
    return 0;
}

#pragma mark - delegate -
- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController mainScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat rate = [UIApplication sharedApplication].statusBarFrame.size.height * 3;
    self.navBar.alpha = MIN(scrollView.contentOffset.y / rate, 1.0);
    
}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController contentScrollViewDidScroll:(UIScrollView *)scrollView {
    [self.menuView updateLayout:scrollView];
}


- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController contentScrollViewDidEndScroll:(UIScrollView *)scrollView {
    [self.menuView checkState];
}

- (void)segmentPageViewController:(SegmentPageViewController *)segmentPageController  menuView:(BOOL)isAdsorption {
    self.menuView.backgroundColor = isAdsorption?[UIColor blackColor]:[UIColor whiteColor];
}


@end
