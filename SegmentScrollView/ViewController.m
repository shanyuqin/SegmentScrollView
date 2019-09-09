//
//  ViewController.m
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/19.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import "ViewController.h"
#import "TestSegPageViewController.h"

@interface ViewController ()<UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:FALSE animated:animated];
}

- (IBAction)buttonAction:(UIButton *)sender {
    
    TestSegPageViewController *segVC = [TestSegPageViewController new];
    [self.navigationController pushViewController:segVC animated:YES];
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isRootVC = (viewController == navigationController.viewControllers.firstObject);
    [navigationController.interactivePopGestureRecognizer setEnabled:!isRootVC];
}

@end
