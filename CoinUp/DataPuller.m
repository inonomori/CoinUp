//#import "APFinancialData.h"
#import "DataPuller.h"
#import "JSONKit.h"
#import "ToolBox.h"


NSTimeInterval timeIntervalForNumberOfWeeks(float numberOfWeeks)
{
    NSTimeInterval seconds = fabs(60.0 * 60.0 * 24.0 * 7.0 * numberOfWeeks);

    return seconds;
}

@interface DataPuller()

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL loadingData;

//-(void)fetch;
//-(NSString *)URL;
//-(void)notifyPulledData;

@end

@implementation DataPuller

@synthesize startDate;
@synthesize endDate;
@synthesize targetStartDate;
@synthesize targetEndDate;
@synthesize overallLow;
@synthesize overallHigh;
@synthesize overallVolumeHigh;
@synthesize overallVolumeLow;
@synthesize financialData;

@synthesize receivedData;
@synthesize connection;
@synthesize loadingData;

- (id)initWithPlatform:(COINPLATFORMTYPE)platform targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate TimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval
{
    if (platform == NOPLATFORM)
        return nil;
    
    self = [super init];
    if ( self != nil )
    {
        self.targetStartDate = aStartDate;
        self.targetEndDate = anEndDate;
        
        self.platform  = platform;
        self.timeInterval = timeInterval;
        
        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.2];
    }
    
    return self;
}

- (void)setAllAttributes
{
    startDate = [NSDate dateWithTimeIntervalSince1970:[self.financialData[0][0] doubleValue]];
    self.endDate = [NSDate dateWithTimeIntervalSince1970:[self.financialData[self.financialData.count-1][0] doubleValue]];
    
    NSInteger lowIndex = 0;
    NSInteger highIndex = self.financialData.count-1;
    NSInteger index;
    NSInteger l;
    NSInteger h;
    
    while (1)
    {
        index = (highIndex - lowIndex)/2 + lowIndex;
        if (index == lowIndex)
        {
            l = index;
            break;
        }
        if ([[NSDate dateWithTimeIntervalSince1970:[self.financialData[index][0] doubleValue]] compare:self.targetStartDate] == NSOrderedAscending)
        {
            lowIndex = index;
        }
        else if ([[NSDate dateWithTimeIntervalSince1970:[self.financialData[index][0] doubleValue]] compare:self.targetStartDate] == NSOrderedDescending)
        {
            highIndex = index;
        }
        else //equal
        {
            l = index;
            break;
        }
    }
    
    lowIndex = 0;
    highIndex = self.financialData.count-1;
    
    while (1)
    {
        index = (highIndex - lowIndex)/2 + lowIndex;
        if (index == lowIndex)
        {
            h = highIndex;
            break;
        }
        if ([[NSDate dateWithTimeIntervalSince1970:[self.financialData[index][0] doubleValue]] compare:self.targetEndDate] == NSOrderedAscending)
        {
            lowIndex = index;
        }
        else if ([[NSDate dateWithTimeIntervalSince1970:[self.financialData[index][0] doubleValue]] compare:self.targetEndDate] == NSOrderedDescending)
        {
            highIndex = index;
        }
        else //equal
        {
            h = index;
            break;
        }
    }
    
    
    
    
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:h-l+1];
    
    NSInteger interval;
    switch (self.timeInterval)
    {
        case NRCPKLINETIMEINTERVAL24H:
        case NRCPKLINETIMEINTERVAL15M:
            interval = 1;
            break;
        case NRCPKLINETIMEINTERVAL1H:
            interval = 4;
            break;
        case NRCPKLINETIMEINTERVAL30M:
            interval = 2;
            break;
        default:
            interval = 1;
            break;
    }
    
    for (int i = l; i<=h; i += interval)
    {
        [filteredArray addObject:self.financialData[i]];
    }

    self.filteredFinancialData = [filteredArray copy];
    
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:300];
    NSMutableArray *volArray = [NSMutableArray arrayWithCapacity:200];
    for (NSArray *item in self.filteredFinancialData)
    {
        [tempArray addObject:item[2]];
        [tempArray addObject:item[3]];
        [volArray addObject:item[5]];
    }
    self.overallHigh = [NSNumber numberWithDouble:[[tempArray valueForKeyPath:@"@max.self"] doubleValue]/100];
    self.overallLow =  [NSNumber numberWithDouble:[[tempArray valueForKeyPath:@"@min.self"] doubleValue]/100];
    self.overallVolumeHigh = [NSNumber numberWithDouble:[[volArray valueForKeyPath:@"@max.self"] doubleValue]/100000000];
    self.overallVolumeLow = [NSNumber numberWithDouble:[[volArray valueForKeyPath:@"@min.self"] doubleValue]/100000000];
}

-(NSString *)pathForSymbol:(NSString *)aSymbol
{
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *docPath            = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];

    return docPath;
}

-(NSString *)faultTolerantPathForSymbol:(NSString *)aSymbol
{
    NSString *docPath = [self pathForSymbol:aSymbol];

    if ( ![[NSFileManager defaultManager] fileExistsAtPath:docPath] ) {
        //if there isn't one in the user's documents directory, see if we ship with this data
        docPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    }
    return docPath;
}

//Always returns *something*
-(NSDictionary *)dictionaryForSymbol:(NSString *)aSymbol
{
    NSString *path                      = [self faultTolerantPathForSymbol:aSymbol];
    NSMutableDictionary *localPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    return localPlistDict;
}

#pragma mark -
#pragma mark Downloading of data
- (void)fetch
{
    NSURL *url = [ToolBox getKLineURLForPlatform:self.platform ForTimeInterval:self.timeInterval];
    
    __weak DataPuller *weakSelf = self;
    dispatch_queue_t downloadQueue = dispatch_queue_create("KLineDownloadQueue", NULL);
	dispatch_async(downloadQueue, ^{
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        NSArray *cachedArray;
        if (jsonData != nil)
            cachedArray = [[[JSONDecoder alloc] init] objectWithData:jsonData][@"bars"];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.financialData = (jsonData != nil)?cachedArray:nil;
            [weakSelf setAllAttributes];
            [weakSelf.delegate dataPullerDidFinishFetch:weakSelf];
        });
        
	});
	dispatch_release(downloadQueue);
}
@end
