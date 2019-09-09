//
//  MenuView.h
//  SegmentScrollView
//
//  Created by shanyuqin on 2019/8/20.
//  Copyright © 2019 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MenuView;

@protocol MenuViewDelegate <NSObject>

- (void)menuView:(MenuView *)menuView didSelectedItemAt:(NSInteger)index;

@end


@interface MenuView : UIView

@property (nonatomic, weak) id<MenuViewDelegate> delegate;
@property (nonatomic, strong) NSArray * titles;
- (void)updateLayout:(UIScrollView *)externalScrollView;
- (void)checkState;
@end

NS_ASSUME_NONNULL_END
