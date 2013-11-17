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
#import <AFNetworking.h>
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
#import "NRCoinUpBoard.h"
#import "JSONKit.h"
#import "FSPopDialogViewController.h"

#define OHCP_LABEL_IS_ON NO
#define TOKEN [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]
#define kTouchPlot @"TOUCH PLOT"

@interface NRViewController ()

@property (nonatomic, strong) NRFXBTCTicker *FXBTCticker;
@property (nonatomic, strong) NROKCoinTicker *okcoinTicker;
@property (nonatomic, strong) NRBTCTRADETicker *btcTradeTicker;
@property (nonatomic, strong) NRMTGOXTicker *mtGoxTicker;
@property (nonatomic, strong) NRBitStampTicker *bitStampTicker;
@property (nonatomic, strong) NRCHBTCTicker *CHBTCTicker;
@property (nonatomic, strong) NRBTCCHINATicker *BTCChinaTicker;
@property (nonatomic, strong) NRHUOBITicker *HuoBiTicker;
@property (nonatomic, strong) NRBTC100Ticker *btc100Ticker;

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
@property (weak, nonatomic) IBOutlet UILabel *LastLabel_BITSTAMP;  //YES, I do not want to use IBOutletCollection
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
@property (nonatomic, strong) DataPuller *dataPuller;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHostView;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic) NSUInteger selectedCoordination;
@property (nonatomic) BOOL touchPlotSelected;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *graphVolLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *graphSegmentedController;
@property (weak, nonatomic) IBOutlet UIScrollView *priceSettingScrollView;
@property (weak, nonatomic) IBOutlet UITextField *priceSettingMaxTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceSettingMinTextField;
@property (weak, nonatomic) IBOutlet UILabel *priceSettingCurrentPriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *priceSettingHighActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *priceSettingLowActivityIndicator;
@property (weak, nonatomic) IBOutlet UISwitch *priceSettingHighSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *priceSettingLowSwitch;
@property (nonatomic, strong) FSPopDialogViewController *popDiagram;
@property (nonatomic) BOOL isNotificationWarningShowedAlready;
@property (nonatomic, strong) NSTimer *UIUpdateTimer;

@property (nonatomic, strong) NSString *bitstampSID;
@property (nonatomic) unsigned long long bitstampTimeStamp;

@property (nonatomic, strong) NSNumber *lastPriceNumber;
@property (nonatomic) NSInteger changedCounter; //sorry, i have no idea how to solve the problem of reset xy range

@end

@implementation NRViewController

- (NSArray*)tradeArray
{
    if (_tradeArray == nil)
        _tradeArray = [NSArray array];
    return _tradeArray;
}

- (FSPopDialogViewController*)popDiagram
{
    if (!_popDiagram)
    {
        _popDiagram = [[FSPopDialogViewController alloc] init];
        _popDiagram.delegate = self;
    }
    return _popDiagram;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isNotificationWarningShowedAlready = NO;
    self.changedCounter = 0;  //do not allow to change xy range
    [self setupGraphicPlots];
    self.platformType = NOPLATFORM;
    self.InfoWindow.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.InfoWindow.layer.shadowOffset = CGSizeMake(0, 0);
    self.InfoWindow.layer.masksToBounds = NO;
    self.InfoWindow.layer.cornerRadius = 8;
    self.InfoWindow.layer.shadowRadius = 5;
    self.InfoWindow.layer.shadowOpacity = 0.5;
    
    
    self.FXBTCticker= [[NRFXBTCTicker alloc] init];
    self.FXBTCticker.delegate = self;
    self.FXBTCticker.useTickerToUpdateUI = NO;
    [self.FXBTCticker start];
    
    self.okcoinTicker = [[NROKCoinTicker alloc] init];
    self.okcoinTicker.delegate = self;
    self.okcoinTicker.useTickerToUpdateUI = NO;
    [self.okcoinTicker start];
    
    self.btcTradeTicker = [[NRBTCTRADETicker alloc] init];
    self.btcTradeTicker.delegate = self;
    self.btcTradeTicker.useTickerToUpdateUI = NO;
    [self.btcTradeTicker start];
    
    self.mtGoxTicker = [[NRMTGOXTicker alloc] init];
    self.mtGoxTicker.delegate = self;
    self.mtGoxTicker.useTickerToUpdateUI = NO;
    [self.mtGoxTicker start];
    
    self.bitStampTicker = [[NRBitStampTicker alloc] init];
    self.bitStampTicker.delegate = self;
    self.bitStampTicker.useTickerToUpdateUI = NO;
    [self.bitStampTicker start];
    
    self.CHBTCTicker = [[NRCHBTCTicker alloc] init];
    self.CHBTCTicker.delegate = self;
    self.CHBTCTicker.useTickerToUpdateUI = NO;
    [self.CHBTCTicker start];
    
    self.BTCChinaTicker = [[NRBTCCHINATicker alloc] init];
    self.BTCChinaTicker.delegate = self;
    self.BTCChinaTicker.useTickerToUpdateUI = NO;
    [self.BTCChinaTicker start];
    
    self.HuoBiTicker = [[NRHUOBITicker alloc] init];
    self.HuoBiTicker.delegate = self;
    self.HuoBiTicker.useTickerToUpdateUI = NO;
    [self.HuoBiTicker start];
    
    self.btc100Ticker = [[NRBTC100Ticker alloc] init];
    self.btc100Ticker.delegate = self;
    self.btc100Ticker.useTickerToUpdateUI = NO;
    [self.btc100Ticker start];
    
    [self updateLastPriceForAllPlatform:nil];
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(updateLastPriceForAllPlatform:)
                                   userInfo:nil
                                    repeats:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBITSTAMPSID];
    self.scrollViewInfoWindow.contentSize = CGSizeMake(SCREENWIDTH*4, self.scrollViewInfoWindow.frame.size.height);
    self.priceSettingScrollView.contentSize = CGSizeMake(self.priceSettingScrollView.frame.size.width,1500);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateLastPriceForAllPlatform:(id)userInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"http://115.29.191.191:4321/all" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *resultDic = (NSDictionary*)responseObject;
         double bitstampPrice = [resultDic[@"bitstamp"] doubleValue];
         double btc100Price = [resultDic[@"btc100"] doubleValue];
         double btcchinaPrice = [resultDic[@"btcchina"] doubleValue];
         double btctradePrice = [resultDic[@"btctrade"] doubleValue];
         double chbtcPrice = [resultDic[@"chbtc"] doubleValue];
         double fxbtcPrice = [resultDic[@"fxbtc"] doubleValue];
         double huobiPrice = [resultDic[@"huobi"] doubleValue];
         double mtgoxPrice = [resultDic[@"mtgox"] doubleValue];
         double okcoinPrice = [resultDic[@"okcoin"] doubleValue];
         
         self.FXBTCticker.last = fxbtcPrice;
         self.okcoinTicker.last = okcoinPrice;
         self.btcTradeTicker.last = btctradePrice;
         self.mtGoxTicker.last = mtgoxPrice;
         self.bitStampTicker.last = bitstampPrice;
         self.CHBTCTicker.last = chbtcPrice;
         self.BTCChinaTicker.last = btcchinaPrice;
         self.HuoBiTicker.last = huobiPrice;
         self.btc100Ticker.last = btc100Price;
         
         NSLog(@"JSON: %@", responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self.UIUpdateTimer invalidate];
         self.UIUpdateTimer = nil;
         self.FXBTCticker.useTickerToUpdateUI = YES;
         self.okcoinTicker.useTickerToUpdateUI = YES;
         self.btcTradeTicker.useTickerToUpdateUI = YES;
         self.mtGoxTicker.useTickerToUpdateUI = YES;
         self.bitStampTicker.useTickerToUpdateUI = YES;
         self.CHBTCTicker.useTickerToUpdateUI = YES;
         self.BTCChinaTicker.useTickerToUpdateUI = YES;
         self.HuoBiTicker.useTickerToUpdateUI = YES;
         self.btc100Ticker.useTickerToUpdateUI = YES;
         NSLog(@"Error: %@", error);
     }];
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

