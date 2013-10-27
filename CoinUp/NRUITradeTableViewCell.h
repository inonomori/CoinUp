//
//  NRUITradeTableViewCell.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-26.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRUITradeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *volLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

@end
