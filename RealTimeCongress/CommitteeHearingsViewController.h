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
#import "RootViewController.h"

#define REQUEST_PAGE_SIZE @"100"
#define IPHONE_CELL_WIDTH 260
#define DETAIL_CELL_WIDTH 660
#define PORTRAIT_CELL_WIDTH 720

@interface CommitteeHearingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PopoverSupportingViewController> {
    @private
    NSArray *parsedHearingData;
    IBOutlet UISegmentedControl *chamberControl;
    UITableViewCell *committeeHearingsCell;
    NSMutableArray *hearingDays;
    NSArray *sectionDataArray;
    NSMutableDictionary *hearingDayDictionary;
    UITableView *hearingsTableView;
    SunlightLabsConnection *connection;
    Reachability *reachabilityInfo;
    int cellWidth;
}

@property(nonatomic,retain) NSArray *parsedHearingData;
@property(nonatomic,retain) NSArray *sectionDataArray;
@property(nonatomic,retain) NSMutableDictionary *hearingDayDictionary;
@property(nonatomic,retain) IBOutlet UISegmentedControl *chamberControl;
@property(nonatomic,retain) NSMutableArray *hearingDays;
@property(nonatomic,retain) IBOutlet UITableView *hearingsTableView;
@property (nonatomic, assign) UITableViewCell *committeeHearingsCell;

- (void) refresh;
- (void) parseData: (NSNotification *)notification;
- (void) parseCachedData: (NSData *) data;
- (void) retrieveData;

@end
