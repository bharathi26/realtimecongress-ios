//
//  FloorUpdateViewController.h
//  RealTimeCongress
//
//  Created by Stephen Searles on 6/4/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunlightLabsConnection.h"
#import "Reachability.h"

#define FLOOR_UPDATE_CELL_WIDTH 230
@class FloorUpdate;

@interface FloorUpdateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
    @private
    SunlightLabsConnection * connection;
    NSMutableArray * floorUpdates;
    NSMutableArray *updateDays;
    NSUInteger page;
    UISegmentedControl * control;
    UITableView *floorUpdatesTableView;
    NSMutableDictionary *updateDayDictionary;
    BOOL refreshed;
    Reachability *reachabilityInfo;
}

@property(nonatomic, retain) IBOutlet UISegmentedControl *control;
@property(nonatomic, retain) IBOutlet UITableView *floorUpdatesTableView;

@end
