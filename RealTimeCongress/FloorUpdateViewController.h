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

#define IPHONE_CELL_WIDTH 260
#define DETAIL_CELL_WIDTH 660
#define PORTRAIT_CELL_WIDTH 720

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
    int cellWidth;
}

@property(nonatomic, retain) IBOutlet UISegmentedControl *control;
@property(nonatomic, retain) IBOutlet UITableView *floorUpdatesTableView;

@end
