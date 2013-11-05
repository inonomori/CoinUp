#import <Foundation/Foundation.h>
#import "NRCoinUpBoard.h"

typedef NS_ENUM(NSInteger, NRCPKLINETIMEINTERVAL) {
    NRCPKLINETIMEINTERVAL24H = 0,
    NRCPKLINETIMEINTERVAL1H = 1,
    NRCPKLINETIMEINTERVAL30M = 2,
    NRCPKLINETIMEINTERVAL15M = 3,
};


@class DataPuller;

@protocol DataPullerDelegate

- (void)updateBITSTAMPSID;
- (void)dataPullerDidFinishFetch:(DataPuller*)dp;
- (NSString*)getBitStampSID;
- (unsigned long long)getBitStampTimeStamp;

@end

@interface DataPuller : NSObject {
    NSDate *startDate;
    NSDate *endDate;

    NSDate *targetStartDate;
    NSDate *targetEndDate;

    @private
    NSString *csvString;

    BOOL loadingData;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (nonatomic, weak) id<DataPullerDelegate,NRCoinUpBoard> delegate;
@property (nonatomic) COINPLATFORMTYPE platform;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *targetStartDate;
@property (nonatomic, retain) NSDate *targetEndDate;
@property (nonatomic) NRCPKLINETIMEINTERVAL timeInterval;
@property (nonatomic, strong) NSArray *financialData;
@property (nonatomic, strong) NSArray *filteredFinancialData;
@property (nonatomic, strong) NSNumber *overallHigh;
@property (nonatomic, strong) NSNumber *overallLow;
@property (nonatomic, strong) NSNumber *overallVolumeHigh;
@property (nonatomic, strong) NSNumber *overallVolumeLow;

- (id)initWithPlatform:(COINPLATFORMTYPE)platform targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate TimeInterval:(NRCPKLINETIMEINTERVAL)timeInterval;

@end
