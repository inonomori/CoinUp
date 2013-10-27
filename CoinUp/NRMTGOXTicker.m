//
//  NRMTGOXTicker.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRMTGOXTicker.h"
#import "JSONKit.h"

#define URL @"http://data.mtgox.com/api/1/BTCUSD/ticker"
#define TRADE_URL @"http://info.btc123.com/lib/jsonProxyEx.php?type=MtGoxTradesv2NODB"
#define PLATFORMNAME @"MTGOX"
#define PLATFORMTYPE MTGOX

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
    __weak NRMTGOXTicker* weakSelf = self;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Queue", NULL);
	dispatch_async(downloadQueue, ^{
        jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonData)
            {
                NSDictionary *jsonObject = [[[[JSONDecoder alloc] init] objectWithData:jsonData] objectForKey:@"return"];
                weakSelf.last = [jsonObject[@"last"][@"value"] doubleValue];
                weakSelf.high = [jsonObject[@"high"][@"value"] doubleValue];
                weakSelf.low = [jsonObject[@"low"][@"value"] doubleValue];
                weakSelf.vol = [jsonObject[@"vol"][@"value"] doubleValue];
                weakSelf.ask = [jsonObject[@"sell"][@"value"] doubleValue];
                weakSelf.bid = [jsonObject[@"buy"][@"value"] doubleValue];
            }
            else
            {
                weakSelf.last = UNAVAILABLE;
                weakSelf.high = UNAVAILABLE;
                weakSelf.low = UNAVAILABLE;
                weakSelf.vol = UNAVAILABLE;
                weakSelf.ask = UNAVAILABLE;
                weakSelf.bid = UNAVAILABLE;
            }
            
            TradeJsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:TRADE_URL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (TradeJsonData)
                {
                    NSArray* jsonResultArray = [[[JSONDecoder alloc] init] objectWithData:TradeJsonData];
                    [self tradeArrayParser:jsonResultArray];
                }
                else
                    self.tradeArray = nil;
            });
        });
	});
	dispatch_release(downloadQueue);
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
    NSMutableArray *resultMutableArray = [NSMutableArray arrayWithCapacity:100];
    for (int i = array.count-1; i>=0; --i)
    {
        NSDictionary *item = array[i];
        NSString *type = [item[@"trade_type"] isEqualToString:@"bid"]?@"sell":@"buy";
        [resultMutableArray addObject:@{@"date":item[@"date"],@"price":item[@"price"],@"amount":item[@"amount"],@"type":type}];
        
    }
    self.tradeArray = [resultMutableArray copy];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"last"])
    {
        if (self.last != UNAVAILABLE)
            [self.delegate updateLabel:[NSString stringWithFormat:@"$%.2f",self.last] ForName:PLATFORMNAME];
        else
            [self.delegate updateLabel:@"N/A" ForName:PLATFORMNAME];
        
        if ([change[@"old"] doubleValue] > self.last)
            [self.delegate flashColorInGreen:NO ForName:PLATFORMNAME];
        else if ([change[@"old"] doubleValue] < self.last)
            [self.delegate flashColorInGreen:YES ForName:PLATFORMNAME];
        else{}
    }
    else if (![keyPath isEqualToString:@"tradeArray"])
        [self updateInfoWindow];
    else //tradeArray
    {
        if ([self.delegate currentPlatformType] == PLATFORMTYPE)
            [self.delegate setTradeArrayAndReloadTableView:self.tradeArray];
    }
}

- (void)updateInfoWindow
{
    if ([self.delegate currentPlatformType] == PLATFORMTYPE)
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
    }
}

@end