- (NSString*)getBitStampSID
{
    return self.bitstampSID;
}

- (unsigned long long)getBitStampTimeStamp
{
    return self.bitstampTimeStamp;
}

- (void)setGraphDataLabelForDataAtIndex:(NSUInteger)index
{
    NSInteger moneyDivision = [ToolBox getMoneyDivisionForPlatform:self.platformType];
    NSInteger volDivision = [ToolBox getVolDivisionForPlatform:self.platformType];
    
    NSInteger json_volIndex = (self.platformType == BITSTAMP)?7:5;
    NSInteger json_openIndex = (self.platformType == BITSTAMP)?3:1;
    NSInteger json_closeIndex = 4;
    NSInteger json_maxIndex = (self.platformType == BITSTAMP)?5:2;
    NSInteger json_minIndex = (self.platformType == BITSTAMP)?6:3;
    
    if (self.dataPuller.filteredFinancialData != nil && self.dataPuller.filteredFinancialData.count > index)
    {
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:[self.dataPuller.filteredFinancialData[index][0] doubleValue]];
        NSDateFormatter *formateter = [[NSDateFormatter alloc] init];
        [formateter setDateFormat:@"yyyy年MM月dd日HH:mm"];
        NSString *time = [formateter stringFromDate:d];
        
        self.dateLabel.text = time;
        self.openLabel.text = [NSString stringWithFormat:@"%.2f",[self.dataPuller.filteredFinancialData[index][json_openIndex] doubleValue]/moneyDivision];
        self.maxLabel.text = [NSString stringWithFormat:@"%.2f",[self.dataPuller.filteredFinancialData[index][json_maxIndex] doubleValue]/moneyDivision];
        self.minLabel.text = [NSString stringWithFormat:@"%.2f",[self.dataPuller.filteredFinancialData[index][json_minIndex] doubleValue]/moneyDivision];
        self.closeLabel.text = [NSString stringWithFormat:@"%.2f",[self.dataPuller.filteredFinancialData[index][json_closeIndex] doubleValue]/moneyDivision];
        self.graphVolLabel.text = [NSString stringWithFormat:@"%.3f",[self.dataPuller.filteredFinancialData[index][json_volIndex] doubleValue]/volDivision];
    }
}

