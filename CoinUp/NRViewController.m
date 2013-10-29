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
#import "NRUITradeTableViewCell.h"
#import "NRUIDepthTableViewCell.h"

@interface NRViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewInfoWindow;
@property (nonatomic, strong) NSArray *tradeArray;
@property (nonatomic, strong) NSArray *depthArray;
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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *depthTableView;
@property (weak, nonatomic) IBOutlet UIImageView *upArrow;

@end

@implementation NRViewController

- (NSArray*)tradeArray
{
    if (_tradeArray == nil)
        _tradeArray = [NSArray array];
    return _tradeArray;
}

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollViewInfoWindow.contentSize = CGSizeMake(SCREENWIDTH*2, self.scrollViewInfoWindow.frame.size.height);
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

- (void)setTradeArrayAndReloadTableView:(NSArray *)tradeArray
{
    self.tradeArray = tradeArray;
    [self.tableView reloadData];
}

- (void)setDepthArrayAndReloadTableView:(NSArray *)depthArray
{
    self.depthArray = depthArray;
    [self.depthTableView reloadData];
}

#pragma mark - InfoWindow Control
- (IBAction)ButtonTouched:(UIButton *)sender
{
    self.tradeArray = nil;
    [self.tableView reloadData];
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
    NSLog(@"%f",SCREENHEIGHT);

    if (frame.origin.y == SCREENHEIGHT)
    {
        frame.origin.y -= 110;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             self.InfoWindow.frame = frame;
             self.baseView.frame = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))?CGRectMake(0, 20, SCREENWIDTH, SCREENHEIGHT-140):CGRectMake(0,0,SCREENWIDTH,SCREENHEIGHT-120);
         }
                         completion:nil
         ];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InfoWindowUpdate" object:nil];
}

- (IBAction)InfoWindowSwipeDownGestureHandler:(UISwipeGestureRecognizer *)sender
{
    if (self.InfoWindow.frame.origin.y == 0)
    {
        CGRect frame = self.InfoWindow.frame;
        frame.origin.y = SCREENHEIGHT-110;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.InfoWindow.frame = frame;
                             self.upArrow.alpha = 1;
                         }
                         completion:nil
         ];
    }
    else
        [self dismissInfoWindow];
}

- (IBAction)InfoWindowSwipeUpGestureHandler:(UISwipeGestureRecognizer *)sender
{
    CGRect frame = self.InfoWindow.frame;
    if (frame.origin.y != 0)
    {
        frame.origin.y = 0;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.InfoWindow.frame = frame;
                             self.upArrow.alpha = 0;
                         }
                         completion:nil
         ];
    }
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
         self.baseView.frame = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))?CGRectMake(0, 20, SCREENWIDTH, SCREENHEIGHT-20):CGRectMake(0,0,SCREENWIDTH,SCREENHEIGHT);;
     }
                     completion:nil
     ];
}

- (IBAction)SegmentControlValueChanged:(UISegmentedControl *)sender
{
    CGRect rect = CGRectMake(SCREENWIDTH*sender.selectedSegmentIndex, 0, SCREENWIDTH, sender.frame.size.height);
    [self.scrollViewInfoWindow scrollRectToVisible:rect animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0)
        return self.tradeArray.count;
    else
        return self.depthArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0)
    {
        static NSString *CellIdentifier = @"TradeCell";
        NRUITradeTableViewCell *cell;
        if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[NRUITradeTableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:CellIdentifier];
            }
        }
        else
        {
            cell = (NRUITradeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }
        
        cell.priceLabel.text = [NSString stringWithFormat:@"%.2f",[self.tradeArray[indexPath.row][@"price"] doubleValue]];
        cell.volLabel.text = [NSString stringWithFormat:@"%.3f",[self.tradeArray[indexPath.row][@"amount"] doubleValue]];
        NSString *t = self.tradeArray[indexPath.row][@"date"];
        
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:[t doubleValue]];
        NSDateFormatter *formateter = [[NSDateFormatter alloc] init];
        [formateter setDateFormat:@"HH:mm:ss"];
        NSString *time = [formateter stringFromDate:d];
        cell.timeStampLabel.text = time;
        if ([self.tradeArray[indexPath.row][@"type"] isEqualToString:@"buy"])
            cell.priceLabel.textColor = [UIColor redColor];
        else if ([self.tradeArray[indexPath.row][@"type"] isEqualToString:@"sell"])
            cell.priceLabel.textColor = [UIColor greenColor];
        else
            cell.priceLabel.textColor = [UIColor blackColor];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"DepthCell";
        NRUIDepthTableViewCell *cell;
        if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[NRUIDepthTableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:CellIdentifier];
            }
        }
        else
        {
            cell = (NRUIDepthTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }
        
        double askVol = [self.depthArray[indexPath.row][@"ask"][1] doubleValue];
        double bidVol = [self.depthArray[indexPath.row][@"bid"][1] doubleValue];
        cell.sellPriceLabel.text = [NSString stringWithFormat:@"%.2f",[self.depthArray[indexPath.row][@"ask"][0] doubleValue]];
        cell.sellVolLabel.text = [NSString stringWithFormat:@"%.2f",askVol];
        cell.buyPriceLabel.text = [NSString stringWithFormat:@"%.2f",[self.depthArray[indexPath.row][@"bid"][0] doubleValue]];
        cell.buyVolLabel.text = [NSString stringWithFormat:@"%.2f",bidVol];
        [cell setSellBarValue:askVol BuyBarValue:bidVol];
        
        return cell;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
