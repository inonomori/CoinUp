//
//  NRUIDepthTableViewCell.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-29.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRUIDepthTableViewCell.h"
#import "ToolBox.h"

@implementation NRUIDepthTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSellBarValue:(double)sellvalue BuyBarValue:(double)buyvalue
{
    CGFloat buyRatio = (float)(buyvalue/MAXIMUM_BAR_VALUE);
    CGFloat sellRatio = (float)(sellvalue/MAXIMUM_BAR_VALUE);
    
    NSInteger buyLength = SCREENWIDTH/2*buyRatio;
    NSInteger sellLength = SCREENWIDTH/2*sellRatio;
    
    
    CGRect buyframe = self.buyBarView.frame;
    CGRect sellframe = self.sellBarView.frame;
    
    buyframe.origin.x = SCREENWIDTH/2 - buyLength;
    buyframe.size.width = buyLength;
    self.buyBarView.frame = buyframe;
    
    sellframe.size.width = sellLength;
    self.sellBarView.frame = sellframe;
}

@end