#pragma mark - InfoWindow Control
- (IBAction)ButtonTouched:(UIButton *)sender
{
    BOOL isDataNotEmpty = (self.dataPuller != nil);
    self.dataPuller = nil;
    [self.graph reloadData];
    self.tradeArray = nil;
    self.depthArray = nil;
    [self.tableView reloadData];
    [self.depthTableView reloadData];
    CGRect frame = self.InfoWindow.frame;
    self.platformType = sender.tag;
    [self SegmentControlValueChanged:self.graphSegmentedController];  //force to send value change message to let the app draw the graph immediantly.
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    if (isDataNotEmpty)
    {
        plotSpace.allowsUserInteraction = NO;
        self.changedCounter = 1;
        //        self.changedCounter = 2; //allow change for Y only
    }
    else
    {
        plotSpace.allowsUserInteraction = YES;
        self.changedCounter = 0; //first launch, no plot change, it just created
    }
    
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
             self.baseView.frame = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))?CGRectMake(0, 20, SCREENWIDTH, SCREENHEIGHT-140):CGRectMake(0,0,SCREENWIDTH,SCREENHEIGHT-120);
         }
                         completion:nil
         ];
    }
    [self InitPriceSetting];
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
        [self.view endEditing:YES];
    }
    else
    {
        [self dismissInfoWindow];
    }
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

- (IBAction)InfoWindowTapHandler:(UITapGestureRecognizer *)sender
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
    if (sender.tag == 10)
    {
        CGRect rect = CGRectMake(SCREENWIDTH*sender.selectedSegmentIndex, 0, SCREENWIDTH, sender.frame.size.height);
        [self.scrollViewInfoWindow scrollRectToVisible:rect animated:YES];
        [self.view endEditing:YES];
    }
    else //tag == 20 graph
    {
        self.selectedCoordination = 0;
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
        plotSpace.allowsUserInteraction = NO;
        self.changedCounter = 2; //allow change for twice
        NSInteger timeoffset = 0;
        switch (sender.selectedSegmentIndex) {
            case 0:
            {
                timeoffset = 42*24; //42 days, 6 weeks
                CPTXYAxisSet *xyAxisSet        = (id)self.graph.axisSet;
                CPTXYAxis *xAxis               = xyAxisSet.xAxis;
                xAxis.title = @"6周";
            }
                break;
            case 1:
            {
                timeoffset = 3*24;  // 3 days
                CPTXYAxisSet *xyAxisSet        = (id)self.graph.axisSet;
                CPTXYAxis *xAxis               = xyAxisSet.xAxis;
                xAxis.title = @"3日";
            }
                break;
            case 2:
            {
                timeoffset = 24;  // a day
                CPTXYAxisSet *xyAxisSet        = (id)self.graph.axisSet;
                CPTXYAxis *xAxis               = xyAxisSet.xAxis;
                xAxis.title = @"24时";
            }
                break;
            case 3:
            {
                timeoffset = 12;  //half a day
                CPTXYAxisSet *xyAxisSet        = (id)self.graph.axisSet;
                CPTXYAxis *xAxis               = xyAxisSet.xAxis;
                xAxis.title = @"12时";
            }
                break;
            default:
                break;
        }
        NSDate *start = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * timeoffset]; // 4 weeks ago
        NSDate *end = [NSDate date];
        
        DataPuller *dp = [[DataPuller alloc] initWithPlatform:self.platformType targetStartDate:start targetEndDate:(NSDate *)end TimeInterval:sender.selectedSegmentIndex];
        
        self.dataPuller = dp;
        if (dp)
            [dp setDelegate:self];
    }
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

