//
//  NRAppDelegate.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRAppDelegate.h"
#import "FSPopDialogViewController.h"
#import "NRViewController.h"

@interface NRAppDelegate()

@property (nonatomic, strong) FSPopDialogViewController *PopDialogViewControlller;

@end

@implementation NRAppDelegate

- (FSPopDialogViewController*)PopDialogViewControlller
{
    if (!_PopDialogViewControlller)
        _PopDialogViewControlller = [[FSPopDialogViewController alloc] init];
    return _PopDialogViewControlller;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"token = %@",[prefs objectForKey:@"pushToken"]);
    if (![prefs objectForKey:@"pushToken"])
    {
        NSLog(@"initiating remoteNotificationAreActive");
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    if ([UIApplication sharedApplication].enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone)
    {
        NSLog(@"disabled remote push notification");
    }
    
    //handle push notification if app is not running
    [[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey] description];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", token);

    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"pushToken"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //self.window.rootViewController
    UIViewController *vc;
    
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nv = (UINavigationController*)self.window.rootViewController;
        vc = [nv.viewControllers lastObject];
    }
    else if ([self.window.rootViewController isKindOfClass:[UIViewController class]])
    {
        vc = self.window.rootViewController;
    }
    
    NSLog(@"receive a message");
    if (self.PopDialogViewControlller.isShow == NO)
    {
        self.PopDialogViewControlller.delegate = vc;
        self.PopDialogViewControlller.popDialogStyle = FSPopDialogStyleFromBottom;
        self.PopDialogViewControlller.disappearDialogStyle = FSPopDialogStyleFromBottom;
        self.PopDialogViewControlller.size = CGSizeMake(300,180);
        self.PopDialogViewControlller.dialogViewTitle = NSLocalizedString(@"notification", nil);
        self.PopDialogViewControlller.question = userInfo[@"aps"][@"alert"];
        self.PopDialogViewControlller.okButtonTitle = NSLocalizedString(@"OK", nil);
        self.PopDialogViewControlller.isShow = YES;
        [self.PopDialogViewControlller appear];
    }
    else //Update popwindow
    {
        self.PopDialogViewControlller.question = userInfo[@"aps"][@"alert"];
        self.PopDialogViewControlller.isShow = YES;
        [self.PopDialogViewControlller updateContent];
        [self.PopDialogViewControlller flash];
    }
    
    if ([vc isKindOfClass:[NRViewController class]])
    {
        //TODO: update pricesetting view
    }
}

@end
