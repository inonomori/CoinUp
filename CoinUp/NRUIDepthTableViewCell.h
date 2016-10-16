//
//  NRUIDepthTableViewCell.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-29.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAXIMUM_BAR_VALUE 50

@interface NRUIDepthTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *buyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyVolLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellVolLabel;
@property (weak, nonatomic) IBOutlet UIView *buyBarView;
@property (weak, nonatomic) IBOutlet UIView *sellBarView;

- (void)setSellBarValue:(double)sellvalue BuyBarValue:(double)buyvalue;

@end