#pragma mark core plot
- (void)setupGraphicPlots
{
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [self.graph applyTheme:theme];
    self.graph.frame                       = self.view.bounds;
    self.graph.paddingRight                = 10.0f;
    self.graph.paddingLeft                 = 30.0f;
    self.graph.plotAreaFrame.masksToBorder = NO;
    self.graph.plotAreaFrame.cornerRadius  = 0.0f;
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor           = [CPTColor blackColor];
    borderLineStyle.lineWidth           = 1.0f;
    self.graph.plotAreaFrame.borderLineStyle = borderLineStyle;
    self.graphHostView.hostedGraph          = self.graph;
    
    // Axes
    CPTXYAxisSet *xyAxisSet        = (id)self.graph.axisSet;
    CPTXYAxis *xAxis               = xyAxisSet.xAxis;
    CPTMutableLineStyle *lineStyle = [xAxis.axisLineStyle mutableCopy];
    lineStyle.lineCap   = kCGLineCapButt;
    xAxis.axisLineStyle = lineStyle;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xAxis.titleOffset = 0.0f;
    CPTMutableTextStyle *LabelStype = [CPTMutableTextStyle textStyle];
    LabelStype.color    = [CPTColor darkGrayColor];
    LabelStype.fontSize = 8.0;
    xAxis.titleTextStyle = LabelStype;
    
    
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    lineStyle = [yAxis.axisLineStyle mutableCopy];
    lineStyle.lineCap = kCGLineCapRound;
    yAxis.labelOffset = 10.0f;
    
    CPTMutableTextStyle *yLabelStype = [CPTMutableTextStyle textStyle];
    yLabelStype.color    = [CPTColor blackColor];
    yLabelStype.fontSize = 6.0;
    yAxis.labelTextStyle = yLabelStype;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    yAxis.axisLineStyle = nil;
    
    // Line plot with gradient fill
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:self.graph.bounds];
    dataSourceLinePlot.identifier     = @"Data Source Plot";
    dataSourceLinePlot.dataLineStyle  = nil;
    dataSourceLinePlot.dataSource     = self;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    [self.graph addPlot:dataSourceLinePlot];
    
    CPTColor *areaColor                         = [CPTColor colorWithComponentRed:0.0 green:122/255 blue:1 alpha:1];
    
    CPTMutableLineStyle *blueLineStyle = [CPTMutableLineStyle lineStyle];
    blueLineStyle.lineColor = areaColor;
    blueLineStyle.lineWidth = 1.0f;
    dataSourceLinePlot.dataLineStyle = blueLineStyle;
    
    // OHLC plot
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    CPTMutableLineStyle *greenLineStyle = [CPTMutableLineStyle lineStyle];
    greenLineStyle.lineColor = [CPTColor greenColor];
    greenLineStyle.lineWidth = 0.8f;
    redLineStyle.lineColor = [CPTColor redColor];
    redLineStyle.lineWidth = 0.8f;
    CPTTradingRangePlot *ohlcPlot = [[CPTTradingRangePlot alloc] initWithFrame:self.graph.bounds];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.increaseLineStyle = greenLineStyle;
    ohlcPlot.decreaseLineStyle = redLineStyle;
    ohlcPlot.increaseFill = [CPTFill fillWithColor:[CPTColor greenColor]];
    ohlcPlot.decreaseFill = [CPTFill fillWithColor:[CPTColor redColor]];
    if (OHCP_LABEL_IS_ON)
    {
        CPTMutableTextStyle *blackTextStyle = [CPTMutableTextStyle textStyle];
        blackTextStyle.color    = [CPTColor blackColor];
        blackTextStyle.fontSize = 8.0;
        ohlcPlot.labelTextStyle = blackTextStyle;
        ohlcPlot.labelOffset    = 5.0;
    }
    ohlcPlot.stickLength    = 1.0f;
    ohlcPlot.barWidth = 2.0f;
    ohlcPlot.dataSource = self;
    ohlcPlot.plotStyle = CPTTradingRangePlotStyleCandleStick;
    ohlcPlot.cachePrecision = CPTPlotCachePrecisionDecimal;
    [self.graph addPlot:ohlcPlot];
    
    // Add plot space for bar chart
    CPTXYPlotSpace *volumePlotSpace = [[CPTXYPlotSpace alloc] init];
    volumePlotSpace.identifier = @"Volume Plot Space";
    [self.graph addPlotSpace:volumePlotSpace];
    
    // Volume plot
    CPTBarPlot *volumePlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blackColor] horizontalBars:NO];
    volumePlot.dataSource = self;
    
    lineStyle            = [volumePlot.lineStyle mutableCopy];
    lineStyle.lineColor  = [CPTColor colorWithComponentRed:0 green:122/255 blue:1 alpha:1.0];
    volumePlot.lineStyle = lineStyle;
    
    volumePlot.fill           = nil;
    volumePlot.barWidth       = CPTDecimalFromFloat(1.0f);
    volumePlot.identifier     = @"Volume Plot";
    volumePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    [self.graph addPlot:volumePlot toPlotSpace:volumePlotSpace];
    
    CPTScatterPlot *touchPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectNull];
    touchPlot.identifier = kTouchPlot;
    touchPlot.dataSource = self;
    touchPlot.delegate = self;
    [self.graph addPlot:touchPlot];
    [self applyTouchPlotColor];
    
    
    self.selectedCoordination = 0;
    
    // Data puller
    //    NSDate *start         = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 42]; // 4 weeks ago
    //    NSDate *end           = [NSDate date];
    
    //    DataPuller *dp = [[DataPuller alloc] initWithPlatform:OKCOIN targetStartDate:start targetEndDate:(NSDate *)end TimeInterval:NRCPKLINETIMEINTERVAL24H];
    
    self.dataPuller = nil; //dp;
    // [dp setDelegate:self];
}

- (void)applyTouchPlotColor
{
    CPTScatterPlot *touchPlot = (CPTScatterPlot*)[self.graph plotWithIdentifier:kTouchPlot];
    CPTColor *touchPlotColor = [CPTColor orangeColor];
    
    CPTMutableLineStyle *savingsPlotLineStyle = [CPTMutableLineStyle lineStyle];
    savingsPlotLineStyle.lineColor = touchPlotColor;
    
    CPTPlotSymbol *touchPlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    touchPlotSymbol.fill = [CPTFill fillWithColor:touchPlotColor];
    touchPlotSymbol.lineStyle = savingsPlotLineStyle;
    touchPlotSymbol.size = CGSizeMake(15.0f, 15.0f);
    
    
    touchPlot.plotSymbol = touchPlotSymbol;
    
    CPTMutableLineStyle *touchLineStyle = [CPTMutableLineStyle lineStyle];
    touchLineStyle.lineColor = [CPTColor orangeColor];
    touchLineStyle.lineWidth = 5.0f;
    
    touchPlot.dataLineStyle = touchLineStyle;
    
}

// Highlight the touch plot when the user holding tap on the line symbol.
- (void)applyHighLightPlotColor:(CPTScatterPlot *)plot
{
    CPTColor *selectedPlotColor = [CPTColor redColor];
    
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = selectedPlotColor;
    
    CPTPlotSymbol *plotSymbol = nil;
    plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:selectedPlotColor];
    plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(15.0f, 15.0f);
    
    plot.plotSymbol = plotSymbol;
    
    CPTMutableLineStyle *selectedLineStyle = [CPTMutableLineStyle lineStyle];
    selectedLineStyle.lineColor = [CPTColor yellowColor];
    selectedLineStyle.lineWidth = 5.0f;
    
    plot.dataLineStyle = selectedLineStyle;
}

