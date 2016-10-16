//
//  NRViewController.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRCoinUpBoard.h"
#import "NRSwitchViewController.h"
#import "DataPuller.h"
#import "CorePlot-CocoaTouch.h"

@interface NRViewController : NRSwitchViewController<NRCoinUpBoard,UITableViewDataSource,UITableViewDelegate,DataPullerDelegate,CPTPlotDataSource,CPTPlotSpaceDelegate,CPTScatterPlotDelegate>

- (void)dismissModalViewController;

@end
