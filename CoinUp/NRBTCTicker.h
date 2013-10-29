//
//  NRBTCTicker.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NRCoinUpBoard.h"

#define STRING(x) #x
#define NAME(x) @STRING(x)
#define TYPE(x) x

#define UNAVAILABLE 0
#define WAITINGTIME 10

@interface NRBTCTicker : NSObject

@property (nonatomic) double last;
@property (nonatomic) double high;
@property (nonatomic) double low;
@property (nonatomic) double vol;
@property (nonatomic) double ask;
@property (nonatomic) double bid;

@property (nonatomic, strong) NSArray *tradeArray;
@property (nonatomic, strong) NSArray *depthArray;

@property (nonatomic, weak) id<NRCoinUpBoard> delegate;

- (void)tradeArrayParser:(NSArray*)array;
- (void)depthJsonParser:(NSDictionary*)dic;

@end