#pragma mark - CPPlotSpace Delegate Methods
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event
          atPoint:(CGPoint)point
{
    return YES;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point
{
    // Restore the vertical line plot to its initial color.
    [self applyTouchPlotColor];
    self.touchPlotSelected = NO;
    return YES;
}

// This method is call when user touch & drag on the plot space.
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)point
{
    // Convert the touch point to plot area frame location
    CGPoint pointInPlotArea = [self.graph convertPoint:point toLayer:self.graph.plotAreaFrame];
    
    NSDecimal newPoint[2];
    [self.graph.defaultPlotSpace plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointInPlotArea];
    //[self.graph.defaultPlotSpace plotPoint:newPoint forPlotAreaViewPoint:pointInPlotArea];
    NSDecimalRound(&newPoint[0], &newPoint[0], 0, NSRoundPlain);
    int x = [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] intValue];
    
    if (x < 0)
        x = 0;
    else if (x >= [self.dataPuller.filteredFinancialData count])
        x = [self.dataPuller.filteredFinancialData count]-1;
    
    if (self.touchPlotSelected)
    {
        self.selectedCoordination = x;
        [self setGraphDataLabelForDataAtIndex:x];
        CPTScatterPlot *touchPlot = (CPTScatterPlot*)[self.graph plotWithIdentifier:kTouchPlot];
        [touchPlot reloadData];
    }
    
    return YES;
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    if (self.changedCounter == 0)
    {
        if (coordinate == CPTCoordinateY)
            return ((CPTXYPlotSpace *)space).yRange;
        else
            return ((CPTXYPlotSpace *)space).xRange;
    }
    else
    {
        if (--self.changedCounter == 0)
        {
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
            plotSpace.allowsUserInteraction = YES;
        }
        return newRange;
    }
}

#pragma mark - Scatter plot delegate methods

- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    if ([(NSString *)plot.identifier isEqualToString:kTouchPlot])
    {
        self.touchPlotSelected = YES;
        [self applyHighLightPlotColor:plot];
        [self setGraphDataLabelForDataAtIndex:index];
    }
}

#pragma mark - Plot Data Source Methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([(NSString*)plot.identifier isEqualToString:kTouchPlot])
        return 3;
    
    return self.dataPuller.filteredFinancialData.count;
}

