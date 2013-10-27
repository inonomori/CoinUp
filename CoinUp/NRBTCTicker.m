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
    NSMutableArray *resultMutableArray = [NSMutableArray arrayWithCapacity:100];
    for (int i = array.count-1; i>=0; --i)
    {
        NSDictionary *item = array[i];
        [resultMutableArray addObject:@{@"date":item[@"date"],@"price":item[@"price"],@"amount":item[@"amount"],@"type":item[@"type"]}];
        
    }
    self.tradeArray = [resultMutableArray copy];
}

@end
