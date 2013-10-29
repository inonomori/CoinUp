//
//  NRCoinUpBoard.h
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, COINPLATFORMTYPE) {
    NOPLATFORM = 0,
    FXBTC = 1,
    OKCOIN = 2,
    BTCTRADE = 3,
    MTGOX = 4,
    BITSTAMP = 5,
    CHBTC = 6,
    BTCCHINA = 7,
    HUOBI = 8,
    BTC100 = 9,
};

@protocol NRCoinUpBoard <NSObject>

- (void)updateLabel:(NSString*)text ForName:(NSString*)Name;
- (void)flashColorInGreen:(BOOL)isGreen ForName:(NSString*)Name;
- (COINPLATFORMTYPE)currentPlatformType;
- (void)setInfoWindowForHigh:(NSString*)high Low:(NSString*)low Ask:(NSString*)ask Bid:(NSString*)bid Vol:(NSString*)vol;
- (void)setTradeArrayAndReloadTableView:(NSArray*)array;
- (void)setDepthArrayAndReloadTableView:(NSArray *)depthArray;

@end