-(CPTNumericData *)dataForPlot:(CPTPlot *)plot recordIndexRange:(NSRange)indexRange
{
    NSArray *financialData              = self.dataPuller.filteredFinancialData;
    
    const BOOL useDoubles = plot.doublePrecisionCache;
    
    NSUInteger numFields = plot.numberOfFields;
    
    if ([plot.identifier isEqual:@"Volume Plot"])
        numFields = 2;
    
    NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * numFields * ( useDoubles ? sizeof(double) : sizeof(NSDecimal) )];
    
    const NSUInteger maxIndex = NSMaxRange(indexRange);
    
    NSInteger json_volIndex = (self.platformType == BITSTAMP)?7:5;
    NSInteger json_openIndex = (self.platformType == BITSTAMP)?3:1;
    NSInteger json_closeIndex = 4;
    NSInteger json_maxIndex = (self.platformType == BITSTAMP)?5:2;
    NSInteger json_minIndex = (self.platformType == BITSTAMP)?6:3;
    
    NSInteger moneyDivision = [ToolBox getMoneyDivisionForPlatform:self.platformType];
    NSInteger volDivision = [ToolBox getVolDivisionForPlatform:self.platformType];
    
    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        double *nextValue = data.mutableBytes;
        
        for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
            
            NSNumber *value;
            
            for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                switch ( fieldEnum ) {
                    case CPTScatterPlotFieldX:
                        *nextValue++ = (double)(i + 1);
                        break;
                        
                    case CPTScatterPlotFieldY:
                        value = [NSNumber numberWithDouble:[financialData[i][json_closeIndex] doubleValue]/moneyDivision];//[fData objectForKey:@"close"];                         NSAssert(value, @"Close value was nil");
                        *nextValue++ = [value doubleValue];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    else if ( [plot.identifier isEqual:@"Volume Plot"] )
    {
        double *nextValue = data.mutableBytes;
        
        for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
            //            NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
            NSNumber *value;
            
            for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                switch ( fieldEnum ) {
                    case CPTBarPlotFieldBarLocation:
                        *nextValue++ = (double)(i + 1);
                        break;
                        
                    case CPTBarPlotFieldBarTip:
                        value = [NSNumber numberWithDouble:[financialData[i][json_volIndex] doubleValue]/volDivision];//[fData objectForKey:@"volume"];
                        NSAssert(value, @"Volume value was nil");
                        *nextValue++ = [value doubleValue];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    else if ([plot.identifier isEqual:@"OHLC"])
    {
        NSDecimal *nextValue = data.mutableBytes;
        
        for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
            //            NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
            NSNumber *value;
            
            for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                switch ( fieldEnum ) {
                    case CPTTradingRangePlotFieldX:
                        *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                        break;
                        
                    case CPTTradingRangePlotFieldOpen:
                        value = [NSNumber numberWithDouble:[financialData[i][json_openIndex] doubleValue]/moneyDivision];//[fData objectForKey:@"open"];
                        NSAssert(value, @"Open value was nil");
                        *nextValue++ = [value decimalValue];
                        break;
                        
                    case CPTTradingRangePlotFieldHigh:
                        value = [NSNumber numberWithDouble:[financialData[i][json_maxIndex] doubleValue]/moneyDivision];
                        NSAssert(value, @"High value was nil");
                        *nextValue++ = [value decimalValue];
                        break;
                        
                    case CPTTradingRangePlotFieldLow:
                        value = [NSNumber numberWithDouble:[financialData[i][json_minIndex] doubleValue]/moneyDivision];
                        NSAssert(value, @"Low value was nil");
                        *nextValue++ = [value decimalValue];
                        break;
                        
                    case CPTTradingRangePlotFieldClose:
                        value = [NSNumber numberWithDouble:[financialData[i][json_closeIndex] doubleValue]/moneyDivision];
                        NSAssert(value, @"Close value was nil");
                        *nextValue++ = [value decimalValue];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    else //TOUCH PLOT
    {
        NSDecimal *nextValue = data.mutableBytes;
        
        for ( NSUInteger i = indexRange.location; i < maxIndex; i++ )
        {
            NSNumber *value;
            for (NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++)
            {
                switch (fieldEnum) {
                    case CPTScatterPlotFieldX:
                        value = [NSNumber numberWithInt:self.selectedCoordination];
                        *nextValue++ = [value decimalValue];
                        break;
                    case CPTScatterPlotFieldY:
                        switch (i) {
                            case 0:
                                value = [NSNumber numberWithDouble:([self.dataPuller.overallLow doubleValue])];
                                *nextValue++ = [value decimalValue];
                                break;
                            case 2:
                                value = [NSNumber numberWithInt:0];
                                *nextValue++ = [value decimalValue];
                                break;
                            default:
                                value = [NSNumber numberWithInt:0];
                                if (financialData.count > 30)
                                    value = [NSNumber numberWithDouble:[financialData[self.selectedCoordination][json_closeIndex] doubleValue]/moneyDivision];
                                *nextValue++ = [value decimalValue];
                                break;
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
    CPTMutableNumericData *numericData = [CPTMutableNumericData numericDataWithData:data
                                                                           dataType:(useDoubles ? plot.doubleDataType : plot.decimalDataType)
                                                                              shape:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:indexRange.length],
                                                                                     [NSNumber numberWithUnsignedInteger:numFields], nil]
                                                                          dataOrder:CPTDataOrderRowsFirst];
    return numericData;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ( ![(NSString *)plot.identifier isEqualToString : @"OHLC"] ) {
        return (id)[NSNull null]; // Don't show any label
    }
    else if ( index % 5 ) {
        return (id)[NSNull null];
    }
    else {
        return nil; // Use default label style
    }
}

-(void)dataPullerDidFinishFetch:(DataPuller *)dp
{
    static CPTAnimationOperation *animationOperation = nil;
    
    CPTXYPlotSpace *plotSpace       = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    CPTXYPlotSpace *volumePlotSpace = (CPTXYPlotSpace *)[self.graph plotSpaceWithIdentifier:@"Volume Plot Space"];
    
    NSNumber *high   = self.dataPuller.overallHigh;
    NSNumber *low    = self.dataPuller.overallLow;
    NSNumber *length = [NSNumber numberWithDouble:([high doubleValue] - [low doubleValue])];
    
    //    NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    
    NSNumber *lengthDisplacementValue = [NSNumber numberWithDouble:[length doubleValue] * 0.33];
    NSNumber *lowDisplayLocation = [NSNumber numberWithDouble:([low doubleValue] - [lengthDisplacementValue doubleValue])];
    NSNumber *lengthDisplayLocation = [NSNumber numberWithDouble:[length doubleValue]+[lengthDisplacementValue doubleValue]];
    
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromUnsignedInteger(self.dataPuller.filteredFinancialData.count + 1)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[lowDisplayLocation decimalValue] length:[lengthDisplayLocation decimalValue]];
    
    plotSpace.delegate = self;
    
    CPTScatterPlot *linePlot = (CPTScatterPlot *)[self.graph plotWithIdentifier:@"Data Source Plot"];
    linePlot.areaBaseValue  = [high decimalValue];
    linePlot.areaBaseValue2 = [low decimalValue];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    
    NSNumber *overallVolumeHigh = [NSNumber numberWithDouble:[self.dataPuller.overallVolumeHigh doubleValue]];
    NSNumber *overallVolumeLow = [NSNumber numberWithDouble:[self.dataPuller.overallVolumeLow doubleValue]];
    NSNumber *volumeLength = [NSNumber numberWithDouble:([overallVolumeHigh doubleValue])-([overallVolumeLow doubleValue])];
    
    NSNumber *volumeLengthDisplacementValue = [NSNumber numberWithDouble:[volumeLength doubleValue]*3];
    NSNumber *volumeLowDisplayLocation = overallVolumeLow;
    NSNumber *volumeLengthDisplayLocation = [NSNumber numberWithDouble:([volumeLength doubleValue]+[volumeLengthDisplacementValue doubleValue])];
    
    volumePlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromUnsignedInteger(self.dataPuller.filteredFinancialData.count + 1)];
    volumePlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue] length:[volumeLengthDisplayLocation decimalValue]];
    
    if ( animationOperation ) {
        [[CPTAnimation sharedInstance] removeAnimationOperation:animationOperation];
    }
    
    animationOperation = [CPTAnimation animate:volumePlotSpace
                                      property:@"yRange"
                                 fromPlotRange:[CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue]
                                                                            length:CPTDecimalMultiply( [volumeLengthDisplayLocation decimalValue], CPTDecimalFromInteger(10) )]
                                   toPlotRange:[CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue]
                                                                            length:[volumeLengthDisplayLocation decimalValue]]
                                      duration:2.5];
    
    axisSet.xAxis.orthogonalCoordinateDecimal = [low decimalValue];
    axisSet.yAxis.majorIntervalLength         = CPTDecimalFromDouble(50.0);
    axisSet.yAxis.minorTicksPerInterval       = 4;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(1.0);
    NSArray *exclusionRanges = [NSArray arrayWithObjects:
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:[low decimalValue]],
                                nil];
    
    axisSet.yAxis.labelExclusionRanges = exclusionRanges;
    
    [self.graph reloadData];
    [self setGraphDataLabelForDataAtIndex:self.selectedCoordination];
}

