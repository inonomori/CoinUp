//
//  NRBTCTicker.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "NRBTCTicker.h"

@implementation NRBTCTicker

- (NSArray*)tradeArray
{
    if (_tradeArray == nil)
        _tradeArray = [NSArray array];
    return _tradeArray;
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
            [resultMutableArray addObject:@{@"date":item[@"date"],@"price":item[@"price"],@"amount":item[@"amount"],@"type":item[@"type"]}];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tradeArray = [resultMutableArray copy];
        });
        
    });
    dispatch_release(downloadQueue);
}

- (void)depthJsonParser:(NSDictionary*)dic
{
    if (dic == nil)
    {
        self.depthArray = nil;
        return;
    }
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Queue", NULL);
	dispatch_async(downloadQueue, ^{
        
        NSArray *askArray = dic[@"asks"];
        NSArray *bidArray = dic[@"bids"];
        NSMutableArray *resultMutableArray = [NSMutableArray arrayWithCapacity:50];
        NSInteger count = (askArray.count > bidArray.count)?bidArray.count:askArray.count;
        for (int i = 0; i < count; ++i)
        {
            [resultMutableArray addObject:@{@"ask":askArray[askArray.count-i-1],@"bid":bidArray[i]}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.depthArray = [resultMutableArray copy];
        });
    });
    dispatch_release(downloadQueue);
}

@end
