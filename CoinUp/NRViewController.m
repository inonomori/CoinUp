//
//  NRViewController.m
//  CoinUp
//
//  Created by Zhefu Wang on 13-10-25.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//
//  God bless me to earn a thousand Yuan!
//
//

#import <QuartzCore/QuartzCore.h>
#import "NRViewController.h"
#import "NROKCoinTicker.h"
#import "NRFXBTCTicker.h"
#import "NRBTCTRADETicker.h"
#import "NRMTGOXTicker.h"
#import "NRBITSTAMPTicker.h"
#import "NRCHBTCTicker.h"
#import "NRBTCCHINATicker.h"
#import "NRHUOBITicker.h"
#import "NRBTC100Ticker.h"
#import "ToolBox.h"

@interface NRViewController ()

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *CoverView;
@property (weak, nonatomic) IBOutlet UIView *cover_FXBTC;
@property (weak, nonatomic) IBOutlet UIView *cover_OKCOIN;
@property (weak, nonatomic) IBOutlet UIView *cover_BTCTRADE;
@property (weak, nonatomic) IBOutlet UIView *cover_MTGOX;
@property (weak, nonatomic) IBOutlet UIView *cover_BITSTAMP;
@property (weak, nonatomic) IBOutlet UIView *cover_CHBTC;
@property (weak, nonatomic) IBOutlet UIView *cover_BTCCHINA;
@property (weak, nonatomic) IBOutlet UIView *cover_HUOBI;
@property (weak, nonatomic) IBOutlet UIView *cover_BTC100;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_FXBTC;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_OKCOIN;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_BTCTRADE;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_MTGOX;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_BITSTAMP;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_CHBTC;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_BTCCHINA;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_HUOBI;
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_BTC100;
@property (weak, nonatomic) IBOutlet UIView *InfoWindow;
@property (weak, nonatomic) IBOutlet UILabel *buy1PriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sell1PriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *highPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *volLabel;
@property (nonatomic) COINPLATFORMTYPE platformType;

// look upper, it is a penis

@end


@implementation NRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.platformType = NOPLATFORM;
    self.InfoWindow.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.InfoWindow.layer.shadowOffset = CGSizeMake(0, 0);
    self.InfoWindow.layer.masksToBounds = NO;
    self.InfoWindow.layer.cornerRadius = 8;
    self.InfoWindow.layer.shadowRadius = 5;
    self.InfoWindow.layer.shadowOpacity = 0.5;
    
    
    NRFXBTCTicker *FXBTCticker = [[NRFXBTCTicker alloc] init];
    FXBTCticker.delegate = self;
    [FXBTCticker start];
    
    NROKCoinTicker *okcoinTicker = [[NROKCoinTicker alloc] init];
    okcoinTicker.delegate = self;
    [okcoinTicker start];
    
    NRBTCTRADETicker *btcTradeTicker = [[NRBTCTRADETicker alloc] init];
    btcTradeTicker.delegate = self;
    [btcTradeTicker start];
    
    NRMTGOXTicker *mtGoxTicker = [[NRMTGOXTicker alloc] init];
    mtGoxTicker.delegate = self;
    [mtGoxTicker start];
    
    NRBitStampTicker *bitStampTicker = [[NRBitStampTicker alloc] init];
    bitStampTicker.delegate = self;
    [bitStampTicker start];
    
    NRCHBTCTicker *CHBTCTicker = [[NRCHBTCTicker alloc] init];
    CHBTCTicker.delegate = self;
    [CHBTCTicker start];
    
    NRBTCCHINATicker *BTCChinaTicker = [[NRBTCCHINATicker alloc] init];
    BTCChinaTicker.delegate = self;
    [BTCChinaTicker start];
    
    NRHUOBITicker *HuoBiTicker = [[NRHUOBITicker alloc] init];
    HuoBiTicker.delegate = self;
    [HuoBiTicker start];
    
    NRBTC100Ticker *btc100Ticker = [[NRBTC100Ticker alloc] init];
    btc100Ticker.delegate = self;
    [btc100Ticker start];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateLabel:(NSString*)text ForName:(NSString*)Name
{
    NSString *valueName = [NSString stringWithFormat:@"LastLabel_%@",Name];
    ((UILabel*)[self valueForKey:valueName]).text = text;
}

- (void)flashColorInGreen:(BOOL)isGreen ForName:(NSString*)Name
{
    NSString *valueName = [NSString stringWithFormat:@"cover_%@",Name];
    ((UIView*)[self valueForKey:valueName]).backgroundColor = (isGreen)?[UIColor greenColor]:[UIColor redColor];
    ((UIView*)[self valueForKey:valueName]).alpha = 0.8;
   
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         ((UIView*)[self valueForKey:valueName]).alpha = 0;

                     }
                     completion:nil
     ];
}

- (COINPLATFORMTYPE)currentPlatformType
{
    return self.platformType;
}

- (void)setInfoWindowForHigh:(NSString*)high Low:(NSString*)low Ask:(NSString*)ask Bid:(NSString*)bid Vol:(NSString*)vol
{
    self.highPriceLabel.text = high;
    self.lowPriceLabel.text = low;
    self.buy1PriceLabel.text = bid;
    self.sell1PriceLabel.text = ask;
    self.volLabel.text = vol;
}


- (IBAction)ButtonTouched:(UIButton *)sender
{
    CGRect frame = self.InfoWindow.frame;
    self.platformType = sender.tag;
    
    if (self.CoverView.hidden)
    {
        self.CoverView.frame = [sender superview].frame;
        self.CoverView.hidden = NO;
    }
    else
    {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.CoverView.frame = [sender superview].frame;
                         }
                         completion:nil
         ];
    }
    
    if (frame.origin.y == SCREENHEIGHT)
    {
        frame.origin.y -= 110;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             self.InfoWindow.frame = frame;
             self.baseView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-120);
         }
                         completion:nil
         ];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InfoWindowUpdate" object:nil];
}

- (IBAction)InfoWindowSwipeDownGestureHandler:(UISwipeGestureRecognizer *)sender
{
    [self dismissInfoWindow];
}

- (void)dismissInfoWindow
{
    self.CoverView.hidden = YES;
    
    CGRect frame = self.InfoWindow.frame;
    frame.origin.y = SCREENHEIGHT;
    self.platformType = NOPLATFORM;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.InfoWindow.frame = frame;
         self.baseView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
     }
                     completion:nil
     ];
}

- (void)viewDidUnload {
    [self setCover_BTCTRADE:nil];
    [self setLastLabel_BTCTRADE:nil];
    [self setCover_MTGOX:nil];
    [self setLastLabel_MTGOX:nil];
    [self setCover_BITSTAMP:nil];
    [self setLastLabel_BITSTAMP:nil];
    [self setCover_CHBTC:nil];
    [self setLastLabel_CHBTC:nil];
    [self setCover_BTCCHINA:nil];
    [self setLastLabel_BTCCHINA:nil];
    [self setCover_HUOBI:nil];
    [self setLastLabel_HUOBI:nil];
    [self setCover_BTC100:nil];
    [self setLastLabel_BTC100:nil];
    [self setBaseView:nil];
    [super viewDidUnload];
}
@end