#pragma mark - DataPullerDelegateMethods
- (void)updateBITSTAMPSID
{
    NSString *regulaStr = @"(?<=sid\\s=\\s\")\\w*(?=\")";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSString *sourceCode = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://k.btc123.com/markets/bitstamp/btcusd"] encoding:NSASCIIStringEncoding error:nil];
    if (sourceCode)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:sourceCode options:0 range:NSMakeRange(0, [sourceCode length])];
        
        self.bitstampTimeStamp = (unsigned long long)[[NSDate date] timeIntervalSince1970]*1000;
        
        NSTextCheckingResult *match = arrayOfAllMatches[0];
        self.bitstampSID = [sourceCode substringWithRange:match.range];
        NSLog(@"sid = %@",self.bitstampSID);
    }
    else
        self.bitstampSID = nil;
}

#pragma mark - pricesettings
- (void)setLastPriceNumberWithDoubleNumber:(double)number
{
    self.lastPriceNumber = [NSNumber numberWithDouble:number];
    if (number != UNAVAILABLE)
    {
        self.priceSettingCurrentPriceLabel.text = [NSString stringWithFormat:@"%@ 平台当前价格：%.2f",[ToolBox getPlatformNameByPlatformType:self.platformType],number];
    }
    else
    {
        self.priceSettingCurrentPriceLabel.text = @"平台当前价格不可查";
    }
}

- (void)InitPriceSetting
{
    self.priceSettingMaxTextField.enabled = NO;
    self.priceSettingMinTextField.enabled = NO;
    self.priceSettingHighSwitch.hidden = YES;
    self.priceSettingLowSwitch.hidden = YES;
    [self.priceSettingHighActivityIndicator startAnimating];
    [self.priceSettingLowActivityIndicator startAnimating];
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone)
    {
        if (!self.isNotificationWarningShowedAlready)
        {
            [self showDialogWithContent:@"请在系统设置中打开 CoinUp 的推送功" Title:@"错 误"];
            self.isNotificationWarningShowedAlready = YES;
            return;
        }
        return;
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
    NSString *platform = [ToolBox getPlatformNameByPlatformType:self.platformType];
    NSString *urlString = [NSString stringWithFormat:@"http://115.29.191.191:4321/query?token=%@&platform=%@",token,platform];
    NSURL *url = [NSURL URLWithString:urlString];
    
    __weak NRViewController *weakSelf = self;
    dispatch_queue_t queryQueue = dispatch_queue_create("queryQueue", NULL);
    dispatch_async(queryQueue, ^{
        NSData *queryData = [NSData dataWithContentsOfURL:url];
        if (queryData)
        {
            NSError *error;
            NSDictionary *queryDic = [[[JSONDecoder alloc] init] objectWithData:queryData error:&error];
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showDialogWithContent:@"无法连接服务器" Title:@"错 误"];
                });
                NSLog(@"%@",error);
            }
            else
            {
                double highPrice = [queryDic[@"high"] doubleValue];
                double lowPrice = [queryDic[@"low"] doubleValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.priceSettingHighActivityIndicator stopAnimating];
                    if (highPrice - 0 < 0.0001) // UNAVALIABLE
                    {
                        weakSelf.priceSettingHighSwitch.on = NO;
                        weakSelf.priceSettingHighSwitch.hidden = NO;
                        weakSelf.priceSettingMaxTextField.enabled = YES;
                        weakSelf.priceSettingMaxTextField.text = @"";
                    }
                    else
                    {
                        weakSelf.priceSettingMaxTextField.text = [NSString stringWithFormat:@"%.2f",highPrice];
                        weakSelf.priceSettingMaxTextField.enabled = NO;
                        weakSelf.priceSettingHighSwitch.on = YES;
                        weakSelf.priceSettingHighSwitch.hidden = NO;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.priceSettingLowActivityIndicator stopAnimating];
                    });
                    if (lowPrice - 0 < 0.0001) // UNAVALIABLE
                    {
                        weakSelf.priceSettingLowSwitch.on = NO;
                        weakSelf.priceSettingLowSwitch.hidden = NO;
                        weakSelf.priceSettingMinTextField.enabled = YES;
                        weakSelf.priceSettingMinTextField.text = @"";
                    }
                    else
                    {
                        weakSelf.priceSettingMinTextField.text = [NSString stringWithFormat:@"%.2f",lowPrice];
                        weakSelf.priceSettingMinTextField.enabled = NO;
                        weakSelf.priceSettingLowSwitch.on = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.priceSettingLowSwitch.hidden = NO;
                        });
                    }
                });
                
            }
        }
        else
        {
            NSLog(@"Error102: can not connect to server");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf showDialogWithContent:@"无法连接服务器" Title:@"错 误"];
