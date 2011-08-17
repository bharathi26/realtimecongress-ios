//
//  GAOReportViewController.h
//  RealTimeCongress
//
//  Created by Tom Tsai on 8/17/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "SunlightLabsConnection.h"
#import "Reachability.h"

#define REQUEST_PAGE_SIZE @"100"
#define CELL_WIDTH 260

@interface GAOReportViewController : UITableViewController {
@private
    UIActivityIndicatorView *loadingIndicator;
    NSMutableDictionary *reportDaysDictionary;
    NSMutableArray *sectionDataArray;
    NSMutableArray *reportDaysArray;
    SunlightLabsConnection *connection;
    Reachability *reachabilityInfo;
}

- (void) refresh;
- (void) parseData: (NSNotification *)notification;
- (void) parseCachedData: (NSData *) data;
- (void) retrieveData;

@end
