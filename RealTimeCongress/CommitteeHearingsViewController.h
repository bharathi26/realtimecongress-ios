//
//  CommitteeHearingsViewController.h
//  RealTimeCongress
//
//  Created by Tom Tsai on 5/25/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"

#define HOUSE_URL @"http://api.realtimecongress.org/api/v1/committee_hearings.json?apikey=dc060e7c2e154278a4167b2c4c571695&chamber=house&per_page=100&legislative_day__gte=2011-06-01"
#define SENATE_URL @"http://api.realtimecongress.org/api/v1/committee_hearings.json?apikey=dc060e7c2e154278a4167b2c4c571695&chamber=senate&per_page=100&legislative_day__gte=2011-06-01"

@interface CommitteeHearingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *parsedHearingData;
    NSData *jsonData;
    JSONDecoder *jsonKitDecoder;
    IBOutlet UISegmentedControl *chamberControl;
    UIActivityIndicatorView *loadingIndicator;
    NSOperationQueue *opQueue;
    UITableViewCell *committeeHearingsCell;
    NSMutableArray *hearingDays;
    UITableView *hearingsTableView;
}

@property(nonatomic,retain) NSArray *parsedHearingData;
@property(nonatomic,retain) NSData *jsonData;
@property(nonatomic,retain) JSONDecoder *jsonKitDecoder;
@property(nonatomic,retain) IBOutlet UISegmentedControl *chamberControl;
@property(nonatomic,retain) UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain) NSOperationQueue *opQueue;
@property(nonatomic,retain) NSMutableArray *hearingDays;
@property(nonatomic,retain) IBOutlet UITableView *hearingsTableView;
@property (nonatomic, assign) UITableViewCell *committeeHearingsCell;

- (void) refresh;
- (void) parseData;
- (void) retrieveData;
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;
@end