//            });
        }
    });
}

- (IBAction)priceSettingTextFieldDidBeginEditing:(UITextField *)sender
{
    self.priceSettingScrollView.contentOffset = CGPointMake(0, sender.frame.origin.y-45);
}

- (IBAction)priceSettingTextFieldDidEndEditing:(UITextField *)sender
{
    self.priceSettingScrollView.contentOffset = CGPointMake(0, 0);
}

- (IBAction)priceSettingTextFieldDidEndOnExit:(UITextField *)sender
{
    [sender resignFirstResponder];
}

- (IBAction)tapOutsideOfTextfield:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (IBAction)priceSettingSwitchValueChanged:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on == NO) //OFF
    {
        NSLog(@"%@ switch to OFF",sender);
        if (sender.tag == 6600)//high
            self.priceSettingMaxTextField.enabled = YES;
        else//6610,low
            self.priceSettingMinTextField.enabled = YES;
        
        //remove from server
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *type = (sender.tag ==6600)?@"high":@"low";
        NSDictionary *parameters = @{@"token": TOKEN,@"platform":[ToolBox getPlatformNameByPlatformType:self.platformType],@"type":type};
        
        [manager GET:@"http://115.29.191.191:4321/delete" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"JSON: %@", responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [self showDialogWithContent:@"无法连接服务器" Title:@"错 误"];
             [sender setOn:YES animated:YES];
             NSLog(@"Error: %@", error);
         }];
    }
    else // ON
    {
        NSLog(@"%@ switch to ON",sender);
        
        //check if user input is a valid float number
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *textfieldContent = (sender.tag == 6600)?self.priceSettingMaxTextField.text:self.priceSettingMinTextField.text;
        NSNumber *number = [formatter numberFromString:textfieldContent];
        if (number != nil) //user input is valid
        {
            double userSettingPrice = [number doubleValue];
            double currentPrice = [self.lastPriceNumber doubleValue];
            if (fabs(currentPrice - UNAVAILABLE)>0.0001) //AVAILABLE
            {
                if (sender.tag == 6600)
                {
                    if (userSettingPrice < currentPrice)
                    {
                        NSLog(@"set it higher");
                        [self showDialogWithContent:@"设定值已低于当前价格" Title:@"错 误"];
                        [sender setOn:NO animated:YES];
                    }
                    else
                    {
                        NSLog(@"it's ok, send it to server for high");
                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                        NSDictionary *parameters = @{@"token": TOKEN,@"platform":[ToolBox getPlatformNameByPlatformType:self.platformType],@"high":[NSString stringWithFormat:@"%.2f",[number doubleValue]]};
                        
                        [manager GET:@"http://115.29.191.191:4321/add" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                        {
                            NSLog(@"JSON: %@", responseObject);
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                        {
                            [self showDialogWithContent:@"无法连接服务器" Title:@"错 误"];
                            [sender setOn:NO animated:YES];
                            NSLog(@"Error100: %@", error);
                            NSLog(@"%@",operation);
                        }];
                    }
                }
                else //6610 low
                {
                    if (userSettingPrice > currentPrice)
                    {
                        NSLog(@"set it lower");
                        [self showDialogWithContent:@"设定值已高于当前价格" Title:@"错 误"];
                        [sender setOn:NO animated:YES];
                    }
                    else
                    {
                        NSLog(@"it's ok, send it to server for low");
                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                        NSDictionary *parameters = @{@"token": TOKEN,@"platform":[ToolBox getPlatformNameByPlatformType:self.platformType],@"low":[NSString stringWithFormat:@"%.2f",[number doubleValue]]};
                        
                        [manager GET:@"http://115.29.191.191:4321/add" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                        {
                            NSLog(@"JSON: %@", responseObject);
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                        {
                            [self showDialogWithContent:@"无法连接服务器" Title:@"错 误"];
                            [sender setOn:NO animated:YES];
                            NSLog(@"Error: %@", error);
                        }];
                    }
                }
            }
            else //currentPrice unavailble
            {
                NSLog(@"currentPrice unavailable, just send to server");
                NSString *type = (sender.tag == 6600)?@"high":@"low";
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *parameters = @{@"token": TOKEN,@"platform":[ToolBox getPlatformNameByPlatformType:self.platformType],type:[NSString stringWithFormat:@"%f",[number doubleValue]]};
                
                [manager GET:@"http://115.29.191.191:4321/add" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     NSLog(@"JSON: %@", responseObject);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     [self showDialogWithContent:@"无法连接服务器" Title:@"错 误"];
                     NSLog(@"Error: %@", error);
                 }];
            }
        }
        else
        {
            NSLog(@"user input is not a valid number");
            [self showDialogWithContent:@"请输入有效的价格值" Title:@"错 误"];
            [sender setOn:NO animated:YES];
        }
    }
}

- (void)showDialogWithContent:(NSString*)content Title:(NSString*)title
{
    self.popDiagram.popDialogStyle = FSPopDialogStyleFromBottom;
    self.popDiagram.disappearDialogStyle = FSPopDialogStyleFromBottom;
    self.popDiagram.size = CGSizeMake(300,180);
    self.popDiagram.dialogViewTitle = title;
    self.popDiagram.question = content;
    self.popDiagram.okButtonTitle = @"确 定";
    self.popDiagram.isShow = YES;
    [self.popDiagram appear];

}

@end
