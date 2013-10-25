//
//  NROKCoinTicker.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NROKCoinTicker.h"
#import "JSONKit.h"

#define URL @"http://www.okcoin.com/api/ticker.do"
#define PLATFORMNAME @"OKCOIN"

@implementation NROKCoinTicker

- (NROKCoinTicker*)init
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfoWindow) name:@"InfoWindowUpdate" object:nil];
    
    return self;
}

- (void)update:(id)userInfo
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("DownloadQueue", NULL);
	
    dispatch_async(downloadQueue, ^{
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL]];
        if (jsonData)
        {
            NSDictionary *jsonObject = [[[[JSONDecoder alloc] init] objectWithData:jsonData] objectForKey:@"ticker"];
            //        self.last = [jsonObject[@"last_rate"] doubleValue];
            //        self.high = [jsonObject[@"high"] doubleValue];
            //        self.low = [jsonObject[@"low"] doubleValue];
            //        self.vol = [jsonObject[@"vol"] doubleValue];
            //        self.ask = [jsonObject[@"ask"] doubleValue];
            //        self.bid = [jsonObject[@"bid"] doubleValue];
        }
        else
        {
            self.last = UNAVAILABLE;
            self.high = UNAVAILABLE;
            self.low = UNAVAILABLE;
            self.vol = UNAVAILABLE;
            self.ask = UNAVAILABLE;
            self.bid = UNAVAILABLE;
        }
	});
	dispatch_release(downloadQueue);
}

- (void)start
{
    [self update:nil];
    [NSTimer scheduledTimerWithTimeInterval:5
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
            [self.delegate updateLabel:[NSString stringWithFormat:@"¥%.2f",self.last] ForName:PLATFORMNAME];
        else
            [self.delegate updateLabel:@"N/A" ForName:PLATFORMNAME];
        
        if ([change[@"old"] doubleValue] > self.last)
            [self.delegate flashColorInGreen:NO ForName:PLATFORMNAME];
        else if ([change[@"old"] doubleValue] < self.last)
            [self.delegate flashColorInGreen:YES ForName:PLATFORMNAME];
        else{}
    }
    else
    {
//        if ([[self valueForKey:keyPath] doubleValue] != UNAVAILABLE)
//        {
            [self updateInfoWindow];
//        }
//        else
//            [self.delegate setInfoWindowForHigh:@"N/A" Low:@"N/A" Ask:@"N/A" Bid:@"N/A" Vol:@"N/A"];
    }
}

- (void)updateInfoWindow
{
    if ([self.delegate currentPlatformType] == OKCOIN)
    {
        if (self.low == UNAVAILABLE || self.high == UNAVAILABLE || self.ask == UNAVAILABLE || self.bid == UNAVAILABLE || self.vol == UNAVAILABLE)
        {
            [self.delegate setInfoWindowForHigh:@"N/A" Low:@"N/A" Ask:@"N/A" Bid:@"N/A" Vol:@"N/A"];
        }
        else
        {
            [self.delegate setInfoWindowForHigh:[NSString stringWithFormat:@"¥%.2f",self.high] Low:[NSString stringWithFormat:@"¥%.2f",self.low] Ask:[NSString stringWithFormat:@"¥%.2f",self.ask] Bid:[NSString stringWithFormat:@"¥%.2f",self.bid] Vol:[NSString stringWithFormat:@"฿%.2f",self.vol]];
        }
    }
}

@end
