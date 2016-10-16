//
//  NRVerifyViewController.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-11-28.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRViewController.h"

@interface NRVerifyViewController : UIViewController <NSURLConnectionDelegate>

@property (nonatomic, weak) NRViewController *delegate;

@end
