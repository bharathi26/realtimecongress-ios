//
//  CRSReportViewController.h
//  RealTimeCongress
//
//  Created by Tom Tsai on 8/10/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "SunlightLabsConnection.h"
#import "Reachability.h"

#define REQUEST_PAGE_SIZE @"100"

@interface CRSReportViewController : UITableViewController {
@private
    NSArray *parsedCRSReportData;
    UIActivityIndicatorView *loadingIndicator;
    NSMutableDictionary *reportDaysDictionary;
    NSArray *sectionDataArray;
    NSMutableArray *reportDaysArray;
    SunlightLabsConnection *connection;
    Reachability *reachabilityInfo;
}


- (void) refresh;
- (void) parseData: (NSNotification *)notification;
- (void) parseCachedData: (NSData *) data;
- (void) retrieveData;

@end
