//
//  NRMainViewController.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-12-4.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRMainViewController.h"

@interface NRMainViewController ()

@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation NRMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.currentViewController = [sb instantiateViewControllerWithIdentifier:@"BTCViewController"];
    NRSwitchViewController *viewController = (NRSwitchViewController*)self.currentViewController;
    viewController.delegate = self;
    [self addChildViewController:self.currentViewController];
    self.currentViewController.view.frame=self.view.bounds;
    [self.view addSubview:self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//FSSwitchViewController
- (void)switchToViewController:(UIViewController *)viewController Animation:(UIViewAnimationOptions)animationOption AdditionalInitBlock:(void (^)(id))initBlock
{
    NRSwitchViewController *aNewViewController = (NRSwitchViewController*)viewController;
    aNewViewController.delegate = self;
    if (initBlock)
        initBlock(aNewViewController);
    [aNewViewController.view layoutIfNeeded];
    aNewViewController.view.frame = self.view.bounds;
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:aNewViewController];
    
    __weak __block NRMainViewController *weakSelf=self;
    [self transitionFromViewController:self.currentViewController
                      toViewController:aNewViewController
                              duration:1.0
                               options:animationOption
                            animations:nil
                            completion:^(BOOL finished) {
                                [weakSelf.currentViewController.view removeFromSuperview];
                                [weakSelf.currentViewController removeFromParentViewController];
                                [aNewViewController didMoveToParentViewController:weakSelf];
                                weakSelf.currentViewController = aNewViewController;
                            }];
    
}

- (void)switchToViewControllerWithIdentifier:(NSString*)identifier Animation:(UIViewAnimationOptions)animationOption AdditionalInitBlock:(void(^)(id))initBlock
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    [self switchToViewController:[sb instantiateViewControllerWithIdentifier:identifier] Animation:animationOption AdditionalInitBlock:initBlock];
}


@end
