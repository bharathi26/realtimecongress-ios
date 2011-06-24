//
//  FloorUpdateViewController.h
//  RealTimeCongress
//
//  Created by Stephen Searles on 6/4/11.
//  Copyright 2011 Sunlight Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunlightLabsConnection.h"
@class FloorUpdate;

@interface FloorUpdateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
    @private
    SunlightLabsConnection * connection;
    NSMutableArray * floorUpdates;
    NSUInteger page;
    UISegmentedControl * control;
    UITableView *floorUpdatesTableView;
}

@property(nonatomic, retain) IBOutlet UISegmentedControl *control;
@property(nonatomic, retain) IBOutlet UITableView *floorUpdatesTableView;

@end
