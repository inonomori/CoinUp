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
#import "NRCoinUpBoard.h"

#define OHCP_LABEL_IS_ON NO
#define kTouchPlot @"TOUCH PLOT"

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

@property (nonatomic) NSInteger changedCounter; //sorry, i have no idea how to solve reset xy range problem.

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
    self.changedCounter = 0;  //do not allow change range
    [self setupGraphicPlots];
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
    self.scrollViewInfoWindow.contentSize = CGSizeMake(SCREENWIDTH*3, self.scrollViewInfoWindow.frame.size.height);
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
    self.tradeArray = nil;
    [self.tableView reloadData];
    CGRect frame = self.InfoWindow.frame;
    self.platformType = sender.tag;
    [self SegmentControlValueChanged:self.graphSegmentedController];  //force to send value change message to let the app draw the graph immediantly.
    
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
    if (sender.tag == 10)
    {
    CGRect rect = CGRectMake(SCREENWIDTH*sender.selectedSegmentIndex, 0, SCREENWIDTH, sender.frame.size.height);
    [self.scrollViewInfoWindow scrollRectToVisible:rect animated:YES];
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
    
    NSLog(@"%d",self.dataPuller.filteredFinancialData.count);
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
    
    NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    
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


@end
