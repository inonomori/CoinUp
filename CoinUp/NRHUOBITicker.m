//
//  NRHUOBITicker.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRHUOBITicker.h"
#import "JSONKit.h"

#define TICKER_URL @"http://www.btc123.com/e/interfaces/tickers.php?type=huobiTicker"
#define TRADE_URL @"http://info.btc123.com/lib/jsonProxyEx.php?type=huobiTrades"
#define DEPTH_URL @"http://info.btc123.com/lib/jsonProxyEx.php?type=huobiDepth"
#define PLATFORM HUOBI

@implementation NRHUOBITicker

- (NRHUOBITicker*)init
{
    [self addObserver:self
           forKeyPath:@"last"
              options:(NSKeyValueObservingOptionOld)
              context:NULL];
    [self addObserver:self
           forKeyPath:@"high"
              options:(NSKeyValueObservingOptionOld)
              context:NULL];
    [self addObserver:self
           forKeyPath:@"low"
              options:(NSKeyValueObservingOptionOld)
              context:NULL];
    [self addObserver:self
           forKeyPath:@"vol"
              options:(NSKeyValueObservingOptionOld)
              context:NULL];
    [self addObserver:self
           forKeyPath:@"ask"
              options:(NSKeyValueObservingOptionOld)
              context:NULL];
    [self addObserver:self
           forKeyPath:@"bid"
              options:(NSKeyValueObservingOptionOld)
              context:NULL];
    [self addObserver:self
           forKeyPath:@"tradeArray"
              options:NSKeyValueObservingOptionOld
              context:NULL];
    [self addObserver:self
           forKeyPath:@"depthArray"
              options:NSKeyValueObservingOptionOld
              context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfoWindow) name:@"InfoWindowUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrinceSetting) name:@"InfoWindowUpdate" object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)update:(id)userInfo
{
    __block NSData *jsonData;
    __block NSData *TradeJsonData;
    __block NSData *DepthJsonData;
    __weak NRHUOBITicker* weakSelf = self;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Queue", NULL);
	dispatch_async(downloadQueue, ^{
        jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:TICKER_URL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonData)
            {
                NSDictionary *jsonObject = [[[[JSONDecoder alloc] init] objectWithData:jsonData] objectForKey:@"ticker"];
                if (self.useTickerToUpdateUI)
                    weakSelf.last = [jsonObject[@"last"] doubleValue];
                weakSelf.high = [jsonObject[@"high"] doubleValue];
                weakSelf.low = [jsonObject[@"low"] doubleValue];
                weakSelf.vol = [jsonObject[@"vol"] doubleValue];
                weakSelf.ask = [jsonObject[@"sell"] doubleValue];
                weakSelf.bid = [jsonObject[@"buy"] doubleValue];
            }
            else
            {
                if (self.useTickerToUpdateUI)
                    weakSelf.last = UNAVAILABLE;
                weakSelf.high = UNAVAILABLE;
                weakSelf.low = UNAVAILABLE;
                weakSelf.vol = UNAVAILABLE;
                weakSelf.ask = UNAVAILABLE;
                weakSelf.bid = UNAVAILABLE;
            }
            
        });
        
        TradeJsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:TRADE_URL]];
        if (TradeJsonData)
        {
            NSArray* jsonResultArray = [[[JSONDecoder alloc] init] objectWithData:TradeJsonData];
            [self tradeArrayParser:jsonResultArray];
        }
        else
            [self tradeArrayParser:nil];
        
        DepthJsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:DEPTH_URL]];
        if (DepthJsonData)
        {
            NSDictionary *jsonResult = [[[JSONDecoder alloc] init] objectWithData:DepthJsonData];
            [self depthJsonParser:jsonResult];
        }
        else
            [self depthJsonParser:nil];

	});
}

- (void)start
{
    [self update:nil];
    [NSTimer scheduledTimerWithTimeInterval:WAITINGTIME
                                     target:self
                                   selector:@selector(update:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"last"])
    {
        if (self.last != UNAVAILABLE)
            [self.delegate updateLabel:[NSString stringWithFormat:@"¥%.2f",self.last] ForName:NAME(PLATFORM)];
        else
            [self.delegate updateLabel:@"N/A" ForName:NAME(PLATFORM)];
        
        if ([change[@"old"] doubleValue] > self.last)
            [self.delegate flashColorInGreen:NO ForName:NAME(PLATFORM)];
        else if ([change[@"old"] doubleValue] < self.last)
            [self.delegate flashColorInGreen:YES ForName:NAME(PLATFORM)];
        else{}
        
        [self updatePrinceSetting];
    }
    else if (![keyPath isEqualToString:@"tradeArray"] || ![keyPath isEqualToString:@"depthArray"])
        [self updateInfoWindow];
    else //depth or trade
    {
        if ([self.delegate currentPlatformType] == TYPE(PLATFORM))
        {
            if ([keyPath isEqualToString:@"tradeArray"])
                [self.delegate setTradeArrayAndReloadTableView:self.tradeArray];
            else
                [self.delegate setDepthArrayAndReloadTableView:self.depthArray];
            
        }
    }
}

- (void)updatePrinceSetting
{
    if ([self.delegate currentPlatformType] == TYPE(PLATFORM))
    {
        [self.delegate setLastPriceNumberWithDoubleNumber:self.last];
    }
}

- (void)updateInfoWindow
{
    if ([self.delegate currentPlatformType] == TYPE(PLATFORM))
    {
        if (self.low == UNAVAILABLE || self.high == UNAVAILABLE || self.ask == UNAVAILABLE || self.bid == UNAVAILABLE || self.vol == UNAVAILABLE)
        {
            [self.delegate setInfoWindowForHigh:@"N/A" Low:@"N/A" Ask:@"N/A" Bid:@"N/A" Vol:@"N/A"];
        }
        else
        {
            [self.delegate setInfoWindowForHigh:[NSString stringWithFormat:@"¥%.2f",self.high] Low:[NSString stringWithFormat:@"¥%.2f",self.low] Ask:[NSString stringWithFormat:@"¥%.2f",self.ask] Bid:[NSString stringWithFormat:@"¥%.2f",self.bid] Vol:[NSString stringWithFormat:@"฿%.2f",self.vol]];
        }
        [self.delegate setTradeArrayAndReloadTableView:self.tradeArray];
        [self.delegate setDepthArrayAndReloadTableView:self.depthArray];
    }
}

@end
