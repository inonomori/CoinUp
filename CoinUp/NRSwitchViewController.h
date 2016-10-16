//
//  NRSwitchViewController.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-12-4.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NRSwitchViewControllerProtocol <NSObject>
@required
- (void)switchToViewController:(UIViewController *)viewController Animation:(UIViewAnimationOptions)animationOption AdditionalInitBlock:(void (^)(id))initBlock;
@optional
- (void)switchToViewControllerWithIdentifier:(NSString*)identifier Animation:(UIViewAnimationOptions)animationOption AdditionalInitBlock:(void(^)(id))initBlock;
@end


@interface NRSwitchViewController : UIViewController

@property (nonatomic, weak) id<NRSwitchViewControllerProtocol> delegate;

@end
