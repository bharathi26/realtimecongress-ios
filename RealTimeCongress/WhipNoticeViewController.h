#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "SunlightLabsConnection.h"
#import "Reachability.h"
#import "RootViewController.h"

#define REQUEST_PAGE_SIZE @"100"

@interface WhipNoticeViewController : UITableViewController <PopoverSupportingViewController>{
    @private
    NSArray *parsedWhipNoticeData;
    NSMutableDictionary *noticeDaysDictionary;
    NSArray *sectionDataArray;
    NSMutableArray *noticeDaysArray;
    SunlightLabsConnection *connection;
    Reachability *reachabilityInfo;
}

@property(nonatomic,retain) NSArray *parsedWhipNoticeData;
@property(nonatomic,retain) NSMutableDictionary *noticeDaysDictionary;
@property(nonatomic,retain) NSArray *sectionDataArray;
@property(nonatomic,retain) NSMutableArray *noticeDaysArray;


- (void) refresh;
- (void) parseData: (NSNotification *)notification;
- (void) parseCachedData: (NSData *) data;
- (void) retrieveData;

@end
