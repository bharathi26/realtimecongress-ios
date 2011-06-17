#import <UIKit/UIKit.h>
#import "JSONKit.h"

#define REQUEST_PAGE_SIZE @"100"

@interface WhipNoticeViewController : UITableViewController {
    NSArray *parsedWhipNoticeData;
    NSData *jsonData;
    JSONDecoder *jsonKitDecoder;
    UIActivityIndicatorView *loadingIndicator;
    NSOperationQueue *opQueue;
    NSMutableDictionary *noticeDaysDictionary;
    NSArray *sectionDataArray;
    NSMutableArray *noticeDaysArray;
}

@property(nonatomic,retain) NSArray *parsedWhipNoticeData;
@property(nonatomic,retain) NSData *jsonData;
@property(nonatomic,retain) JSONDecoder *jsonKitDecoder;
@property(nonatomic,retain) UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain) NSOperationQueue *opQueue;
@property(nonatomic,retain) NSMutableDictionary *noticeDaysDictionary;
@property(nonatomic,retain) NSArray *sectionDataArray;
@property(nonatomic,retain) NSMutableArray *noticeDaysArray;


- (void) refresh;
- (void) parseData;
- (void) retrieveData;
- (void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;
@end
