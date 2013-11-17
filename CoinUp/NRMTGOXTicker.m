//
//  NRMTGOXTicker.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRMTGOXTicker.h"
#import "JSONKit.h"

#define TICKER_URL @"http://data.mtgox.com/api/1/BTCUSD/ticker"
#define TRADE_URL @"http://info.btc123.com/lib/jsonProxyEx.php?type=MtGoxTradesv2NODB"
#define DEPTH_URL @"http://info.btc123.com/lib/jsonProxyEx.php?type=MtGoxDepthv2"
#define PLATFORM MTGOX

@implementation NRMTGOXTicker

- (NRMTGOXTicker*)init
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
    __weak NRMTGOXTicker* weakSelf = self;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Queue", NULL);
	dispatch_async(downloadQueue, ^{
        jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:TICKER_URL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonData)
            {
                NSDictionary *jsonObject = [[[[JSONDecoder alloc] init] objectWithData:jsonData] objectForKey:@"return"];
                if (self.useTickerToUpdateUI)
                    weakSelf.last = [jsonObject[@"last"][@"value"] doubleValue];
                weakSelf.high = [jsonObject[@"high"][@"value"] doubleValue];
                weakSelf.low = [jsonObject[@"low"][@"value"] doubleValue];
                weakSelf.vol = [jsonObject[@"vol"][@"value"] doubleValue];
                weakSelf.ask = [jsonObject[@"sell"][@"value"] doubleValue];
                weakSelf.bid = [jsonObject[@"buy"][@"value"] doubleValue];
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

- (void)tradeArrayParser:(NSArray*)array
{
    if (array == nil)
    {
        self.tradeArray = nil;
        return;
    }
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Queue", NULL);
	dispatch_async(downloadQueue, ^{
        NSMutableArray *resultMutableArray = [NSMutableArray arrayWithCapacity:100];
        for (int i = array.count-1; i>=0; --i)
        {
            NSDictionary *item = array[i];
            NSString *type = [item[@"trade_type"] isEqualToString:@"bid"]?@"sell":@"buy";
            [resultMutableArray addObject:@{@"date":item[@"date"],@"price":item[@"price"],@"amount":item[@"amount"],@"type":type}];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{    self.tradeArray = [resultMutableArray copy];
        });
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"last"])
    {
        if (self.last != UNAVAILABLE)
            [self.delegate updateLabel:[NSString stringWithFormat:@"$%.2f",self.last] ForName:NAME(PLATFORM)];
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
            [self.delegate setInfoWindowForHigh:[NSString stringWithFormat:@"$%.2f",self.high] Low:[NSString stringWithFormat:@"$%.2f",self.low] Ask:[NSString stringWithFormat:@"$%.2f",self.ask] Bid:[NSString stringWithFormat:@"$%.2f",self.bid] Vol:[NSString stringWithFormat:@"฿%.2f",self.vol]];
        }
        [self.delegate setTradeArrayAndReloadTableView:self.tradeArray];
        [self.delegate setDepthArrayAndReloadTableView:self.depthArray];
    }
}

@end
