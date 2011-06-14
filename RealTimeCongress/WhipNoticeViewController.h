#import <UIKit/UIKit.h>
#import "JSONKit.h"

#define REQUEST_PAGE_SIZE @"100"

@interface WhipNoticeViewController : UITableViewController {
    NSArray *parsedWhipNoticeData;
    NSData *jsonData;
    JSONDecoder *jsonKitDecoder;
    UIActivityIndicatorView *loadingIndicator;
    NSOperationQueue *opQueue;
}

@property(nonatomic,retain) NSArray *parsedHearingData;
@property(nonatomic,retain) NSData *jsonData;
@property(nonatomic,retain) JSONDecoder *jsonKitDecoder;
@property(nonatomic,retain) UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,retain) NSOperationQueue *opQueue;


- (void) refresh;
- (void) parseData;
- (void) retrieveData;
- (void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;
@end
