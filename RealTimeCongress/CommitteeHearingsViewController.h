//
//  CommitteeHearingsViewController.h
//  RealTimeCongress
//
//  Created by Tom Tsai on 5/25/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "SunlightLabsConnection.h"
#import "Reachability.h"

#define REQUEST_PAGE_SIZE @"100"
#define CELL_WIDTH 260

@interface CommitteeHearingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray *parsedHearingData;
    IBOutlet UISegmentedControl *chamberControl;
    UIActivityIndicatorView *loadingIndicator;
    UITableViewCell *committeeHearingsCell;
    NSMutableArray *hearingDays;
    NSArray *sectionDataArray;
    NSMutableDictionary *hearingDayDictionary;
    UITableView *hearingsTableView;
    SunlightLabsConnection *connection;
    Reachability *reachabilityInfo;
}

@property(nonatomic,retain) NSArray *parsedHearingData;
@property(nonatomic,retain) NSArray *sectionDataArray;
@property(nonatomic,retain) NSMutableDictionary *hearingDayDictionary;
@property(nonatomic,retain) IBOutlet UISegmentedControl *chamberControl;
@property(nonatomic,retain) UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain) NSMutableArray *hearingDays;
@property(nonatomic,retain) IBOutlet UITableView *hearingsTableView;
@property (nonatomic, assign) UITableViewCell *committeeHearingsCell;

- (void) refresh;
- (void) parseData: (NSNotification *)notification;
- (void) parseCachedData: (NSData *) data;
- (void) retrieveData;

@end
